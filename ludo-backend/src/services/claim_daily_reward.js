async function handleClaimDailyReward(socket) {
  const canClaim = socket.data.canClaimDailyReward;
  if (!canClaim) {
    socket.emit("already_claimed_daily_reward");
    return;
  }
  try {
    const now = new Date();

    let currentStreak = socket.data.rewardStreak;

    // اگر دکمه کلیم فشرده شده، یعنی زنجیره حفظ شده؛ پس روز را جلو می‌بریم (تا سقف ۷ روز)
    let nextStreak = currentStreak >= 7 ? 1 : currentStreak + 1;

    // لیست جوایز روزها (از روز ۱ تا ۷)
    const rewards = [100, 150, 200, 250, 300, 350, 500];
    const coinReward = rewards[currentStreak - 1]; 
    const newCoinBalance = (socket.data.coin || 0) + coinReward;
    const { getDailyRewardStreak } = require("../database/players");
    socket.data.lastClaimDate = now.toISOString();
    socket.data.canClaimDailyReward = false;
    socket.data.coin = newCoinBalance;
    await getDailyRewardStreak(
      nextStreak,
      now,
      newCoinBalance,
      socket.data.telegramId,
    );
    socket.emit("daily_reward_claimed", { coin: newCoinBalance });
  } catch (err) {
    console.error("Error in fixed daily reward claim:", err.message);
    socket.emit("claim_reward_error", { message: "Failed to claim reward." });
  }
}
module.exports = { handleClaimDailyReward };
