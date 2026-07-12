// server.js (یا نام فایل اصلی سرور شما)
require("dotenv").config(); // 🚀 لود کردن متغیرهای محیطی در بالاترین خط برنامه

const http = require("http");
const { bot } = require("./bot");

// تشخیص خودکار محیط بر اساس فایل .env
const isLocal = process.env.NODE_ENV !== "production";
const frontendUrl = process.env.FRONTEND_URL || "http://localhost:3000";
const backendUrl = process.env.BACKEND_URL;

const server = http.createServer((req, res) => {
  // استفاده از آدرس فرانت‌ند به صورت داینامیک در CORS
  res.setHeader("Access-Control-Allow-Origin", frontendUrl);
  res.setHeader("Access-Control-Allow-Methods", "GET, OPTIONS, POST");
  res.setHeader("Access-Control-Allow-Headers", "Content-Type");

  if (req.method === "OPTIONS") {
    res.writeHead(204);
    return res.end();
  }

  if (req.url === "/health") {
    res.writeHead(200, { "Content-Type": "application/json" });
    return res.end(
      JSON.stringify({ status: "ok", environment: process.env.NODE_ENV }),
    );
  }

  if (req.url === "/webhook" && req.method === "POST") {
    let body = "";
    req.on("data", (chunk) => (body += chunk));
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
    // ست کردن وبهوک داینامیک روی سرور اصلی
    await bot.telegram.setWebhook(`${backendUrl}/webhook`);
    console.log("🌐 Webhook successfully set to:", `${backendUrl}/webhook`);
  } else {
    // اگر دوست داشتی در حالت لوکال بات کار کند، این را کامنتش را باز کن
    // bot.launch();
    console.log("🤖 Bot running in local mode (Webhook bypassed)");
  }
});
