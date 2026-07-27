const processingGames = new Set();
const { updateGameState } = require("../database/games");
const { canActivateToken, findKickToken } = require("../logic/canMove");
const { updateLobbyMessage } = require("../../bot");
const {
  TWO_PLAYER_COLORS,
  FOUR_PLAYER_COLORS,
} = require("../constants/gameConfig");
const initialState = require("../models/initialState");
const { resetTimer, pauseTimer, stopTimer } = require("./turnTimerService");
const {
  finishGame,
  sendError,
  validateGameAndPlayer,
} = require("../helpers/game_helpers");
const { generateBalancedDice } = require("../helpers/dice_helper");

function handleRollDice(socket, io, callback) {
  const validation = validateGameAndPlayer(socket, callback);
  if (!validation.isValid) return;

  if (processingGames.has(socket.data.gameId)) {
    return sendError(socket, callback, "در حال پردازش...");
  }

  const gameState = validation.gameState;
  const player = validation.player;
  processingGames.add(socket.data.gameId);

  try {
    // بررسی نوبت بازیکن
    let colorIdx =
      gameState.number_of_players === 4
        ? FOUR_PLAYER_COLORS.indexOf(gameState.current_turn)
        : TWO_PLAYER_COLORS.indexOf(gameState.current_turn);

    if (
      player.color !== gameState.current_turn ||
      gameState.turn_status !== "waitingForRoll"
    ) {
      return sendError(socket, callback, "Not your turn!");
    }

    // تایید دریافت درخواست موفق (Ack)
    if (typeof callback === "function") {
      callback({ success: true });
    }

    pauseTimer(socket.data.gameId);

    // انداختن تاس
    const dice = generateBalancedDice(gameState, player);

    // بررسی توکن‌های فعال
    const isActivePlayer = gameState.tokens.some((t) =>
      canActivateToken(t, gameState, dice),
    );

    // به‌روز رسانی وضعیت بازی بر اساس نتیجه تاس
    let updates = { last_dice_value: dice };
    let changePlayer = false;

    if (isActivePlayer) {
      updates.turn_status = "waitingForMove";
    } else if (dice === 6) {
      updates.turn_status = "waitingForRoll";
    } else {
      while (
        gameState.players[(colorIdx + 1) % gameState.number_of_players]
          .player_status === "offline"
      ) {
        colorIdx = colorIdx + 1;
      }
      updates.current_turn =
        gameState.number_of_players === 4
          ? FOUR_PLAYER_COLORS[(colorIdx + 1) % gameState.number_of_players]
          : TWO_PLAYER_COLORS[(colorIdx + 1) % gameState.number_of_players];
      updates.turn_status = "waitingForRoll";
      changePlayer = true;
    }

    // آپدیت در حافظه سراسری
    initialState.updateGameState(socket.data.gameId, {
      ...updates,
      players: gameState.players,
    });

    // پخش رویداد به همه بازیکنان
    io.to(socket.data.gameId).emit("dice_rolled", updates);

    if (changePlayer) {
      initialState.updateGameState(socket.data.gameId, {
        turn_status: "waitingForAnimate",
      });
      setTimeout(() => {
        initialState.updateGameState(socket.data.gameId, {
          turn_status: "waitingForRoll",
        });

        resetTimer(socket, io);
      }, 1000);
    } else {
      resetTimer(socket, io);
    }
  } finally {
    processingGames.delete(socket.data.gameId);
  }
}

