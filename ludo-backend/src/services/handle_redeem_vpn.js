const {redeemCoinsForVpn} = require("./vpnService")
const {sendError} = require("../helpers/game_helpers")
const {updateCoin} = require("../database/players")
const {VPN_PRICE} = require("../constants/gameConfig")
const initialState = require("../models/initialState")

async function handleRedeemVpn(socket, gb, callback) {
    const coinCost = VPN_PRICE[gb];
    if (socket.data.coin < coinCost) {
        sendError(socket, callback, "you haven't enough coins");
        return;
    }
    if (socket.data.gameId) {
        const currentGame = initialState.getGameState(socket.data.gameId)
        if (currentGame) {
            sendError(socket, callback, "You are in game and can't redeem VPN");
            return;
        }

    }
    const telegramId = socket.data.telegramId;
    if (!telegramId) {
        sendError(socket, callback, "No telegram ID!");
        return ;
    }
    if (typeof callback === "function") {
        callback({success: true});
    }

    const vpnData = await redeemCoinsForVpn(socket, gb);
    if (vpnData.success) {
        await updateCoin(telegramId, "subtract", coinCost
        )
        socket.data.coin = socket.data.coin - coinCost;
    }
    socket.emit("vpn_redeemed", vpnData);
}

module.exports = {handleRedeemVpn};