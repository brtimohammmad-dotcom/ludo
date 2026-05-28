// db.js
const mysql = require("mysql2");

// ۱. تنظیم کانکشن‌پول با قابلیت خواندن از متغیرهای محیطی رندر
const pool = mysql.createPool({
  host: process.env.DB_HOST || "127.0.0.1",
  user: process.env.DB_USER || "root",
  password: process.env.DB_PASSWORD || "",
  database: process.env.DB_NAME || "ludo",
  port: process.env.DB_PORT || 3306,
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0,
  ssl: {
    rejectUnauthorized: false // اجباری برای اتصال به سرور ابری آایون
  }
});

// ۲. تابع اختصاصی برای ساخت خودکار جدول‌های لودو بدون نیاز به کارهای دستی
async function checkAndCreateTables() {
  try {
    console.log("⏳ [Database] در حال بررسی و ساخت خودکار جدول‌های لودو...");

    // ساخت جدول بازیکنان
    await pool.query(`
      CREATE TABLE IF NOT EXISTS \`players\` (
        \`telegram_id\` INT(8) NOT NULL,
        \`username\` VARCHAR(10) NOT NULL,
        PRIMARY KEY (\`telegram_id\`)
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
    `);
    console.log("🔹 جدول players بررسی/ساخته شد.");

    // ساخت جدول بازی‌ها (سازگار با دیتابیس ابری MySQL 8)
    await pool.query(`
      CREATE TABLE IF NOT EXISTS \`game\` (
        \`game_id\` INT(8) NOT NULL AUTO_INCREMENT,
        \`game_status\` ENUM('waitingForPlayer','start','finished','cancel') NOT NULL DEFAULT 'waitingForPlayer',
        \`started_at\` TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
        \`end_at\` TIMESTAMP(6) NULL DEFAULT NULL,
        \`winner\` LONGTEXT NULL,
        \`players\` LONGTEXT NULL,
        \`game_mode\` INT(1) DEFAULT NULL,
        PRIMARY KEY (\`game_id\`)
      ) ENGINE=InnoDB AUTO_INCREMENT=438 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
    `);
    console.log("🔹 جدول game بررسی/ساخته شد.");

    console.log("✅ [Database] تمامی جدول‌ها با موفقیت سینک و آماده استفاده هستند!");
  } catch (error) {
    console.error("❌ [Database] خطای شدید در ساخت خودکار جدول‌ها:", error);
  }
}

// ۳. اجرای اسکریپت همزمان با استارت سرور لودو
const PORT = process.env.PORT || 3000;
// اگر از express استفاده می‌کنی کدهای پایین را با کدهای listen خودت ترکیب کن:
app.listen(PORT, async () => {
  console.log(`🚀 Server is running on port ${PORT}`);
  
  // به محض اینکه سرور در رندر بالا آمد، این تابع دیتابیس آنلاین را پر می‌کند
  await checkAndCreateTables(); 
});راحت‌تر است
// این همان چیزی است که شما در نهایت export خواهید کرد
const db = pool.promise();

module.exports = db;
