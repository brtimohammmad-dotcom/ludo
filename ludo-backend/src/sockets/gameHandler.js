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
    if (socket.recovered){
      console.log(socket.recovered)
    }
      socket.on("auth", async ({ initData, gameMode }) => {
        // ۱. بررسی معتبر بودن حالت بازی
        if (gameMode !== 2 && gameMode !== 4) {
          console.log("Invalid gameMode:", gameMode);
          return socket.emit("error", "your game mode is incorrect");
        }

        console.log("Received initData:", initData);

        try {
          validate(initData, "8780116886:AAEkCv3L3WVnHIhI7fvOPMmj1mSe2QWz9Ho");

          const parsedData = parse(initData);
          const user = parsedData.user;

          if (!user || !user.id) {
            return socket.emit(
              "error",
              "User data not found in Telegram initData.",
            );
          }

          console.log(
            `User authorized successfully: ${user.first_name} (${user.id})`,
          );
          let { game, player } = await handleAuth(
            socket.id,
            user.id,
            user.first_name,
            gameMode,
          );

          socket.data.gameId = game.game_id;
          socket.data.telegramId = player.telegram_id;

          // بررسی وجود بازی در حافظه سراسری
          let currentGameState = initialState.getGameState(socket.data.gameId);
          socket.join(socket.data.gameId);
          socket.emit("initial_player", player);
          io.to(socket.data.gameId).emit("game_state_update", currentGameState);

          // بررسی شروع بازی
          if (
            currentGameState.players.length === gameMode &&
            currentGameState.game_status === "waitingForPlayer"
          ) {
            currentGameState.game_status = "start";
            await updateGameState(socket.data.gameId, { game_status: "start" });
            initialState.updateGameState(socket.data.gameId, {
              game_status: "start",
            });
            io.to(socket.data.gameId).emit(
              "game_started",
              initialState.getGameState(socket.data.gameId),
            );
            startTimer(socket.data.gameId, io);
          }
        } catch (err) {
          // اگر تایید هویت تلگرام شکست بخورد یا خطای دیتابیس رخ دهد، کد به اینجا می‌رسد
          console.error("Auth error:", err.message || err);
          socket.emit(
            "error",
            "Authentication failed. Invalid Telegram data or Database error.",
          );
        }
      });

    // رویدادهای هم سطح
    socket.on("roll_dice", () => {
      if (!socket.data.gameId) {
        return socket.emit("error", "No game found!");
      }
      handleRollDice(socket.data.gameId, socket, io);
    });

    socket.on("move_token", (token) => {
      if (!socket.data.gameId) {
        return socket.emit("error", "No game found!");
      }
      handleMoveToken(socket.data.gameId, socket.id, token, io);
    });

    socket.on("exit_game", (telegramId) => {
      if (!socket.data.gameId) {
        return socket.emit("error", "No game found!");
      }
      handleExitingGame(socket.data.gameId, telegramId, io);
    });

    // رویداد disconnect
    socket.on("disconnect", () => {
      console.log(`Socket disconnected: ${socket.id}`);
    });
  };
};
