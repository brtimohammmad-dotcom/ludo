const processingGames = new Set();
const { updateGameState } = require("../database/games");
const { canActivateToken, findKickToken } = require("../logic/canMove");
const { updateLobbyMessage } = require("../../bot");
const {
  TOW_PLAYER_COLORS,
  FOUR_PLAYER_COLORS,
} = require("../constants/gameConfig");
const initialState = require("../models/initialState"); // اضافه شود
const { resetTimer, pauseTimer, stopTimer } = require("./turnTimerService");

function handleRollDice(socket, io) {
  // دریافت state از حافظه سراسری
  const gameState = initialState.getGameState(socket.data.gameId);

  if (!gameState) {
    return socket.emit("error", "Game not found!");
  }

  if (gameState.game_status !== "start") {
    return socket.emit("error", "The game hasn't started yet!");
  }

  // پیدا کردن بازیکن بر اساس socket.id
  const player = gameState.players.find(
    (p) => p.telegram_id === socket.data.telegramId,
  );

  if (!player) {
    return socket.emit("error", "Player not found!");
  }
  if (processingGames.has(socket.data.gameId)) {
    return socket.emit("error", "در حال پردازش...");
  }

  processingGames.add(socket.data.gameId);

  try {
    // بررسی نوبت بازیکن
    let colorIdx =
      gameState.number_of_players === 4
        ? FOUR_PLAYER_COLORS.indexOf(gameState.current_turn)
        : TOW_PLAYER_COLORS.indexOf(gameState.current_turn);
    if (
      player.color !== gameState.current_turn ||
      gameState.turn_status !== "waitingForRoll"
    ) {
      return socket.emit("error", "Not your turn!");
    }

    pauseTimer(socket.data.gameId);
    // انداختن تاس
    const dice = Math.floor(Math.random() * 6) + 1;

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
          : TOW_PLAYER_COLORS[(colorIdx + 1) % gameState.number_of_players];
      updates.turn_status = "waitingForRoll";
      changePlayer = true;
    }

    // آپدیت در حافظه سراسری
    initialState.updateGameState(socket.data.gameId, {
      ...updates,
    });

    // پخش رویداد به همه بازیکنان این بازی
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
function handleMoveToken(socket, token, io) {
  // دریافت state از حافظه سراسری
  const gameState = initialState.getGameState(socket.data.gameId);

  if (!gameState) {
    return { error: "Game not found!" };
  }

  const player = gameState.players.find(
    (p) => p.telegram_id === socket.data.telegramId,
  );

  if (!player) return { error: "Player not found!" };

  if (!token || !token.id) return { error: "Invalid token!" };

  const tokenIndex = gameState.tokens.findIndex((t) => {
    return Number(t.id) === Number(token.id);
  });

  if (tokenIndex === -1) return { error: "Token not found!" };
  if (processingGames.has(socket.data.gameId)) {
    return socket.emit("error", "در حال پردازش...");
  }
  processingGames.add(socket.data.gameId);
  try {
    const currentToken = gameState.tokens[tokenIndex];
    let colorIdx =
      gameState.number_of_players === 4
        ? FOUR_PLAYER_COLORS.indexOf(gameState.current_turn)
        : TOW_PLAYER_COLORS.indexOf(gameState.current_turn);

    const canMove =
      gameState.turn_status === "waitingForMove" &&
      canActivateToken(currentToken, gameState, gameState.last_dice_value) &&
      player.color === currentToken.color &&
      gameState.current_turn === player.color;

    if (!canMove) return { error: "Invalid move!" };

    // کپی از توکن‌ها برای اعمال تغییرات در سرور
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

    // ۱. دیتای سبک و بهینه فقط برای فرستادن روی سوکت (کلاینت)
    let socketUpdates = {
      token_id: currentToken.id,
      target_position: updatedTokens[tokenIndex].position,
      has_kick: hasKick,
      kicked_token_id: kickedToken ? kickedToken.id : null,
    };

    // ۲. متغیرهای وضعیت بعدی بازی برای ذخیره در سرور
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
          : TOW_PLAYER_COLORS[(colorIdx + 1) % gameState.number_of_players];
      socketUpdates.current_turn = nextTurn;
      socketUpdates.turn_status = "waitingForRoll";
    }

    // ۳. آپدیت حیاتی حافظه سراسری سرور (هم دیتای کلاینت و هم آرایه توکن‌ها اعمال می‌شود)
    initialState.updateGameState(socket.data.gameId, {
      tokens: updatedTokens, // 🌟 بسیار مهم: آرایه توکن‌ها روی سرور حتماً باید بروزرسانی شود
      current_turn: nextTurn,
      turn_status: socketUpdates.turn_status,
    });

    // پخش رویداد بهینه به همه بازیکنان
    io.to(socket.data.gameId).emit("token_moved", {
      updates: socketUpdates,
      has_kick: hasKick,
    });
    // بردن وضعیت به انیمیشن روی سرور
    initialState.updateGameState(socket.data.gameId, {
      turn_status: "waitingForAnimate",
    });
    pauseTimer(socket.data.gameId);

    // مدیریت زمان‌بندی سرور با فرانت
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
        // ... منطق پایان بازی (کاملاً درست است)
        console.log(
          `Game ${socket.data.gameId} finished, winner: ${player.username}`,
        );
        initialState.updateGameState(socket.data.gameId, {
          game_status: "finished",
          winner: player,
        });
        updateLobbyMessage(socket.data.gameId);

        const winnerGameState = initialState.getGameState(socket.data.gameId);
        await updateGameState(
          socket.data.gameId,
          {
            game_status: "finished",
            winner: player,
            players: winnerGameState.players,
            end_at: new Date(),
          },
          winnerGameState.game_mode,
        );
        stopTimer(socket.data.gameId);
        io.to(socket.data.gameId).emit("game_finished", winnerGameState.winner);
        initialState.deleteGameState(socket.data.gameId);
        socket.leave();
      }
    }, time);
  } finally {
    processingGames.delete(socket.data.gameId);
  }
}
async function handleExitingGame(socket, io) {
  let currentGame = initialState.getGameState(socket.data.gameId);
  if (!currentGame) {
    socket.emit("player_exit");
    return;
  }

  const correctPlayers = currentGame.players.map((p) => {
    if (p.telegram_id === socket.data.telegramId) {
      return { ...p, player_status: "offline" };
    } else {
      return p;
    }
  });
  initialState.updateGameState(socket.data.gameId, { players: correctPlayers });
  currentGame = initialState.getGameState(socket.data.gameId);
  socket.emit("player_exit");
  socket
    .to(socket.data.gameId)
    .emit("opponent_exit", { userId: socket.data.telegramId });
  socket.leave(socket.data.gameId);
  const numberOfOnlines = currentGame.players.filter(
    (p) => p.player_status === "online",
  ).length;
  if (numberOfOnlines === 0 && currentGame.game_status === "waitingForPlayer") {
    await updateGameState(
      socket.data.gameId,
      {
        game_status: "cancel",
        players: currentGame.players,
        end_at: new Date(),
      },
      currentGame.game_mode,
    );
    initialState.updateGameState(socket.data.gameId, { game_status: "cancel" });
    updateLobbyMessage(socket.data.gameId);
    initialState.deleteGameState(socket.data.gameId);
  }
  if (numberOfOnlines === 1 && currentGame.game_status === "start") {
    const player = currentGame.players.find(
      (p) => p.player_status === "online",
    );
    console.log(
      `Game ${socket.data.gameId} finished, winner: ${player.username}`,
    );
    initialState.updateGameState(socket.data.gameId, {
      game_status: "finished",
      winner: player,
    });
    updateLobbyMessage(socket.data.gameId);

    const winnerGameState = initialState.getGameState(socket.data.gameId);
    await updateGameState(
      socket.data.gameId,
      {
        game_status: "finished",
        winner: player,
        players: winnerGameState.players,
        end_at: new Date(),
      },
      currentGame.game_mode,
    );
    stopTimer(socket.data.gameId);
    io.to(socket.data.gameId).emit("game_finished", winnerGameState.winner);
    initialState.deleteGameState(socket.data.gameId);
  }
  socket.data.gameId = null;
}
module.exports = { handleRollDice, handleMoveToken, handleExitingGame };
