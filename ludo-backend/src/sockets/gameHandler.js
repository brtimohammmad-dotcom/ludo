const { handleAuth } = require("../services/authService");
const { handleRequestGameState } = require("../services/requestGameState");
const { handleJoinGame } = require("../services/joinGameService");
const { handleClaimDailyReward } = require("../services/claim_daily_reward");
const {
  handleGetLeaderBoardList,
} = require("../services/get_leader_board_list");
const {
  handleRollDice,
  handleMoveToken,
  handleExitingGame,
} = require("../services/gameService");

module.exports = (io) => {
  return async (socket) => {
    socket.on("get_fast_ping", () => {
      socket.emit("fast_ping_gets");
    });
    socket.on("auth", async ({ initData }) => {
      console.log("...authorize...");
      console.log("Received initData:", initData);

      await handleAuth(initData, socket);
    });

    socket.on("request_game_state", async (data) => {
      await handleRequestGameState(socket, data, io);
    });

    socket.on("claim_daily_reward", async (data) => {
      await handleClaimDailyReward(socket);
    });

    socket.on("join_game", async ({ numberOfPlayers }) => {
      if (
        numberOfPlayers !== 2 &&
        numberOfPlayers !== 4 &&
        numberOfPlayers !== -2 &&
        numberOfPlayers !== -4
      ) {
        return socket.emit("error", "Invalid game mode");
      }

      // بازیکن را وارد بازی کن
      await handleJoinGame(numberOfPlayers, socket, io);
    });

    socket.on("roll_dice", async () => {
      if (!socket.data.gameId) {
        return socket.emit("error", "No game found!");
      }
     await handleRollDice(socket, io);
    });

    socket.on("move_token", async (token) => {
      if (!socket.data.gameId) {
        return socket.emit("error", "No game found!");
      }
      await handleMoveToken(socket, token, io);
    });

    socket.on("exit_game", async () => {
      if (!socket.data.gameId) {
        return socket.emit("error", "No game found!");
      }
      await handleExitingGame(socket, io);
    });
    socket.on("get_leader_board_list", async () => {
      await handleGetLeaderBoardList(socket);
    });
    // رویداد disconnect
    socket.on("disconnect", (reason) => {
      console.log(`🚨 Socket disconnected: ${socket.id} | Reason: ${reason}`);
    });
  };
};
