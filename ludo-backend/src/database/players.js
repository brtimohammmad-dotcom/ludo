// اتصال به کلاینت جدید دیتابیس
const supabase = require("../../postgresql");
const initialState = require("../models/initialState");

async function getOrCreatePlayer(telegramId, username) {
  try {
    // استفاده از ویژگی قدرتمند upsert
    // این دستور اگر رکورد وجود داشته باشد آپدیت می‌کند و اگر نباشد اینسرت می‌کند.
    // فیلدهای avatar_url و last_avatar_update را هم به ستون‌های پیش‌فرض اضافه کردیم تا در اولین ورود نال بمانند یا دیتا بگیرند.
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

// تابع جدید: برای مواقعی که عکس کاربر منقضی شده و لینک جدید را در دیتابیس ذخیره می‌کنیم
async function updatePlayerAvatar(telegramId, avatarUrl, lastUpdate) {
  try {
    const { data, error } = await supabase
      .from("players")
      .update({
        avatar_url: avatarUrl,
        last_avatar_update: lastUpdate.toISOString(), // تبدیل تاریخ جی‌اس به فرمت پستگرس
      })
      .eq("telegram_id", telegramId)
      .select()
      .single();

    if (error) throw error;
    return data;
  } catch (error) {
    console.error(
      `خطا در به‌روزرسانی آواتار بازیکن ${telegramId}:`,
      error.message,
    );
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
async function getTopTenPlayers() {
  try {
const { data, error } = await supabase
  .from("players")
  .select("username, coin")
  .order("coin", { ascending: false }) // شرط اول: سکه بیشتر
  .order("telegram_id", { ascending: true }) // شرط دوم: بر اساس ID یکتا
  .limit(10);

    if (error) throw error;
    return data;
  } catch (error) {
    console.error("خطا در دریافت لیست ۱۰ نفر برتر:", error.message);
    throw error;
  }
}

async function getPlayerRank(telegramId) {
  try {
    // ۱. ابتدا تعداد سکه‌های بازیکن فعلی را می‌گیریم
    const { data: player, error: playerError } = await supabase
      .from("players")
      .select("coin, username")
      .eq("telegram_id", telegramId)
      .single();

    if (playerError) throw playerError;

    // ۲. تعداد بازیکنانی که سکه‌شان از این بازیکن بیشتر است را می‌شماریم
    // این کار رتبه دقیق کاربر را در کل دیتابیس مشخص می‌کند
    const { count, error: countError } = await supabase
      .from("players")
      .select("*", { count: "exact", head: true }) // فقط تعداد را می‌شمارد و دیتا برنمی‌گرداند تا بهینه باشد
      .gt("coin", player.coin);

    if (countError) throw countError;

    // رتبه کاربر می‌شود: تعداد افرادی که سکه بیشتری دارند + 1
    return {
      rank: (count || 0) + 1,
    };
  } catch (error) {
    console.error("خطا در محاسبه رتبه بازیکن:", error.message);
    throw error;
  }
}
module.exports = {
  updatePlayerAvatar,
  getTopTenPlayers,
  getPlayerRank,
  getOrCreatePlayer,
  updateCoin,
  reduceMultiplePlayersCoin,
  getDailyRewardStreak,
};
