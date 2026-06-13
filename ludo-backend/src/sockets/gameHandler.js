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
    socket.on("get_fast_ping", () => {
      socket.emit("fast_ping_gets");
    });
    socket.on("auth", async ({ initData }) => {
      console.log("...authorize...");
      console.log("Received initData:", initData);

      try {
        let user;

        if (!isLocal) {
          validate(initData, process.env.BOT_TOKEN);
          const parsedData = parse(initData);
          user = parsedData.user;

          if (!user || !user.id) {
            return socket.emit("initial_player", {
              error: "Invalid Telegram initData",
            });
          }
        } else {
          idCounter++;
          // user = { id: idCounter, first_name: "amir" };
          user = initData;
        }

        console.log(
          `User authorized successfully: ${user.first_name} (${user.id})`,
        );

        // دریافت یا ساخت پلیر
        let { player } = await handleAuth(user.id, user.first_name);

        // اگر پلیر وجود دارد، سوکت جدید را جایگزین کن
        socket.data.telegramId = player.telegram_id;
        socket.data.firstName = player.username;

        // ارسال پلیر به فرانت
        socket.emit("initial_player", player);
      } catch (err) {
        console.error("Auth error:", err.message || err);
        socket.emit("initial_player", {
          error: "Player initialization failed",
        });
      }
    });

    socket.on("request_game_state", async () => {
      if (!socket.data.telegramId) {
        socket.emit("player_not_authorized");
        return;
      }
      const player = {
        telegram_id: socket.data.telegramId,
        username: socket.data.firstName,
      };

      // 1) بررسی اینکه آیا بازیکن در بازی‌ای وجود دارد یا نه
      const result = await hasExistGame(player, socket.id);

      const existingGame = result.game;
      const currentPlayer = result.player;

      // 2) اگر بازیکن در هیچ بازی‌ای نیست
      if (!existingGame) {
        if (!socket.data.gameId) {
          return;
        }
        // 3) اگر بازی در دیتابیس وجود دارد ولی در حافظه نیست
        const dbGame = await getGameState(currentPlayer.game_id);
        if (!dbGame) {
          socket.emit("not_in_game");
          return;
        }

        if (dbGame.winner) {
          socket.emit("game_finished", dbGame.winner);
          return;
        }
        return;
      }

      // 4) اگر بازی تمام شده باشد
      if (existingGame.winner) {
        socket.emit("game_finished", existingGame.winner);
        return;
      }
      console.log("game recoverd");
      socket.join(existingGame.game_id);
      socket.data.gameId = existingGame.game_id;

      // 5) ارسال state کامل بازی
      socket.emit("game_recovered", existingGame);
    });

    socket.on("join_game", async ({ gameMode }) => {
      if (
        gameMode !== 2 &&
        gameMode !== 4 &&
        gameMode !== -2 &&
        gameMode !== -4
      ) {
        return socket.emit("error", "Invalid game mode");
      }

      // بازیکن را وارد بازی کن
      const { game } = await handleJoinGame(gameMode, socket);

      socket.data.gameId = game.game_id;

      // سوکت را وارد روم کن
      socket.join(game.game_id);

      // state فعلی بازی را بگیر
      let currentGameState = initialState.getGameState(game.game_id);

      // ارسال state به همه
      socket.emit("game_state_update", currentGameState);
      socket.to(socket.data.gameId).emit("player_joined", currentGameState);

      // اگر بازی کامل شد → شروع کن
      if (
        currentGameState.players.length === gameMode &&
        currentGameState.game_status === "waitingForPlayer"
      ) {
        currentGameState.game_status = "start";

        await updateGameState(game.game_id, { game_status: "start" });
        initialState.updateGameState(game.game_id, { game_status: "start" });

        io.to(game.game_id).emit(
          "game_started",
          initialState.getGameState(game.game_id),
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
      handleExitingGame(socket, io);
    });

    // رویداد disconnect
    socket.on("disconnect", (reason) => {
      console.log(`🚨 Socket disconnected: ${socket.id} | Reason: ${reason}`);
    });
  };
};
