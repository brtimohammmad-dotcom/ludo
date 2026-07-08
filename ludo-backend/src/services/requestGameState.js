const { hasExistGame } = require("./authService");

async function handleRequestGameState(socket, data) {
  if (!data) {
    console.error("No data received for request_game_state");
    return;
  }
  const { gameMode, gameId } = data;

  if (!socket.data.telegramId) {
    socket.emit("player_not_authorized");
    return;
  }
  console.log(`Received gameMode: ${gameMode}, gameId: ${gameId}`);

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
    if (gameMode && gameId && gameMode === "friendly") {
      socket.data.gameId = gameId;
    }
    if (!socket.data.gameId) {
      socket.emit("not_in_game");
      return;
    }
    // 3) اگر بازی در دیتابیس وجود دارد ولی در حافظه نیست
    const dbGame = await getGameState(socket.data.gameId, gameMode);
    if (!dbGame) {
      socket.emit("not_in_game");
      return;
    }

    if (dbGame.winner) {
      console.log("has winner");
      socket.emit("game_finished", dbGame.winner);
      return;
    }
    if (gameMode && gameId && gameMode === "friendly") {
      await handleJoinGameFriendly(socket, io);
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
}
module.exports = { handleRequestGameState };
