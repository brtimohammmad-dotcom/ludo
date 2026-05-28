// db.js
const mysql = require("mysql2");

// تنظیمات اتصال به دیتابیس MySQL محلی یا سرور
// این مقادیر را بر اساس تنظیمات دیتابیس خودتان تغییر دهید
const pool = mysql.createPool({
  // اگر متغیر محیطی بود از آن استفاده کند، در غیر این صورت از لوکال‌هاست (برای سیستم خودت)
  host: process.env.DB_HOST || "127.0.0.1", 
  user: process.env.DB_USER || "root", 
  password: process.env.DB_PASSWORD || "", // رمز عبور سیستم خودت (اگر دارد)
  database: process.env.DB_NAME || "ludo", 
  port: process.env.DB_PORT || 3306, // پورت پیش‌فرض mysql در سیستم خودت
  
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0,
  
  // این بخش برای اتصال به سرور ابری آایون عالی و بدون نقص کار خواهد کرد
  ssl: {
    rejectUnauthorized: false
  }
});

// از نسخه promise برای استفاده با async/await راحت‌تر است
// این همان چیزی است که شما در نهایت export خواهید کرد
const db = pool.promise();

module.exports = db;
