const { joinGameQueue } = require("./joinGameQueue.js");
const initialState = require("../models/initialState");
const { createNewGameInDatabase } = require("../database/games");
const {
  TOW_PLAYER_COLORS,
  FOUR_PLAYER_COLORS,
} = require("../constants/gameConfig");
const { addPlayerToGameOnDatabase } = require("../database/gamePlayers");

async function handleJoinGame(gameMode, socket) {
  return await joinGameQueue(gameMode, async () => {
    const player ={
        username:socket.data.firstName,
        telegram_id:socket.data.telegramId
    }
    let game = initialState
      .getAllGames()
      .find(
        (g) => g.game_status === "waitingForPlayer" && g.game_mode === gameMode,
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
      player_status: "online",
      numberOfAbsences: 0,
      connection_status: "connected",
    };
    initialState.addPlayerToGameState(correctPlayer, game.game_id);
    return {
      game: game,
    };
  });
}
module.exports = { handleJoinGame };
