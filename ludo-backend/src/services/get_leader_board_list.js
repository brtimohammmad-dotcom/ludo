const { getTopTenPlayers, getPlayerRank } = require("../database/players");
const { sendError } = require("../helpers/game_helpers");

async function handleGetLeaderBoardList(socket, callback) {
  try {
    const telegramId = socket.data.telegramId;

    if (!telegramId) {
      sendError(socket, callback, "player not authorized");
      return;
    }

    if (typeof callback === "function") {
      callback({ success: true });
    }
    const [topPlayers, userRankResult] = await Promise.all([
      getTopTenPlayers(),
      getPlayerRank(telegramId),
    ]);

    // ۳. ارسال اطلاعات نهایی به کلاینت
    socket.emit("leader_board_list_gets", {
      topPlayers: topPlayers, // یک آرایه حداکثر ۱۰ تایی شامل [{username, coin}, ...]
      currentUserRank: userRankResult.rank, // فقط عدد رتبه کاربر (مثلاً ۱۴۲)
    });
  } catch (error) {
    console.error("خطا در پاسخ به درخواست لیدربرد:", error.message);

    socket.emit("error", "خطا در دریافت اطلاعات لیدربرد");
  }
}

module.exports = { handleGetLeaderBoardList };
