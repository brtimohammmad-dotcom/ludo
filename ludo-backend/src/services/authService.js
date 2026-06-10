const { getOrCreatePlayer } = require("../database/players");

const initialState = require("../models/initialState");
async function handleAuth(telegramId, username) {
  let player = await getOrCreatePlayer(telegramId, username);
  if (!player) {
    console.log("Player not found or database lag!");
    // حتماً یک خطای مشخص بفرست یا به جای null، یک وضعیت خطا برگردان
    return socket.emit("initial_player", {
      error: "Player initialization failed",
    });
  }
  return { player: player };
}
async function hasExistGame(player, socketId) {
  const existingGame = initialState.findPlayerGame(player.telegram_id);

  if (existingGame) {
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
