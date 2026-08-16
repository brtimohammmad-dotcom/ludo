const {redeemCoinsForVpn} = require("./vpnService")
const {sendError} = require("../helpers/game_helpers")
const {updatePlayerFullInfo} = require("../database/players")

async function handleClaimWelcomeGift(socket, callback) {
    if (socket.data.welcomeGift) {
        sendError(socket, callback, "welcomeGift already claimed");
        return;
    }
    if (!socket) {
        sendError(socket, callback, "socket not found");
        return;
    }
    callback({success: true});
    socket.data.welcomeGift = true;
    await updatePlayerFullInfo(socket.data.telegramId, {welcome_gift: true})
    const vpnData = await redeemCoinsForVpn(socket, 1)
    socket.emit("welcome_gift_claimed", vpnData);

}

module.exports = {handleClaimWelcomeGift}