const db = require("../../mysqlClient");
const initialState = require("../models/initialState");

async function findWaitingGameInDatabase() {
  try {
    const [rows] = await db.query(
      "SELECT * FROM game WHERE game_status = ? LIMIT 1",
      ["waitingForPlayer"],
    );

    // اگر رکوردی وجود داشت، اولین رکورد را برگردان، در غیر این صورت null
    return rows.length > 0 ? rows[0] : null;
  } catch (error) {
    console.error("خطا در پیدا کردن بازی در انتظار:", error);
    throw error;
  }
}

async function createNewGameInDatabase(gameMode) {
  try {
    // درج رکورد جدید با مقادیر پیش‌فرض
    const [result] = await db.query(
      "INSERT INTO game (game_mode) VALUES (?)",
      [gameMode], // مقدار پیش‌فرض برای وضعیت بازی
    );

    // دریافت رکورد تازه ایجاد شده
    const [rows] = await db.query("SELECT * FROM game WHERE game_id = ?", [
      result.insertId,
    ]);

    return rows[0];
  } catch (error) {
    console.error("خطا در ایجاد بازی جدید:", error);
    throw error;
  }
}

async function updateGameState(id, fields) {
  const setClause = Object.keys(fields)
    .map((key) => `${key} = ?`)
    .join(", ");
  const values = [...Object.values(fields), id];

  const [updateResult] = await db.query(
    `UPDATE game SET ${setClause} WHERE game_id = ?`,
    values,
  );

  const [rows] = await db.query("SELECT * FROM game WHERE game_id = ?", [id]);
  const players = initialState.getGameState(id).players;
  return {
    ...rows[0],
    players: players.map((p) => ({
      socketId: p.socket_id,
      telegramId: p.telegram_id,
      color: p.color,
      username: p.username,
      player_status: p.player_status,
    })),
  };
}

module.exports = {
  findWaitingGameInDatabase,
  createNewGameInDatabase,
  updateGameState,
};
