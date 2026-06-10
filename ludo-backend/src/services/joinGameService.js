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
  if (!(gameMode === 2 || gameMode === 4)) {
    socket.emit("error", "game mode incorrect");
    return;
  }
  return await joinGameQueue(gameMode, async () => {
    const player = {
      username: socket.data.firstName,
      telegram_id: socket.data.telegramId,
    };
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
    const playerIsInGame = players.some(
      (p) => p.telegram_id === socket.data.telegramId,
    );
    if (playerIsInGame) {
      const correctPlayers = game.players.map((p) => {
        if (p.telegram_id === socket.data.telegramId) {
          return { ...p, player_status: "online" };
        } else {
          return p;
        }
      });
      initialState.updateGameState(socket.data.gameId, {
        players: correctPlayers,
      });
      game = initialState.getGameState(game.game_id);
      return {
        game: game,
      };
    }
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
    game = initialState.getGameState(game.game_id);

    return {
      game: game,
    };
  });
}
module.exports = { handleJoinGame };
