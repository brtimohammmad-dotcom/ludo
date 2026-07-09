// اتصال به کلاینت جدید دیتابیس
const supabase = require("../../postgresql");
const initialState = require("../models/initialState");

async function getOrCreatePlayer(telegramId, username) {
  try {
    // استفاده از ویژگی قدرتمند upsert
    // این دستور اگر رکورد وجود داشته باشد آپدیت می‌کند و اگر نباشد اینسرت می‌کند.
    const { data: player, error } = await supabase
      .from("players")
      .upsert(
        { telegram_id: telegramId, username: username },
        { onConflict: "telegram_id" }, // مشخص کردن ستون کلید اصلی برای بررسی تداخل
      )
      .select()
      .single();

    if (error) throw error;

    return player; // بازگرداندن دیتای نهایی بازیکن ساخته یا آپدیت شده
  } catch (error) {
    console.error("خطا در دریافت یا ایجاد بازیکن:", error);
    throw error;
  }
}
async function updateCoin(telegramId, action, value) {
  // action باید 'add' یا 'subtract' باشد
  const { data, error } = await supabase.rpc("update_player_coin", {
    target_telegram_id: telegramId,
    action_type: action,
    coin_value: value,
  });

  if (error) {
    console.error("خطا در به‌روزرسانی سکه:", error.message);
    throw error;
  }

  return data;
}
async function reduceMultiplePlayersCoin(telegramIds, value) {
  // action باید 'add' یا 'subtract' باشد
  const { data, error } = await supabase.rpc("reduce_multiple_players_coin", {
    target_telegram_ids: telegramIds,
    coin_value: value,
  });

  if (error) {
    console.error("خطا در کاهش گروهی سکه ی بازیکنان:", error.message);
    throw error;
  }

  return data;
}
async function getDailyRewardStreak(
  nextStreak,
  now,
  newCoinBalance,
  telegramId,
) {
  const { data, error } = await supabase
    .from("players")
    .update({
      last_claim_date: now.toISOString(),
      reward_streak: nextStreak, // روز زنجیره برای فردا آماده می‌شود
      coin: newCoinBalance,
    })
    .eq("telegram_id", telegramId);

  if (error) throw error;
}
module.exports = {
  getOrCreatePlayer,
  updateCoin,
  reduceMultiplePlayersCoin,
  getDailyRewardStreak,
};
