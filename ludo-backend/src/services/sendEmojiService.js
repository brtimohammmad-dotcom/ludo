function handleSendingEmoji(socket, emoji, io) {
  if (!socket) return;
  const emojis = ["laugh", "angry", "cry", "cool", "shocked", "thumbs_up"];
  if (emojis.some((e) => emoji)) {

    io.emit("emoji_received", { emoji, playerColor: socket.data.color });
  } else {
    Socket.emit("error", "incorrect emoji");
  }
}
module.exports = { handleSendingEmoji };
