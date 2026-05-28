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

module.exports = { getOrCreatePlayer };
