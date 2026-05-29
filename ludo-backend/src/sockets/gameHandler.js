const { handleAuth } = require("../services/authService");
const {
  handleRollDice,
  handleMoveToken,
  handleExitingGame,
} = require("../services/gameService");
const initialState = require("../models/initialState");
const { updateGameState } = require("../database/games");
const { startTimer } = require("../services/turnTimerService");
const { validate, parse } = require("@tma.js/init-data-node");
const { BOT_TOKEN } = require("../constants/gameConfig");
module.exports = (io) => {
  return (socket) => {
    let currentGameId = null;

    socket.on("auth", async ({ initData, gameMode }) => {
      if (gameMode !== 2 && gameMode !== 4) {
        console.log(gameMode);
        socket.emit("error", "your game mode is incorrect");
      }
      const isValid=validate(initData, "8780116886:AAEkCv3L3WVnHIhI7fvOPMmj1mSe2QWz9Ho");
      if (!isValid) {
        return socket.emit(
          "error",
          "Authentication failed. Invalid Telegram data.",
        );
      }
      const user = parse(initData).user; // گرفتن اطلاعات معت
      if (!user || !user.id) {
        return socket.emit(
          "error",
          "User data not found in Telegram initData.",
        );
      }
      try {
        let { game, player } = await handleAuth(
          socket.id,
          user.id,
          user.first_name,
          gameMode,
        );

        currentGameId = game.game_id;

        // بررسی وجود بازی در حافظه سراسری

        let currentGameState = initialState.getGameState(currentGameId);
        socket.join(currentGameId);
        socket.emit("initial_player", player);
        io.to(currentGameId).emit("game_state_update", currentGameState);

        // بررسی شروع بازی
        if (
          currentGameState.players.length === gameMode &&
          currentGameState.game_status === "waitingForPlayer"
        ) {
          currentGameState.game_status = "start";
          await updateGameState(currentGameId, { game_status: "start" });
          initialState.updateGameState(currentGameId, { game_status: "start" });
          io.to(currentGameId).emit(
            "game_started",
            initialState.getGameState(currentGameId),
          );
          startTimer(currentGameId, io);
        }
      } catch (err) {
        console.error("Auth error:", err);
        socket.emit("auth_error", { message: "Database error" });
      }
    });

    // رویدادهای هم سطح
    socket.on("roll_dice", () => {
      if (!currentGameId) {
        return socket.emit("error", "No game found!");
      }
      handleRollDice(currentGameId, socket, io);
    });

    socket.on("move_token", (token) => {
      if (!currentGameId) {
        return socket.emit("error", "No game found!");
      }
      handleMoveToken(currentGameId, socket.id, token, io);
    });
    socket.on("exit_game", (telegramId) => {
      if (!currentGameId) {
        return socket.emit("error", "No game found!");
      }
      handleExitingGame(currentGameId, telegramId, io);
    });

    // رویداد disconnect
    socket.on("disconnect", () => {
      console.log(`Socket disconnected: ${socket.id}`);
    });
  };
};
