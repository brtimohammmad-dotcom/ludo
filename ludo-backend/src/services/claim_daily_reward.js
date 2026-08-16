const { sendError } = require("../helpers/game_helpers");
const { getDailyRewardStreak } = require("../database/players");

// تابع کمکی برای دریافت تاریخ روز UTC
function getUtcDateString(date = new Date()) {
  return date.toISOString().split("T")[0];
}

async function handleClaimDailyReward(socket, callback) {
  const canClaim = socket.data.canClaimDailyReward;

  if (!canClaim) {
    return sendError(socket, callback, "already_claimed_daily_reward");
  }

  if (!socket.data.telegramId) {
    return sendError(socket, callback, "player_not_authorized");
  }

  try {
    const now = new Date();
    const todayUtcStr = getUtcDateString(now);
    let currentStreak = socket.data.rewardStreak || 1;

    // ۱. بررسی سوختن استریک (اگر بیشتر از ۱ روز تقویمی UTC غایب بوده)
    if (socket.data.lastClaimDate) {
      const lastClaimUtcStr = getUtcDateString(new Date(socket.data.lastClaimDate));
      const diffInDays = Math.round(
          (new Date(todayUtcStr) - new Date(lastClaimUtcStr)) / (1000 * 60 * 60 * 24)
      );

      if (diffInDays > 1) {
        currentStreak = 1; // ریست به روز ۱
      }
    }

    // ۲. محاسبه سکه و استریک بعدی
    const rewards = [100, 150, 200, 250, 300, 350, 500];
    const coinReward = rewards[currentStreak - 1] || 100;
    const newCoinBalance = (socket.data.coin || 0) + coinReward;
    let nextStreak = currentStreak >= 7 ? 1 : currentStreak + 1;

    // ۳. آپدیت حافظه سوکت
    socket.data.lastClaimDate = now.toISOString();
    socket.data.canClaimDailyReward = false;
    socket.data.coin = newCoinBalance;
    socket.data.rewardStreak = nextStreak;

    // ۴. ثبت در دیتابیس
    await getDailyRewardStreak(
        nextStreak,
        now,
        newCoinBalance,
        socket.data.telegramId
    );

    // ۵. پاسخ کالبک
    if (typeof callback === "function") {
      callback({ success: true });
    }

    // ۶. فقط ارسال سکه جدید به کلاینت
    socket.emit("daily_reward_claimed", { coin: newCoinBalance });

  } catch (err) {
    console.error("Error in daily reward claim:", err.message);
    sendError(socket, callback, "Failed to claim reward");
  }
}

module.exports = { handleClaimDailyReward };