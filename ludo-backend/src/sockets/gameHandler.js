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
      // ۱. بررسی معتبر بودن حالت بازی
      if (gameMode !== 2 && gameMode !== 4) {
        console.log("Invalid gameMode:", gameMode);
        return socket.emit("error", "your game mode is incorrect");
      }

      console.log("Received initData:", initData);

      try {
        // ۲. تایید اصالت دیتای تلگرام (حتماً باید داخل try باشد چون در صورت خطا throw می‌کند)
        // بهتر است از ثابت BOT_TOKEN که اینپورت کردی استفاده کنی، اما توکن دستی شما را هم اینجا گذاشتم:
        validate(initData, "8780116886:AAEkCv3L3WVnHIhI7fvOPMmj1mSe2QWz9Ho");

        // ۳. پارس کردن اطلاعات کاربر
        const parsedData = parse(initData);
        const user = parsedData.user;

        if (!user || !user.id) {
          return socket.emit(
            "error",
            "User data not found in Telegram initData.",
          );
        }

        console.log(
          `User authorized successfully: ${user.firstName} (${user.id})`,
        );

        // ۴. ورود کاربر به لاجیک بازی و دیتابیس
        // توجه: به جای user.first_name از user.firstName استفاده شد
        let { game, player } = await handleAuth(
          socket.id,
          user.id,
          user.firstName,
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
