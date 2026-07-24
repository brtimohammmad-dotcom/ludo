const { sendError } = require("../helpers/game_helpers");
const { getDailyRewardStreak } = require("../database/players");

async function handleClaimDailyReward(socket, callback) {
  const canClaim = socket.data.canClaimDailyReward;

  if (!canClaim) {
    return sendError(socket, callback, "already_claimed_daily_reward");
  }

  if (!socket.data.telegramId) {
    return sendError(socket, callback, "player_not_authorized");
  }

  try {
    if (typeof callback === "function") {
      callback({ success: true });
    }

    const now = new Date();
    let currentStreak = socket.data.rewardStreak || 1;

    // محاسبه استریک بعدی برای روز بعد (حداکثر ۷)
    let nextStreak = currentStreak >= 7 ? 1 : currentStreak + 1;

    // لیست جوایز روزها (از روز ۱ تا ۷)
    const rewards = [100, 150, 200, 250, 300, 350, 500];
    const coinReward = rewards[currentStreak - 1] || 100;
    const newCoinBalance = (socket.data.coin || 0) + coinReward;

    socket.data.lastClaimDate = now.toISOString();
    socket.data.canClaimDailyReward = false;
    socket.data.coin = newCoinBalance;
    socket.data.rewardStreak = nextStreak;

    await getDailyRewardStreak(
      nextStreak,
      now,
      newCoinBalance,
      socket.data.telegramId,
    );

    socket.emit("daily_reward_claimed", { coin: newCoinBalance });
  } catch (err) {
    console.error("Error in daily reward claim:", err.message);
    sendError(socket, callback, "Failed to claim reward");
  }
}

module.exports = { handleClaimDailyReward };
