const { joinGameQueue, acquireGameLock } = require("./joinGameQueue.js");
const initialState = require("../models/initialState");
const { createFriendlyGame, createGlobalGame } = require("../database/games");
const {
  TWO_PLAYER_COLORS,
  FOUR_PLAYER_COLORS,
  LEVEL_COSTS,
} = require("../constants/gameConfig");
const { addPlayerToGameOnDatabase } = require("../database/gamePlayers");
const { reduceMultiplePlayersCoin } = require("../database/players.js");
const { updateGameState } = require("../database/games");
const { startTimer } = require("../services/turnTimerService");
const { updateLobbyMessage } = require("../../bot.js");
const { hasExistGame } = require("./authService.js");

async function handleJoinGame(data, socket, io) {
  console.log("handle joining game");
  const { numberOfPlayers, gameType, gameLevel } = data;
  const telegramId = socket.data.telegramId;

  // ۱. قفل اول: انحصار بر اساس آیدی بازیکن (جلوگیری از درخواست همزمان خود کاربر)
  return await joinGameQueue(telegramId, async () => {
    const player = {
      username: socket.data.firstName,
      telegram_id: telegramId,
      coin: socket.data.coin,
    };

    // بررسی بازی فعال و رها شده
    const result = await hasExistGame(player, socket.id);
    if (result.game) {
      console.log("hasGame");
      socket.emit("in_another_game");
      const { handleRequestGameState } = require("./requestGameState.js");
      await handleRequestGameState(
        socket,
        {
          gameType: gameType,
          gameId: result.game.game_id,
        },
        io,
      );
      return;
    }

    const entryFee = gameType === "friendly" ? 0 : LEVEL_COSTS[gameLevel] || 0;

    // ----------------------------------------------------
    // بخش بازی‌های عمومی (Global)
    // ----------------------------------------------------
    if (gameType === "global") {
      if (player.coin < entryFee) {
        socket.emit("insufficient_coin");
        return;
      }

      let game;
      let isJoined = false;

      // یک حلقه برای پیدا کردن یا ساخت اتاق، تا اگر قفل اتاقی آزاد شد و پر بود، شانسش را از دست ندهد
      while (!isJoined) {
        game = initialState.getAllGames().find(
          (g) =>
            g.game_status === "waitingForPlayer" &&
            g.number_of_players === numberOfPlayers &&
            g.game_type === "global" &&
            g.game_level === gameLevel &&
            g.players.length < numberOfPlayers, // مطمئن شویم پر نیست
        );

        if (!game) {
          // اگر بازی نبود، یکی می‌سازیم
          const dbGame = await createGlobalGame(numberOfPlayers, gameLevel);
          game = initialState.createGameInGameState(
            dbGame.game_id,
            numberOfPlayers,
            gameType,
            gameLevel,
          );
        }

        // ۲. قفل دوم: انحصار بر اساس آیدی بازی (جلوگیری از تداخل بازیکنان مختلف در این اتاق)
        isJoined = await acquireGameLock(game.game_id, async () => {
          // استیت به‌روز شده بازی را داخل قفل مجدد می‌گیریم
          const currentRoomState = initialState.getGameState(game.game_id);

          // چک امنیتی: آیا در حین معطل شدن پشت قفل، ظرفیت پر شده؟
          if (
            currentRoomState.players.length >=
            currentRoomState.number_of_players
          ) {
            return false; // شکست در ورود، حلقه در دور بعدی یک اتاق دیگر پیدا می‌کند
          }

          // اضافه کردن بازیکن با رنگ و صندلی کاملاً امن
          await addPlayerToGame(currentRoomState, player, socket);
          return true;
        });
      }

      socket.data.gameId = game.game_id;
      await callFront(socket, io);
    }

    // ----------------------------------------------------
    // بخش بازی‌های دوستانه (Friendly)
    // ----------------------------------------------------
    if (gameType === "friendly") {
      let room = await createFriendlyGame(numberOfPlayers, "free");
      room = initialState.createGameInGameState(
        room.room_id,
        numberOfPlayers,
        gameType,
        "free",
      );

      // بازی‌های دوستانه تازه ساخته شده‌اند اما برای رعایت ساختار استاندارد قفل آن را می‌گیریم
      await acquireGameLock(room.game_id, async () => {
        await addPlayerToGame(room, player, socket);
      });

      socket.data.gameId = room.game_id;
      await callFront(socket, io);
    }
  });
}

