function generateBalancedDice(gameState, player) {
  // ۱. مقداردهی اولیه متغیرهای کمکی
  if (player.roll_count_without_six === undefined)
    player.roll_count_without_six = 0;
  if (player.consecutive_six_count === undefined)
    player.consecutive_six_count = 0;

  // بررسی وضعیت مهره‌های فعال بازیکن در زمین
  const hasActiveTokens = gameState.tokens.some(
    (t) => t.color === player.color && t.position > 0,
  );

  let dice;

  // ۲. اگر بازیکن هیچ مهره‌ای در زمین ندارد، شانس شش آوردن را پلکانی بالا می‌بریم
  if (!hasActiveTokens) {
    const rollCount = player.roll_count_without_six;
    const randomPercent = Math.random() * 100; // یک عدد تصادفی بین ۰ تا ۱۰۰

    let shouldBeSix = false;

    if (rollCount === 1) {
      if (randomPercent < 30) shouldBeSix = true; // ۳۰ درصد شانس در پرتاب دوم
    } else if (rollCount === 2) {
      if (randomPercent < 60) shouldBeSix = true; // ۶۰ درصد شانس در پرتاب سوم
    } else if (rollCount >= 3) {
      shouldBeSix = true; // ۱۰۰ درصد شانس در پرتاب چهارم به بعد
    }

    if (shouldBeSix) {
      player.roll_count_without_six = 0;
      player.consecutive_six_count += 1;
      return 6;
    }
  }

  // ۳. قانون ضد شش متوالی: اگر ۲ بار پشت سر هم ۶ آورده، تاس بعدی قطعاً بین ۱ تا ۵ باشد
  if (player.consecutive_six_count >= 2) {
    dice = Math.floor(Math.random() * 5) + 1;
  } else {
    // در حالت عادی تاس معمولی
    dice = Math.floor(Math.random() * 6) + 1;
  }

  // ۴. به‌روزرسانی شمارنده‌ها
  if (dice === 6) {
    player.roll_count_without_six = 0;
    player.consecutive_six_count += 1;
  } else {
    player.roll_count_without_six += 1;
    player.consecutive_six_count = 0;
  }

  return dice;
}

module.exports = { generateBalancedDice };
