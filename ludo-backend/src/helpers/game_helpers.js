const {updateLobbyMessage} = require("../../bot");
const initialState = require("../models/initialState");
const {updateGameState} = require("../database/games");
const {stopTimer} = require("../services/turnTimerService");
const {updateCoin} = require("../database/players");
const {WIN_AMOUNT} = require("../constants/gameConfig");

async function finishGame(gameId, winnerPlayer, gameType, io) {
    const winnerGameState = initialState.getGameState(gameId);
    if (!winnerGameState) return;

    initialState.updateGameState(gameId, {
        game_status: "finished",
        winner: winnerPlayer,
    });

     updateLobbyMessage(gameId);
     console.log("winnerPlayer:")
     console.log(winnerPlayer.telegram_id)
     updateGameState(
        gameId,
        {
            game_status: "finished",
            winner: winnerPlayer.telegram_id,
            end_at: new Date().toISOString(),
        },
    );

    if (gameType === "global") {
        const finishedGame = initialState.getGameState(gameId);
        const addCoinValue =
            WIN_AMOUNT[finishedGame.game_level][finishedGame.number_of_players];
        try {
            await updateCoin(winnerPlayer.telegram_id, "add", addCoinValue);
            const allSockets = await io.in(gameId).fetchSockets();
            const targetSocket = allSockets.find(
                (s) => s.data.telegramId === winnerPlayer.telegram_id,
            );
            if (targetSocket) {
                targetSocket.data.coin = (targetSocket.data.coin || 0) + addCoinValue;
            }
        } catch {
            console.log("error in increase winner coin");
        }
    }

    stopTimer(gameId);
    io.to(gameId).emit("game_finished", winnerPlayer);
    initialState.deleteGameState(gameId);
}

// 🎯 تابع اصلاح‌شده ارسال خطا
const sendError = (socket, callback, message) => {
    if (typeof callback === "function") {
        callback({success: true});
    }
    socket.emit("error", {message});
};

function validateGameAndPlayer(socket, callback) {
    const gameId = socket.data?.gameId;
    const telegramId = socket.data?.telegramId;

    if (!gameId) {
        sendError(socket, callback, "No game found!");
        return {isValid: false};
    }

    const gameState = initialState.getGameState(gameId);
    if (!gameState) {
        sendError(socket, callback, "Game not found!");
        return {isValid: false};
    }

    if (gameState.game_status !== "start") {
        sendError(socket, callback, "The game hasn't started yet!");
        return {isValid: false};
    }

    const player = gameState.players.find((p) => p.telegram_id === telegramId);
    if (!player) {
        sendError(socket, callback, "Player not found!");
        return {isValid: false};
    }

    return {isValid: true, gameState, player};
}

module.exports = {finishGame, sendError, validateGameAndPlayer};
