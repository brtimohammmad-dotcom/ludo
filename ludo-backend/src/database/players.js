const db = require("../../mysqlClient");
const initialState = require("../models/initialState");

async function getOrCreatePlayer(telegramId, username) {
  try {
    // ابتدا بررسی کن بازیکن وجود دارد یا نه
    const [existingRows] = await db.query(
      "SELECT * FROM players WHERE telegram_id = ?",
      [telegramId],
    );

    if (existingRows.length > 0) {
      // بازیکن وجود دارد - به‌روزرسانی username (ممکن است تغییر کرده باشد)
      const [updateResult] = await db.query(
        "UPDATE players SET username = ? WHERE telegram_id = ?",
        [username, telegramId],
      );

      // گرفتن اطلاعات به‌روز شده
      const [rows] = await db.query(
        "SELECT * FROM players WHERE telegram_id = ?",
        [telegramId],
      );
      return rows[0];
    } else {
      // بازیکن وجود ندارد - ایجاد جدید
      const [insertResult] = await db.query(
        "INSERT INTO players (telegram_id, username) VALUES (?, ?)",
        [telegramId, username],
      );

      // گرفتن اطلاعات بازیکن جدید
      const [rows] = await db.query(
        "SELECT * FROM players WHERE telegram_id = ?",
        [telegramId],
      );
      return rows[0];
    }
  } catch (error) {
    console.error("خطا در دریافت یا ایجاد بازیکن:", error);
    throw error;
  }
}

module.exports = { getOrCreatePlayer};