function handleMoveToken(socket, token, io, callback) {
  const validation = validateGameAndPlayer(socket, callback);
  if (!validation.isValid) return;

  if (processingGames.has(socket.data.gameId)) {
    return sendError(socket, callback, "در حال پردازش...");
  }

  const gameState = validation.gameState;
  const player = validation.player;

  if (!token || !token.id) {
    return sendError(socket, callback, "Invalid Token");
  }

  const tokenIndex = gameState.tokens.findIndex(
    (t) => Number(t.id) === Number(token.id),
  );

  if (tokenIndex === -1) {
    return sendError(socket, callback, "Token not found");
  }

  processingGames.add(socket.data.gameId);

  try {
    const currentToken = gameState.tokens[tokenIndex];
    let colorIdx =
      gameState.number_of_players === 4
        ? FOUR_PLAYER_COLORS.indexOf(gameState.current_turn)
        : TWO_PLAYER_COLORS.indexOf(gameState.current_turn);

    const canMove =
      gameState.turn_status === "waitingForMove" &&
      canActivateToken(currentToken, gameState, gameState.last_dice_value) &&
      player.color === currentToken.color &&
      gameState.current_turn === player.color;

    if (!canMove) {
      return sendError(socket, callback, "Invalid Move");
    }

    // تایید دریافت درخواست موفق (Ack)
    if (typeof callback === "function") {
      callback({ success: true });
    }

    let updatedTokens = [...gameState.tokens];

    const kickedToken = findKickToken(
      currentToken,
      gameState.last_dice_value,
      gameState.tokens,
    );
    let hasKick = false;
    if (kickedToken) {
      hasKick = true;
      const kickedIdx = updatedTokens.findIndex((t) => t.id === kickedToken.id);
      updatedTokens[kickedIdx] = { ...kickedToken, position: -1 };
    }

    // حرکت توکن در آرایه سرور
    if (currentToken.position === -1) {
      updatedTokens[tokenIndex] = { ...currentToken, position: 0 };
    } else {
      updatedTokens[tokenIndex] = {
        ...currentToken,
        position: currentToken.position + gameState.last_dice_value,
      };
    }

    const isSix = gameState.last_dice_value === 6;

    let socketUpdates = {
      token_id: currentToken.id,
      target_position: updatedTokens[tokenIndex].position,
      has_kick: hasKick,
      kicked_token_id: kickedToken ? kickedToken.id : null,
    };

    let nextTurn = gameState.current_turn;
    if (isSix) {
      socketUpdates.turn_status = "waitingForRoll";
    } else {
      while (
        gameState.players[(colorIdx + 1) % gameState.number_of_players]
          .player_status === "offline"
      ) {
        colorIdx = colorIdx + 1;
      }
      nextTurn =
        gameState.number_of_players === 4
          ? FOUR_PLAYER_COLORS[(colorIdx + 1) % gameState.number_of_players]
          : TWO_PLAYER_COLORS[(colorIdx + 1) % gameState.number_of_players];
      socketUpdates.current_turn = nextTurn;
      socketUpdates.turn_status = "waitingForRoll";
    }

    initialState.updateGameState(socket.data.gameId, {
      tokens: updatedTokens,
      current_turn: nextTurn,
      turn_status: socketUpdates.turn_status,
    });

    // پخش رویداد حرکت به کلاینت‌ها
    io.to(socket.data.gameId).emit("token_moved", {
      updates: socketUpdates,
      has_kick: hasKick,
    });

    initialState.updateGameState(socket.data.gameId, {
      turn_status: "waitingForAnimate",
    });
    pauseTimer(socket.data.gameId);

    let time =
      currentToken.position === -1 ? 300 : gameState.last_dice_value * 300;

    setTimeout(async () => {
      const currentGameState = initialState.getGameState(socket.data.gameId);
      if (!currentGameState) return;

      const playerTokens = currentGameState.tokens.filter(
        (t) => t.color === player.color,
      );

      initialState.updateGameState(socket.data.gameId, {
        turn_status: "waitingForRoll",
      });

      const hasNotWon = playerTokens.some((t) => t.position !== 39);
      if (hasNotWon) {
        resetTimer(socket, io);
      } else {

        await finishGame(
          socket.data.gameId,
          player,
          currentGameState.game_type,
          io,
        );
      }
    }, time);
  } finally {
    processingGames.delete(socket.data.gameId);
  }
}

async function handleExitingGame(socket, io, callback) {
  const gameId = socket.data?.gameId;
  const telegramId = socket.data?.telegramId;

  if (!gameId) {
    return sendError(socket, callback, "No game found!");
  }

  let currentGame = initialState.getGameState(gameId);
  if (!currentGame) {
    if (typeof callback === "function") callback({ success: true });
    socket.emit("player_exit");
    return;
  }

  const player = currentGame.players.find((p) => p.telegram_id === telegramId);
  if (!player) {
    return sendError(socket, callback, "Player not found in game!");
  }

  if (typeof callback === "function") {
    callback({ success: true });
  }

  // ==========================================
  // حالت اول: بازی هنوز شروع نشده (در لابی)
  // ==========================================
  if (currentGame.game_status === "waitingForPlayer") {
    const deletePlayerList = currentGame.players.filter(
      (p) => p.telegram_id !== telegramId,
    );

    const correctColorPlayersList = deletePlayerList.map((p, index) => {
      return {
        ...p,
        color:
          currentGame.number_of_players === 2
            ? TWO_PLAYER_COLORS[index]
            : FOUR_PLAYER_COLORS[index],
      };
    });

    initialState.updateGameState(gameId, {
      players: correctColorPlayersList,
    });

    currentGame = initialState.getGameState(gameId);

    socket.emit("player_exit");
    socket.to(gameId).emit("opponent_exit", { userId: telegramId });
    socket.leave(gameId);

    if (currentGame.players.length === 0) {
      await updateGameState(
        gameId,
        {
          game_status: "cancel",
          players: currentGame.players,
          end_at: new Date(),
        },
        currentGame.game_type,
      );
      initialState.updateGameState(gameId, { game_status: "cancel" });
      updateLobbyMessage(gameId);
      initialState.deleteGameState(gameId);
    } else {
      updateLobbyMessage(gameId);
    }

    socket.data.gameId = null;
    socket.data.color = null;
  }

  // ==========================================
  // حالت دوم: بازی شروع شده
  // ==========================================
  else if (currentGame.game_status === "start") {
    const correctPlayers = currentGame.players.map((p) => {
      if (p.telegram_id === telegramId) {
        return { ...p, player_status: "offline" };
      }
      return p;
    });

    initialState.updateGameState(gameId, {
      players: correctPlayers,
    });

    currentGame = initialState.getGameState(gameId);

    socket.emit("player_exit");
    socket.to(gameId).emit("opponent_exit", { userId: telegramId });
    socket.leave(gameId);

    const onlinesList = currentGame.players.filter(
      (p) => p.player_status === "online",
    );
    const numberOfOnlines = onlinesList.length;

    if (numberOfOnlines === 1) {
      const winnerPlayer = onlinesList[0];


      await finishGame(
        currentGame.game_id,
        winnerPlayer,
        currentGame.game_type,
        io,
      );
    } else if (numberOfOnlines === 0) {

      await updateGameState(
        gameId,
        {
          game_status: "cancel",
          players: currentGame.players,
          end_at: new Date(),
        },
        currentGame.game_type,
      );

      stopTimer(gameId);
      initialState.deleteGameState(gameId);
    }

    socket.data.gameId = null;
    socket.data.color = null;
  }
}

module.exports = { handleRollDice, handleMoveToken, handleExitingGame };
