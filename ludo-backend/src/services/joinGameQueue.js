const userLocks = new Map();

/**
 * مدیریت قفل‌های همزمانی بر اساس آیدی بازیکن
 * @param {string|number} playerId - آیدی منحصربه‌فرد بازیکن
 * @param {Function} callback - عملیات اصلی ورود به بازی و کسر سکه
 */
async function joinGameQueue(playerId, callback) {
  // ۱. گرفتن قفل فعلی کاربر (اگر در حال پردازش درخواست قبلی باشد) یا حل‌شده
  const currentLock = userLocks.get(playerId) || Promise.resolve();

  let release;

  // ۲. ساخت قفل جدید برای درخواست‌های بعدی همین کاربر
  const nextLock = new Promise((resolve) => {
    release = resolve;
  });

  // ۳. ثبت قفل جدید برای این کاربر در مپ
  userLocks.set(
    playerId,
    currentLock.then(() => nextLock),
  );

  // ۴. انتظار برای به پایان رسیدن کارهای قبلی همین کاربر
  await currentLock;

  try {
    // ۵. اجرای عملیات اصلی (مانند کسر سکه، ساخت اتاق یا اضافه شدن به دیتابیس)
    return await callback();
  } finally {
    // ۶. آزاد کردن قفل برای درخواست‌های بعدی این کاربر
    release();

    // ۷. پاک کردن آیدی کاربر از مپ قفل‌ها به محض پایان کار (جلوگیری از نشت حافظه)
    if (userLocks.get(playerId) === nextLock) {
      userLocks.delete(playerId);
    }
  }
}

module.exports = {
  joinGameQueue,
};
