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

        // بررسی اینکه آیا پلیر در بازی است
        let { game, newPlayer } = await hasExistGame(player, socket.id);

        // 🌟 نکتهٔ طلایی:
        // اگر newPlayer null بود، به‌جای خطا دادن، از player اصلی استفاده کن
        const finalPlayer = newPlayer || player;

        // ارسال پلیر به فرانت
        socket.emit("initial_player", finalPlayer);

        // اگر پلیر در بازی بود، gameId را ست کن
        if (game) {
          socket.data.gameId = game.game_id;
        }
      } catch (err) {
        console.error("Auth error:", err.message || err);
        socket.emit("initial_player", {
          error: "Player initialization failed",
        });
      }
    });

    socket.on("join_game", async ({ gameMode }) => {
      if (gameMode !== 2 && gameMode !== 4) {
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
      io.to(game.game_id).emit("game_state_update", currentGameState);

      // اگر بازی کامل شد → شروع کن
      if (
        currentGameState.players.length === gameMode &&
        currentGameState.game_status === "waitingForPlayer"
      ) {
        currentGameState.game_status = "start";

        await updateGameState(game.game_id, { game_status: "start" });
        initialState.updateGameState(game.game_id, { game_status: "start" });

        io.to(game.game_id).emit(
          "game_state_update",
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
      socket.leave();
      handleExitingGame(socket, io);
    });

    // رویداد disconnect
    socket.on("disconnect", (reason) => {
      console.log(`🚨 Socket disconnected: ${socket.id} | Reason: ${reason}`);
    });
  };
};
