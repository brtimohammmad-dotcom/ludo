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
  // 1️⃣ تفکیک دقیق آدرس از پارامترها (Query Params)
  const parsedUrl = new URL(req.url, `http://${req.headers.host}`);
  const pathname = parsedUrl.pathname;

  // 2️⃣ تنظیم هوشمند هدرهای CORS برای فلاتر وب
  if (pathname === "/proxy-avatar") {
    res.setHeader("Access-Control-Allow-Origin", "*"); // کاملاً آزاد برای لود عکس در مرورگر مینی‌اپ
  } else {
    res.setHeader("Access-Control-Allow-Origin", frontendUrl);
  }

  res.setHeader("Access-Control-Allow-Methods", "GET, OPTIONS, POST");
  res.setHeader(
    "Access-Control-Allow-Headers",
    "Content-Type, Accept, Authorization",
  );

  // پاسخ سریع به درخواست‌های OPTIONS مرورگر
  if (req.method === "OPTIONS") {
    res.writeHead(204);
    return res.end();
  }

  // 3️⃣ روت سلامت سرور
  if (pathname === "/health") {
    res.writeHead(200, { "Content-Type": "application/json" });
    return res.end(JSON.stringify({ status: "ok" }));
  }



  // 5️⃣ روت وبهوک تلگرام
  if (pathname === "/webhook" && req.method === "POST") {
    let body = "";
    req.on("data", (chunk) => {
      body += chunk;
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
        console.error("Webhook processing error:", err);
        res.writeHead(400);
        res.end();
      }
    });
    return;
  }

  // اگر هیچکدام نبود -> 404 واقعی
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
    `🚀 Server running in [${process.env.NODE_ENV || "development"}] mode on port ${port}`,
  );
  console.log(`🔗 Allowed Frontend CORS: ${frontendUrl}`);

  if (!isLocal && backendUrl) {
    try {
      await bot.telegram.setWebhook(`${backendUrl}/webhook`);
      console.log("🌐 Webhook successfully set to:", `${backendUrl}/webhook`);
    } catch (webhookError) {
      console.error("❌ Failed to set Telegram Webhook:", webhookError);
    }
  } else {
    console.log("🤖 Bot running in local mode (Webhook bypassed)");
  }
});
