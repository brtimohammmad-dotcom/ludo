const { hasExistGame } = require("./authService");
const { handleJoinGameFriendly } = require("./joinGameService");
const { getGameState } = require("../database/games");

async function handleRequestGameState(socket, data, io) {
  if (!data) {
    console.error("No data received for request_game_state");
    return;
  }
  // 🚀 هماهنگ‌سازی با متغیرهای جدید: استفاده از gameType به جای gameMode
  const { gameType, gameId } = data;

  if (!socket.data.telegramId) {
    socket.emit("player_not_authorized");
    return;
  }

  const player = {
    telegram_id: socket.data.telegramId,
    username: socket.data.firstName,
  };

  // ۱) بررسی اینکه آیا بازیکن در بازی‌ای از قبل وجود دارد یا نه
  const result = await hasExistGame(player, socket.id);
  const existingGame = result.game;
  const currentPlayer = result.player;

  // ۲) اگر بازیکن در حال حاضر در هیچ بازیِ زنده‌ای (در استیت سرور) نیست
  if (!existingGame) {
    // اگر درخواست ورود به یک بازی دوستانه از طریق لینک یا آیدی است
    if (gameType && gameId && gameType === "friendly") {
      socket.data.gameId = gameId;
    }

    if (!socket.data.gameId) {
      socket.emit("not_in_game");
      return;
    }

    // ۳) بررسی وضعیت بازی از روی دیتابیس (اگر سرور ریست شده یا بازی در حافظه پاک شده)
    const dbGame = await getGameState(socket.data.gameId, gameType);
    if (!dbGame) {
      socket.emit("not_in_game");
      return;
    }

    // اگر بازی قبلاً برنده داشته و تمام شده
    if (dbGame.winner) {
      socket.emit("game_finished", dbGame.winner);
      return;
    }

    // اگر بازیستانه بود و هنوز پر نشده، بازیکن را به روم دوستانه جوین کن
    if (gameType && gameId && gameType === "friendly") {
      await handleJoinGameFriendly(socket, io);
      return;
    }
    return;
  }

  // ۴) اگر بازیکن در یک بازی هست، اما می‌خواهد وارد یک بازی دوستانه دیگر شود!
  if (gameType === "friendly" && gameId !== existingGame.game_id) {
    socket.emit("in_another_game");
  }

  // ۵) اگر بازی موجود تمام شده باشد
  if (existingGame.winner) {
    socket.emit("game_finished", existingGame.winner);
    return;
  }

  // ۶) 🚀 ریکاوری موفق بازی (Game Recovered)
  socket.join(existingGame.game_id);
  socket.data.gameId = existingGame.game_id;

  // پیدا کردن رنگ بازیکن در استیت بازی
  const matchedPlayer = existingGame.players.find(
    (p) => p.telegram_id === currentPlayer.telegram_id,
  );

  if (matchedPlayer) {
    socket.data.color = matchedPlayer.color;
  }

  // ارسال وضعیت کامل بازی به فرانت‌اند جهت بازسازی صفحه مسابقه
  socket.emit("game_recovered", existingGame);
}

module.exports = { handleRequestGameState };
