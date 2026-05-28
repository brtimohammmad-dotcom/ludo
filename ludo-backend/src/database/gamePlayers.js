const db = require("../../mysqlClient");
const initialState = require("../models/initialState");

async function addPlayerToGameOnDatabase(player, gameId, color) {
  try {
    // اضافه کردن بازیکن جدید
    const query = `
      UPDATE game 
      SET players = JSON_ARRAY_APPEND(
        COALESCE(players, '[]'),
        '$',
        JSON_OBJECT(
          'telegram_id', ?,
          'username', ?,
          'color', ?
        )
      )
      WHERE game_id = ?
    `;

    await db.query(query, [player.telegram_id, player.username, color, gameId]);
    // 2. گرفتن کل بازی با دیتای جدید
    const [rows] = await db.query(
      "SELECT players FROM game WHERE game_id = ?",
      [gameId],
    );

    // 3. پیدا کردن همون بازیکنی که اضافه کردیم
    const playersRaw = rows[0]?.players || "[]";
    const players = Array.isArray(playersRaw)
      ? playersRaw
      : JSON.parse(playersRaw);
    const currentPlayer = players.find(
      (p) => p.telegram_id === player.telegram_id,
    );

    return currentPlayer; // اینجا دقیقاً همون آبجکت بازیکنه
  } catch (error) {
    console.error("خطا در اضافه کردن بازیکن به بازی:", error);
    throw error;
  }
}
module.exports = { addPlayerToGameOnDatabase };
