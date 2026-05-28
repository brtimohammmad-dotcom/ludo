// خروجی جدید دیتابیس را به فایلی که ساختی وصل می‌کنیم
const supabase = require("../../postgresql");
const initialState = require("../models/initialState");

async function addPlayerToGameOnDatabase(player, gameId, color) {
  try {
    // ۱. ابتدا دیتای فعلی ستون players را برای این بازی می‌گیریم
    const { data: gameData, error: fetchError } = await supabase
      .from("game")
      .select("players")
      .eq("game_id", gameId)
      .single();

    if (fetchError) throw fetchError;

    // مطمئن می‌شویم که مچ به صورت آرایه است، اگر خالی بود یک آرایه خالی قرار می‌دهیم
    let currentPlayers = gameData.players || [];

    // اگر دیتابیس به صورت رشته فرستاده بود پارسش می‌کنیم (معمولاً در jsonb خود ابزار تبدیل آرایه می‌دهد)
    if (typeof currentPlayers === "string") {
      currentPlayers = JSON.parse(currentPlayers);
    }

    // ۲. ساختن آبجکت بازیکن جدید با ساختاری که مد نظرت بود
    const newPlayerObj = {
      telegram_id: player.telegram_id,
      username: player.username,
      color: color,
    };

    // اضافه کردن بازیکن جدید به لیست فعلی بازیکنان
    currentPlayers.push(newPlayerObj);

    // ۳. آپدیت کردن دیتابیس با آرایهٔ جدید و گرفتن خروجی آپدیت شده (select)
    const { data: updatedGame, error: updateError } = await supabase
      .from("game")
      .update({ players: currentPlayers })
      .eq("game_id", gameId)
      .select("players")
      .single();

    if (updateError) throw updateError;

    // ۴. پیدا کردن و برگرداندن همین بازیکنی که تازه اضافه شد
    const playersList = updatedGame.players || [];
    const currentPlayer = playersList.find(
      (p) => p.telegram_id === player.telegram_id,
    );

    return currentPlayer; // دقیقاً همان آبجکت بازیکن برگشت داده می‌شود
  } catch (error) {
    console.error("خطا در اضافه کردن بازیکن به بازی:", error);
    throw error;
  }
}

module.exports = { addPlayerToGameOnDatabase };
