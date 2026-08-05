const supabase = require("../../postgresql");

async function addPlayerToGameOnDatabase(telegramId, gameId, color) {
  try {
    const { data, error } = await supabase
      .from("game_players")
      .insert({
        game_id: String(gameId),
        telegram_id: telegramId,
        color: color,
        player_status: "online",
      })
      .select()
      .single();

    if (error) {
      if (error.code === "23505") {
        // جلوگیری از ارور ثبت تکراری
        return null;
      }
      throw error;
    }

    return data;
  } catch (error) {
    console.error("❌ خطا در ثبت بازیکن در دیتابیس:", error);
    throw error;
  }
}
/**
 * تغییر وضعیت آنلاین/آفلاین بودن بازیکن در طول بازی
 */
async function updatePlayerStatusOnDatabase(telegramId, gameId, status) {
  try {
    const { data, error } = await supabase
        .from("game_players")
        .update({ player_status: status })
        .eq("game_id", String(gameId))
        .eq("telegram_id", telegramId)
        .select()
        .single();

    if (error) throw error;
    return data;
  } catch (error) {
    console.error("❌ خطا در آپدیت وضعیت بازیکن:", error);
    throw error;
  }
}

/**
 * حذف بازیکن از بازی (مخصوص زمانی که لابی هنوز شروع نشده و بازیکن لفت می‌دهد)
 */
async function removePlayerFromGameOnDatabase(telegramId, gameId) {
  try {
    const { error } = await supabase
        .from("game_players")
        .delete()
        .eq("game_id", String(gameId))
        .eq("telegram_id", telegramId);

    if (error) throw error;
    return true;
  } catch (error) {
    console.error("❌ خطا در حذف بازیکن از دیتابیس:", error);
    throw error;
  }
}

module.exports = {
  addPlayerToGameOnDatabase,
  updatePlayerStatusOnDatabase,
  removePlayerFromGameOnDatabase,
};
