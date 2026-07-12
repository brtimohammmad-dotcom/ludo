const { getTopTenPlayers, getPlayerRank } = require("../database/players");
// نکته: به جای "اسم_فایل_دیتابیست" مسیر واقعی فایلی که متدهای بالا در آن قرار دارند را بنویس

async function handleGetLeaderBoardList(socket) {
  try {
    // ۱. گرفتن تلگرام‌آیدی کاربر از روی دیتای سوکت (که در مرحله auth ذخیره کرده‌ای)
    const telegramId = socket.data.telegramId;

    if (!telegramId) {
      return socket.emit("error", "کاربر احراز هویت نشده است.");
    }

    // ۲. اجرای موازی هر دو کوئری برای سرعت بالاتر سرور
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
