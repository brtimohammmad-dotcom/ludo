const { updateLobbyMessage } = require("../../bot");
const initialState = require("../models/initialState");
const { updateGameState } = require("../database/games");
const { stopTimer } = require("../services/turnTimerService");
const { updateCoin } = require("../database/players");

async function finishGame(gameId, winnerPlayer, gameMode, io) {
  const winnerGameState = initialState.getGameState(gameId);
  if (!winnerGameState) return;
  
  initialState.updateGameState(gameId, {
    game_status: "finished",
    winner: winnerPlayer,
  });
  
  await updateLobbyMessage(gameId);
  await updateGameState(
    gameId,
    {
      game_status: "finished",
      winner: winnerPlayer,
      players: winnerGameState.players,
      end_at: new Date(),
    },
    gameMode,
  );
  if (gameMode === "global") {
    const addCoinValue = winnerGameState.number_of_players === 2 ? 180 : 300;
    try {
      await updateCoin(winnerPlayer.telegram_id, "add", addCoinValue);
      const allSockets = await io.in(gameId).fetchSockets();
      const targetSocket = allSockets.find(
        (s) => s.data.telegramId === winnerPlayer.telegram_id,
      );
      targetSocket.data.coin = targetSocket.data.coin + addCoinValue;
    } catch {
      console.log("error in increase winner coin");
    }
  }
  stopTimer(gameId);
  io.to(gameId).emit("game_finished", winnerPlayer);
  initialState.deleteGameState(gameId);
}
module.exports = { finishGame };
