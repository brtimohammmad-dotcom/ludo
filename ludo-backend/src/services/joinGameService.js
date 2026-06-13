const { joinGameQueue } = require("./joinGameQueue.js");
const initialState = require("../models/initialState");
const { createNewGameInDatabase } = require("../database/games");
const {
  TOW_PLAYER_COLORS,
  FOUR_PLAYER_COLORS,
} = require("../constants/gameConfig");
const { addPlayerToGameOnDatabase } = require("../database/gamePlayers");

async function handleJoinGame(gameMode, socket) {
  console.log("player id: ", socket.data.telegramId, " joined");
  console.log("player name: ", socket.data.firstName, "joined");
  console.log("game mode is: ", gameMode);

  return await joinGameQueue(gameMode, async () => {
    const player = {
      username: socket.data.firstName,
      telegram_id: socket.data.telegramId,
    };

    // ----------------------------------------------------
    // بخش بازی‌های عمومی (مقادیر مثبت ۲ و ۴)
    // ----------------------------------------------------
    if (gameMode === 2 || gameMode === 4) {
      let game = initialState
        .getAllGames()
        .find(
          (g) =>
            g.game_status === "waitingForPlayer" && g.game_mode === gameMode,
        );
      if (!game) {
        game = await createNewGameInDatabase(gameMode);
        game = initialState.createGameInGameState(game.game_id, gameMode);
      }
      const players = initialState.getGameState(game.game_id).players;
      const playerIsInGame = players.some((p) => p.telegram_id === socket.data.telegramId);

      if (playerIsInGame) {
        const correctPlayers = game.players.map((p) => {
          if (p.telegram_id === socket.data.telegramId) {
            return { ...p, player_status: "online" };
          } else {
            return p;
          }
        });
        initialState.updateGameState(game.game_id, { players: correctPlayers });
        game = initialState.getGameState(game.game_id);
        return { game: game };
      } else {
        const color = gameMode === 2
            ? TOW_PLAYER_COLORS[players.length]
            : FOUR_PLAYER_COLORS[players.length];

        const playerInDataBase = await addPlayerToGameOnDatabase(player, game.game_id, color);
        const correctPlayer = {
          ...playerInDataBase,
          color: color,
          player_status: "online",
          numberOfAbsences: 0,
          connection_status: "connected",
        };
        initialState.addPlayerToGameState(correctPlayer, game.game_id);
        game = initialState.getGameState(game.game_id);

        return { game: game };
      }
    }

    // ----------------------------------------------------
    // بخش بازی‌های دوستانه (مقادیر منفی ۲- و ۴-)
    // ----------------------------------------------------
    if (gameMode === -2 || gameMode === -4) {
      // ۱. ساخت بازی در دیتابیس
      let game = await createNewGameInDatabase(gameMode);
      
      // ۲. ایجاد وضعیت بازی در حافظه (initialState)
      game = initialState.createGameInGameState(game.game_id, gameMode);

      // ۳. تعیین رنگ اولین بازیکن (سازنده بازی همیشه ایندکس ۰ است)
      const color = gameMode === -2 ? TOW_PLAYER_COLORS[0] : FOUR_PLAYER_COLORS[0];

      // ۴. اضافه کردن سازنده بازی به دیتابیس بازی
      const playerInDataBase = await addPlayerToGameOnDatabase(player, game.game_id, color);

      // ۵. اضافه کردن سازنده بازی به وضعیت حافظه
      const correctPlayer = {
        ...playerInDataBase,
        color: color,
        player_status: "online",
        numberOfAbsences: 0,
        connection_status: "connected",
      };
      initialState.addPlayerToGameState(correctPlayer, game.game_id);
      game = initialState.getGameState(game.game_id);

      // ۶. تولید لینک دعوت عمیق (Deep Linking) برای ربات تلگرام
      const botUsername = "YourBotUsername"; // ⚠️ آیدی ربات خود را بدون @ اینجا بنویسید
      const invitationLink = `https://t.me/${botUsername}?start=game_${game.game_id}`;

      // ۷. بازگرداندن اطلاعات بازی همراه با لینک دعوت به مینی‌اپ (سوکت)
      return {
        game: game,
        invitationLink: invitationLink
      };
    }
  });
}

module.exports = { handleJoinGame };