async function handleJoinGameFriendly(socket, io) {
  console.log("joining game friendly");
  const telegramId = socket.data.telegramId;
  const gameId = socket.data.gameId;

  return await joinGameQueue(telegramId, async () => {
    const player = {
      username: socket.data.firstName,
      telegram_id: telegramId,
      coin: socket.data.coin,
    };
    try {
      // استفاده از قفل بازی برای ورود به اتاق دوستانه موجود
      await acquireGameLock(gameId, async () => {
        const game = initialState.getGameState(gameId);
        if (!game || game.players.length >= game.number_of_players) {
          throw new Error("Room is full or doesn't exist");
        }
        await addPlayerToGame(game, player, socket);
      });

      await callFront(socket, io);
    } catch (err) {
      console.log("Error in joining friendly game:", err);
      socket.emit("join_error", { message: err.message });
    }
  });
}

async function callFront(socket, io) {
  const gameId = socket.data.gameId;
  const telegramId = socket.data.telegramId;

  socket.join(gameId);

  let currentGameState = initialState.getGameState(gameId);
  if (!currentGameState) return;

  socket.emit("game_state_update", currentGameState);

  const newPlayer = currentGameState.players.find(
    (p) => p.telegram_id === telegramId,
  );
  if (newPlayer) {
    socket.to(gameId).emit("player_joined", newPlayer);
  }

  if (
    currentGameState.players.length === currentGameState.number_of_players &&
    currentGameState.game_status === "waitingForPlayer"
  ) {
    currentGameState.game_status = "start";

    if (currentGameState.game_type === "global") {
      const coinCost = LEVEL_COSTS[currentGameState.game_level] || 0;

      if (coinCost > 0) {
        let playersTelegramId = [];

        const reducedPlayers = currentGameState.players.map((p) => {
          playersTelegramId.push(p.telegram_id);
          return {
            ...p,
            coin: p.coin - coinCost,
          };
        });

        initialState.updateGameState(gameId, {
          players: reducedPlayers,
        });

        try {
          await reduceMultiplePlayersCoin(playersTelegramId, coinCost);
        } catch (dbError) {
          console.error("Error reducing coins from DB:", dbError);
        }

        const sockets = await io.in(gameId).fetchSockets();
        sockets.forEach((s) => {
          s.data.coin = s.data.coin - coinCost;
        });
      }
    }

    await updateGameState(
      gameId,
      { game_status: "start" },
      currentGameState.game_type,
    );

    initialState.updateGameState(gameId, {
      game_status: "start",
    });

    io.to(gameId).emit("game_started");
    startTimer(socket, io);
  }

  updateLobbyMessage(gameId);
}

async function addPlayerToGame(game, player, socket) {
  const players = game.players;

  // با توجه به اینکه این تابع حالا همواره درون فرآیند انحصاری acquireGameLock اجرا می‌شود،
  // مقدار players.length کاملاً دقیق و بدون تداخل خواهد بود.
  const color =
    game.number_of_players === 2
      ? TWO_PLAYER_COLORS[players.length]
      : FOUR_PLAYER_COLORS[players.length];

  socket.data.color = color;

  const playerInDataBase = await addPlayerToGameOnDatabase(
    player,
    game.game_id,
    color,
    game.game_type,
  );

  const correctPlayer = {
    ...playerInDataBase,
    color: color,
    player_status: "online",
    numberOfAbsences: 0,
    connection_status: "connected",
    avatar_url: socket.data.avatarUrl,
  };

  initialState.addPlayerToGameState(correctPlayer, game.game_id);
}

module.exports = { handleJoinGame, handleJoinGameFriendly };
