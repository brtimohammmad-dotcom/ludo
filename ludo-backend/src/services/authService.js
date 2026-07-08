const { getOrCreatePlayer } = require("../database/players");

const initialState = require("../models/initialState");


async function handleAuth(initData, socket) {
  const isLocal = process.env.RENDER !== "true";

  try {
    let user;

    if (!isLocal) {
      const { validate, parse } = require("@tma.js/init-data-node");
      validate(initData, process.env.BOT_TOKEN);
      const parsedData = parse(initData);
      user = parsedData.user;

      if (!user || !user.id) {
        return socket.emit("initial_player", {
          error: "Invalid Telegram initData",
        });
      }
    } else {
      user = initData;
    }
    console.log(
      `User authorized successfully: ${user.first_name} (${user.id})`,
    );
    socket.emit("initial_player", {
      error: "Player initialization failed",
    });
    let player = await getOrCreatePlayer(user.id, user.first_name);
    if (!player) {
      console.log("Player not found or database lag!");
      // حتماً یک خطای مشخص بفرست یا به جای null، یک وضعیت خطا برگردان
      return socket.emit("initial_player", {
        error: "Player initialization failed",
      });
    }

    // اگر پلیر وجود دارد، سوکت جدید را جایگزین کن
    socket.data.telegramId = player.telegram_id;
    socket.data.firstName = player.username;
    socket.data.coin = player.coin;

    // ارسال پلیر به فرانت
    socket.emit("initial_player", player);
  } catch (err) {
    console.error("Auth error:", err.message || err);
  }
}
async function hasExistGame(player, socketId) {
  const existingGame = initialState.findPlayerGame(player.telegram_id);

  if (existingGame) {
    console.log(existingGame.players);
    const currentPlayer = initialState.findPlayerInfoInGame(
      existingGame.game_id,
      player.telegram_id,
    );
    if (currentPlayer && currentPlayer.player_status === "online") {
      currentPlayer.socketId = socketId;
      currentPlayer.connection_status = "connected";

      const correctPlayers = existingGame.players.map((p) => {
        if (p.telegram_id === currentPlayer.telegram_id) {
          return { ...currentPlayer }; // بازگرداندن آبجکت جدید
        }
        return p; // بازگرداندن آبجکت بدون تغییر
      });
      initialState.updateGameState(existingGame.game_id, {
        players: correctPlayers,
      });
      const correctGameState = initialState.getGameState(existingGame.game_id);
      return {
        game: correctGameState,
        player: currentPlayer,
      };
    } else {
      return {
        game: null,
        player: player,
      };
    }
  } else {
    return {
      game: null,
      player: player,
    };
  }
}
module.exports = { handleAuth, hasExistGame };
