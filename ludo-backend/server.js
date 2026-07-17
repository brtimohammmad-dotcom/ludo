// server.js
require("dotenv").config(); // 🚀 لود کردن متغیرهای محیطی در بالاترین خط برنامه

// 🛑 جلوگیری از کرش کردن سرور در صورت بروز خطای غیرمنتظره
process.on("uncaughtException", (err) => {
  console.error("❌ Uncaught Exception:", err);
});

process.on("unhandledRejection", (reason, promise) => {
  console.error("❌ Unhandled Rejection at:", promise, "reason:", reason);
});

const http = require("http");
const { bot } = require("./bot");

// تشخیص خودکار محیط بر اساس فایل .env
const isLocal = process.env.NODE_ENV !== "production";
const frontendUrl = process.env.FRONTEND_URL || "http://localhost:3000";
const backendUrl = process.env.BACKEND_URL;

const server = http.createServer(async (req, res) => {
  // گرفتن دامنه‌ها و پارامترها از روی آدرس درخواست (بخش Query Params)
  const parsedUrl = new URL(req.url, `http://${req.headers.host}`);
  const pathname = parsedUrl.pathname;

  // تنظیم هدرهای پایه CORS برای پاسخ‌ها
  res.setHeader("Access-Control-Allow-Origin", frontendUrl);
  res.setHeader("Access-Control-Allow-Methods", "GET, OPTIONS, POST");
  res.setHeader("Access-Control-Allow-Headers", "Content-Type");

  if (req.method === "OPTIONS") {
    res.writeHead(204);
    return res.end();
  }

  // 1️⃣ روت سلامت سرور
  if (pathname === "/health") {
    res.writeHead(200, { "Content-Type": "application/json" });
    return res.end(
      JSON.stringify({ status: "ok", environment: process.env.NODE_ENV }),
    );
  }

  // 2️⃣ 🔄 روت جدید: پروکسی آواتار تلگرام (حل مشکل CORS فرانت‌اند)
  if (pathname === "/proxy-avatar" && req.method === "GET") {
    try {
      const fileUrl = parsedUrl.searchParams.get("url");

      if (!fileUrl) {
        res.writeHead(400, { "Content-Type": "text/plain" });
        return res.end("URL is required");
      }

      // امنیت: فقط درخواست به دامنه‌ی رسمی تلگرام مجاز است
      if (!fileUrl.startsWith("https://api.telegram.org")) {
        res.writeHead(403, { "Content-Type": "text/plain" });
        return res.end("Only Telegram API URLs are allowed");
      }

      // دانلود عکس از تلگرام
      const response = await fetch(fileUrl);

      if (!response.ok) {
        res.writeHead(response.status, { "Content-Type": "text/plain" });
        return res.end("Failed to fetch image from Telegram");
      }

      const arrayBuffer = await response.arrayBuffer();
      const buffer = Buffer.from(arrayBuffer);

      // آزاد کردن کامل CORS برای این عکس تا فلاتر وب بتونه راحت رندرش کنه
      res.setHeader("Access-Control-Allow-Origin", "*");
      res.writeHead(200, {
        "Content-Type": response.headers.get("content-type") || "image/jpeg",
      });
      return res.end(buffer);
    } catch (error) {
      console.error("Avatar proxy error:", error);
      res.writeHead(500, { "Content-Type": "text/plain" });
      return res.end("Error fetching image");
    }
  }

  // 3️⃣ روت وبهوک تلگرام
  if (pathname === "/webhook" && req.method === "POST") {
    let body = "";
    req.on("data", (chunk) => {
      body += chunk;
      // جلوگیری از پر شدن حافظه رم سرور توسط ریکوئست‌های حجیم
      if (body.length > 1e6) {
        res.writeHead(413, { "Content-Type": "text/plain" });
        res.end("Request Entity Too Large");
        return req.destroy();
      }
    });

    req.on("end", () => {
      try {
        const update = JSON.parse(body);
        bot.handleUpdate(update);
        res.writeHead(200);
        res.end();
      } catch (err) {
        res.writeHead(400);
        res.end();
      }
    });
    return;
  }

  // روت‌های ناشناخته
  res.writeHead(404);
  res.end();
});

// کانفیگ هوشمند سوکت بر اساس محیط
const io = require("socket.io")(server, {
  cors: {
    origin: frontendUrl,
    methods: ["GET", "POST"],
    allowedHeaders: ["Content-Type", "Authorization"],
    credentials: true,
  },
  connectionStateRecovery: {
    maxDisconnectionDuration: 20 * 1000,
    skipMiddlewares: false,
  },
  pingInterval: 5000,
  pingTimeout: 3000,
  transports: ["websocket", "polling"],
});

const registerGameHandlers = require("./src/sockets/gameHandler");
io.on("connection", registerGameHandlers(io));

const port = process.env.PORT || 3000;

server.listen(port, "0.0.0.0", async () => {
  console.log(
    `🚀 Server running in [${process.env.NODE_ENV}] mode on port ${port}`,
  );
  console.log(`🔗 Allowed Frontend CORS: ${frontendUrl}`);

  if (!isLocal && backendUrl) {
    await bot.telegram.setWebhook(`${backendUrl}/webhook`);
    console.log("🌐 Webhook successfully set to:", `${backendUrl}/webhook`);
  } else {
    console.log("🤖 Bot running in local mode (Webhook bypassed)");
  }
});
