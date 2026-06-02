const { getOrCreatePlayer } = require("../database/players");
const { createNewGameInDatabase } = require("../database/games");
const { addPlayerToGameOnDatabase } = require("../database/gamePlayers");
const {
  TOW_PLAYER_COLORS,
  FOUR_PLAYER_COLORS,
} = require("../constants/gameConfig");
const initialState = require("../models/initialState");
const { Socket } = require("socket.io");
const { authQueue } = require("./authQueue.js");
async function handleAuth(socketId, telegramId, username, gameMode) {
  return authQueue(gameMode , async()=>{
      let player = await getOrCreatePlayer(telegramId, username);

      const existingGame = initialState.findPlayerGame(player.telegram_id);
      if (existingGame) {
        const currentPlayer = initialState.findPlayerInfoInGame(
          existingGame.game_id,
          player.telegram_id,
        );
        if (currentPlayer.player_status === "online") {
          currentPlayer.socketId = socketId;
          const correctPlayers = existingGame.players.map((p) => {
            if (p.telegram_id === currentPlayer.telegram_id) {
              return { ...p, socketId: socketId }; // بازگرداندن آبجکت جدید
            }
            return p; // بازگرداندن آبجکت بدون تغییر
          });
          initialState.updateGameState(existingGame.game_id, {
            players: correctPlayers,
          });
          const correctGameState = initialState.getGameState(
            existingGame.game_id,
          );
          return {
            game: correctGameState,
            player: currentPlayer,
          };
        }
      } else {
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
        const color =
          gameMode === 2
            ? TOW_PLAYER_COLORS[players.length]
            : FOUR_PLAYER_COLORS[players.length];
        const playerInDataBase = await addPlayerToGameOnDatabase(
          player,
          game.game_id,
          color,
        );
        const correctPlayer = {
          ...playerInDataBase,
          color: color,
          socketId: socketId,
          player_status: "online",
          numberOfAbsences: 0,
          connection_status: "connected",
        };
        initialState.addPlayerToGameState(correctPlayer, game.game_id);

        return { game, player: correctPlayer };
      }
  });

}

module.exports = { handleAuth };
