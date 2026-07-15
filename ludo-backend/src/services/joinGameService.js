const { joinGameQueue } = require("./joinGameQueue.js");
const initialState = require("../models/initialState");
const { createFriendlyGame, createGlobalGame } = require("../database/games");
const {
  TWO_PLAYER_COLORS,
  FOUR_PLAYER_COLORS,
  LEVEL_COSTS
} = require("../constants/gameConfig");
const { addPlayerToGameOnDatabase } = require("../database/gamePlayers");
const { reduceMultiplePlayersCoin } = require("../database/players.js");
const { updateGameState } = require("../database/games");
const { startTimer } = require("../services/turnTimerService");
const { error } = require("node:console");
const { updateLobbyMessage } = require("../../bot.js");
const { hasExistGame } = require("./authService.js");

// تعریف هزینه‌‌های هر سطح بازی به صورت متمرکز و امن


async function handleJoinGame(data, socket, io) {
  console.log("handle joining game")
  const { numberOfPlayers, gameType, gameLevel } = data;

  console.log("player id: ", socket.data.telegramId, " joined");
  console.log("player name: ", socket.data.firstName, "joined");
  console.log("number of players is: ", numberOfPlayers);
  console.log("game type is: ", gameType);
  console.log("game level is: ", gameLevel);

  // استفاده از آیدی تلگرام بازیکن به عنوان کلید قفل (تغییری که با هم دادیم)
  return await joinGameQueue(socket.data.telegramId, async () => {
    const player = {
      username: socket.data.firstName,
      telegram_id: socket.data.telegramId,
      coin: socket.data.coin,
    };

    // بررسی اینکه آیا بازیکن در حال حاضر بازیِ فعالِ رهاشده دارد یا نه
    const result = await hasExistGame(player, socket.id);
    if (result.game) {
      console.log("hasGame");
      socket.emit("in_another_game");
      const { handleRequestGameState } = require("./requestGameState.js");
      await handleRequestGameState(
        socket,
        {
          gameType: gameType, // استفاده از نوع واقعی بازی
          gameId: result.game.game_id,
        },
        io,
      );
      return;
    }

    let gameOrRoom;

    // محاسبه‌ی امن هزینه‌ی ورودی بر اساس لول بازی از سمت سرور
    const entryFee = gameType === "friendly" ? 0 : LEVEL_COSTS[gameLevel] || 0;

    // ----------------------------------------------------
    // بخش بازی‌های عمومی (Global)
    // ----------------------------------------------------
    if (gameType === "global") {
      // بررسی موجودی سکه بر اساس هزینه واقعی این لول خاص
      if (player.coin < entryFee) {
        socket.emit("insufficient_coin");
        return;
      }

      // پیدا کردن بازی‌های در حال انتظار متناسب با این لول و تعداد بازیکن
      let game = initialState.getAllGames().find(
        (g) =>
          g.game_status === "waitingForPlayer" &&
          g.number_of_players === numberOfPlayers &&
          g.game_type === "global" &&
          g.game_level === gameLevel, // فیلتر کردن بر اساس سطح بازی
      );

      if (!game) {
        // ساخت بازی در دیتابیس و حافظه با مشخصات جدید
        game = await createGlobalGame(
          numberOfPlayers,
          gameLevel,
        );
        game = initialState.createGameInGameState(
          game.game_id,
          numberOfPlayers,
          gameType,
          gameLevel,
        );
      }

      await addPlayerToGame(game, player, socket);
      game = initialState.getGameState(game.game_id);
      gameOrRoom = game;
    }

    // ----------------------------------------------------
    // بخش بازی‌های دوستانه (Friendly)
    // ----------------------------------------------------
    if (gameType === "friendly") {
      // ساخت بازی دوستانه (کلاینت لول بازی را free می‌فرستد)
      let room = await createFriendlyGame(
        numberOfPlayers,
        "free",
      );

      room = initialState.createGameInGameState(
        room.room_id,
        numberOfPlayers,
        gameType,
        "free",
      );

      await addPlayerToGame(room, player, socket);
      room = initialState.getGameState(room.game_id);

      gameOrRoom = room;
    }

    socket.data.gameId = gameOrRoom.game_id;
    callFront(socket, io);
  });
}

async function handleJoinGameFriendly(socket, io) {
  console.log("joining game friendly");
  return await joinGameQueue(socket.data.telegramId, async () => {
    const player = {
      username: socket.data.firstName,
      telegram_id: socket.data.telegramId,
      coin: socket.data.coin,
    };
    try {
      const game = initialState.getGameState(socket.data.gameId);

      await addPlayerToGame(game, player, socket);
      callFront(socket, io);
    } catch (err) {
      console.log("Error in joining friendly game:", err);
    }
  });
}

async function callFront(socket, io) {
  const gameId = socket.data.gameId;
  const telegramId = socket.data.telegramId;

  // سوکت را وارد روم کن
  socket.join(gameId);

  // state فعلی بازی را بگیر
  let currentGameState = initialState.getGameState(gameId);
  if (!currentGameState) return;

  // ارسال state به بازیکن جدید
  socket.emit("game_state_update", currentGameState);

  const newPlayer = currentGameState.players.find(
    (p) => p.telegram_id === telegramId,
  );
  if (newPlayer) {
    socket.to(gameId).emit("player_joined", newPlayer);
  }

  // اگر بازی کامل شد → شروع کن
  if (
    currentGameState.players.length === currentGameState.number_of_players &&
    currentGameState.game_status === "waitingForPlayer"
  ) {
    currentGameState.game_status = "start";

    // بررسی حالت بازی برای کم کردن سکه
    if (currentGameState.game_type === "global") {
      // 🚀 محاسبه کاملاً داینامیک هزینه کسر سکه بر اساس لول میز
      const coinCost = LEVEL_COSTS[currentGameState.game_level] || 0;

      if (coinCost > 0) {
        let playersTelegramId = [];

        // ۱. آپدیت سکه بازیکنان در حافظه سرور (State)
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

        // ۲. آپدیت هم‌زمان تمام بازیکنان در دیتابیس
        try {
          await reduceMultiplePlayersCoin(playersTelegramId, coinCost);
        } catch (dbError) {
          console.error("Error reducing coins from DB:", dbError);
        }

        const sockets = await io.in(gameId).fetchSockets();
        sockets.forEach((socket) => {
          socket.data.coin = socket.data.coin - coinCost;
        });
      }
    }

    // ۳. آپدیت وضعیت بازی در دیتابیس و استیت سرور
    await updateGameState(
      gameId,
      { game_status: "start" },
      currentGameState.game_type,
    );

    initialState.updateGameState(gameId, {
      game_status: "start",
    });

    // اطلاع‌رسانی شروع بازی به همه اعضای اتاق
    io.to(gameId).emit("game_started");

    startTimer(socket, io);
  }

  updateLobbyMessage(gameId);
}

async function addPlayerToGame(game, player, socket) {
  const players = game.players;

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
  };
  initialState.addPlayerToGameState(correctPlayer, game.game_id);
}

module.exports = { handleJoinGame, handleJoinGameFriendly };
