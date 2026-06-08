const { handleAuth, hasExistGame } = require("../services/authService");
const { handleJoinGame } = require("../services/joinGameService");
const {
  handleRollDice,
  handleMoveToken,
  handleExitingGame,
} = require("../services/gameService");
const initialState = require("../models/initialState");
const { updateGameState, getGameState } = require("../database/games");
const { startTimer } = require("../services/turnTimerService");
const { validate, parse } = require("@tma.js/init-data-node");
const { BOT_TOKEN } = require("../constants/gameConfig");
const isLocal = process.env.RENDER !== "true";
let idCounter = 0;

module.exports = (io) => {
  return async (socket) => {
    console.log("Recovered:", socket.recovered);
    if (socket.recovered) {
      console.log("gameId:", socket.data.gameId);
      console.log("user id:", socket.data.telegramId);
      let currentGame = initialState.getGameState(socket.data.gameId);
      if (!socket.data.gameId) {
        console.log("no game id ");
      } else if (!currentGame) {
        const currentGameInDataBase = await getGameState(socket.data.gameId);
        if (!currentGameInDataBase) {
          console.log("no game found ");
        } else {
          socket.emit("game_finished", currentGameInDataBase.winner);
        }
      } else {
        const updatedPlayers = currentGame.players.map((p) => {
          if (p.telegram_id === socket.data.telegramId) {
            return { ...p, telegram_id: socket.data.telegramId };
          } else {
            return p;
          }
        });
        initialState.updateGameState(currentGame.game_id, {
          players: updatedPlayers,
        });
        currentGame = initialState.getGameState(currentGame.game_id);
        socket.emit("game_state_update", currentGame);
      }
    }

    socket.on("auth", async ({ initData }) => {
      console.log("...authorize...");

      console.log("Received initData:", initData);

      try {
        let user;
        if (!isLocal) {
          validate(initData, "process.env.BOT_TOKEN");

          const parsedData = parse(initData);
          user = parsedData.user;

          if (!user || !user.id) {
            return socket.emit(
              "error",
              "User data not found in Telegram initData.",
            );
          }
        } else {
          idCounter++;
          user = {
            id: idCounter,
            first_name: "amir",
          };
        }

        console.log(
          `User authorized successfully: ${user.first_name} (${user.id})`,
        );
        let { player } = await handleAuth(user.id, user.first_name);
        let { game, newPlayer } = await hasExistGame(player, socket.id);
        socket.data.telegramId = player.telegram_id;
        socket.data.firstName = player.username;

        if (game) {
          if (!newPlayer) {
            console.log("Player not found or database lag!");
            // حتماً یک خطای مشخص بفرست یا به جای null، یک وضعیت خطا برگردان
            return socket.emit("initial_player", {
              error: "Player initialization failed",
            });
          }
          socket.emit("initial_player", newPlayer);

          socket.data.gameId = game.game_id;
          let currentGameState = initialState.getGameState(socket.data.gameId);
          socket.join(socket.data.gameId);

          io.to(socket.data.gameId).emit("game_state_update", currentGameState);
        } else {
          if (!player) {
            console.log("Player not found or database lag!");
            // حتماً یک خطای مشخص بفرست یا به جای null، یک وضعیت خطا برگردان
            return socket.emit("initial_player", {
              error: "Player initialization failed",
            });
          }
          console.log(player);
          socket.emit("initial_player", player);
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
    socket.on("join_game", async ({ gameMode }) => {
      // ۱. بررسی معتبر بودن حالت بازی
      if (gameMode !== 2 && gameMode !== 4) {
        console.log("Invalid gameMode:", gameMode);
        return socket.emit("error", "your game mode is incorrect");
      }
      const { game } = await handleJoinGame(gameMode, socket);
      socket.data.gameId = game.game_id;
      let currentGameState = initialState.getGameState(socket.data.gameId);

      socket.join(socket.data.gameId);

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
        startTimer(socket, io);
      }
    });
    socket.on("roll_dice", () => {
      if (!socket.data.gameId) {
        return socket.emit("error", "No game found!");
      }
      handleRollDice(socket, io);
    });

    socket.on("move_token", (token) => {
      if (!socket.data.gameId) {
        return socket.emit("error", "No game found!");
      }
      handleMoveToken(socket, token, io);
    });

    socket.on("exit_game", () => {
      if (!socket.data.gameId) {
        return socket.emit("error", "No game found!");
      }
      socket.leave();
      handleExitingGame(socket, io);
    });

    // رویداد disconnect
    socket.on("disconnect", () => {
      console.log(`Socket disconnected: ${socket.id}`);
    });
  };
};
