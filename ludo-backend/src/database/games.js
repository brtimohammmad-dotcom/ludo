// اتصال به کلاینت جدید دیتابیس
const supabase = require("../../postgresql");
const initialState = require("../models/initialState");

/**
 * ایجاد یک بازی جدید در دیتابیس
 */
async function createNewGameInDatabase(gameMode) {
  let isGlobal;
  if (gameMode === 2 || gameMode === 4) {
    isGlobal = true;
  } else {
    false;
  }
  try {
    // درج رکورد جدید و دریافت آنی کل اطلاعات رکورد با استفاده از select()
    const { data: newGame, error } = await supabase
      .from(isGlobal ? "game" : "room")
      .insert([{ game_mode: isGlobal ? gameMode : -gameMode }])
      .select()
      .single();

    if (error) throw error;

    return newGame; // شامل game_id تولید شده به همراه مقادیر پیش‌فرض (started_at و ...)
  } catch (error) {
    console.error("خطا در ایجاد بازی جدید:", error);
    throw error;
  }
}

/**
 * به‌روزرسانی فیلدهای داینامیک بازی
 */
async function updateGameState(id, fields) {
  try {
    // در سوپابیس برای آپدیت داینامیک نیازی به ساختن دستی کلاز SET (مثل نقشه کردن Keys و Values) نیست؛
    // خود پکیج آبجکت fields را می‌گیرد و فیلدهای تغییر یافته را اعمال می‌کند.
    const { data: updatedGame, error } = await supabase
      .from("game")
      .update(fields)
      .eq("game_id", id)
      .select()
      .single();

    if (error) throw error;

    // دریافت لیست بازیکنان از استیت لوکال برنامه (طبق کد قبلی خودت)
    const players = initialState.getGameState(id)?.players || [];

    return {
      ...updatedGame,
      players: players.map((p) => ({
        socketId: p.socket_id,
        telegramId: p.telegram_id,
        color: p.color,
        username: p.username,
        player_status: p.player_status,
      })),
    };
  } catch (error) {
    console.error("خطا در به‌روزرسانی وضعیت بازی:", error);
    throw error;
  }
}
async function getGameState(gameId) {
  // روش 3: بدون single() - همیشه یک آرایه برمی‌گردد
  const { data: games, error } = await supabase
    .from("game")
    .select("*")
    .eq("game_id", gameId);

  if (error) {
    console.error("خطا:", error);
  } else if (games.length === 0) {
    console.log("بازی پیدا نشد");
  } else {
    const game = games[0]; // اولین (و تنها) رکورد
    console.log("بازی:", game);
    return game;
  }
}
module.exports = {
  createNewGameInDatabase,
  updateGameState,
  getGameState,
};
