// db.js
const mysql = require("mysql2");

// تنظیمات اتصال به دیتابیس MySQL محلی یا سرور
// این مقادیر را بر اساس تنظیمات دیتابیس خودتان تغییر دهید
const pool = mysql.createPool({
  host: "127.0.0.1", // آدرس سرور دیتابیس شما (مثلاً localhost یا 127.0.0.1)
  user: "root", // نام کاربری MySQL شما
  database: "ludo", // نام دیتابیسی که قبلاً ساختهاید
  waitForConnections: true,
  connectionLimit: 10, // حداکثر تعداد اتصالات همزمان
  queueLimit: 0,
  ssl: {
    rejectUnauthorized: false
  }
});

// از نسخه promise برای استفاده با async/await راحت‌تر است
// این همان چیزی است که شما در نهایت export خواهید کرد
const db = pool.promise();

module.exports = db;
