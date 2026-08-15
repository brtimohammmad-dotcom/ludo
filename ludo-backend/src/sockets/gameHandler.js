const {handleAuth} = require("../services/authService");
const {handleRequestGameState} = require("../services/requestGameState");
const {handleJoinGame} = require("../services/joinGameService");
const {handleClaimDailyReward} = require("../services/claim_daily_reward");
const {
    handleGetLeaderBoardList,
} = require("../services/get_leader_board_list");
const {
    handleRollDice,
    handleMoveToken,
    handleExitingGame,
} = require("../services/gameService");
const {handleSendingEmoji} = require("../services/sendEmojiService.js");
const {handleRedeemVpn} = require("../services/handle_redeem_vpn.js");

module.exports = (io) => {
    return async (socket) => {
        socket.on("get_fast_ping", () => {
            socket.emit("fast_ping_gets");
        });
        socket.on("auth", ({initData}) => {


            handleAuth(initData, socket);
        });

        socket.on("request_game_state", (data) => {
            handleRequestGameState(socket, data, io);
        });

        socket.on("claim_daily_reward", (data, callback) => {
            handleClaimDailyReward(socket, callback);
        });

        socket.on("join_game", (data, callback) => {
            if (!data) {
                return socket.emit("error", "Invalid data");
            }

            handleJoinGame(data, socket, io, callback);
        });

        socket.on("roll_dice", (data, callback) => {
            handleRollDice(socket, io, callback);
        });

        socket.on("move_token", (token, callback) => {
            handleMoveToken(socket, token, io, callback);
        });
        socket.on("redeem_vpn", (gb, callback) => {
            handleRedeemVpn(socket, gb, callback);
        });

        socket.on("exit_game", async (data, callback) => {
            if (!socket.data.gameId) {
                return socket.emit("error", "No game found!");
            }
            await handleExitingGame(socket, io, callback);
        });
        socket.on("get_leader_board_list", async (data, callback) => {
            await handleGetLeaderBoardList(socket, callback);
        });
        socket.on("send_emoji", (data) => {
            handleSendingEmoji(socket, data, io);
        });
        // رویداد disconnect
        socket.on("disconnect", (reason) => {
        });
    };
};
