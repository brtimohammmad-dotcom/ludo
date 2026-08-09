require("dotenv").config();

process.on("uncaughtException", (err) => {
  console.error("❌ Uncaught Exception:", err);
});

process.on("unhandledRejection", (reason, promise) => {
  console.error("❌ Unhandled Rejection at:", promise, "reason:", reason);
});

const http = require("http");
const { bot } = require("./bot");

const isLocal = process.env.NODE_ENV !== "production";
const frontendUrl = process.env.FRONTEND_URL || "http://localhost:3000";
const backendUrl = process.env.BACKEND_URL;

// 🟢 ساخت میدل‌ور استاندارد وبهوک تلگرام
const handleTelegramWebhook = bot.webhookCallback("/webhook");

// 🟢 تابع کمکی برای خواندن Body درخواست‌های POST در HTTP خام
const parseJsonBody = (req) => {
  return new Promise((resolve) => {
    let body = "";
    req.on("data", (chunk) => {
      body += chunk.toString();
    });
    req.on("end", () => {
      try {
        resolve(body ? JSON.parse(body) : {});
      } catch (e) {
        resolve({});
      }
    });
  });
};

const server = http.createServer(async (req, res) => {
  const parsedUrl = new URL(req.url, `http://${req.headers.host}`);
  const pathname = parsedUrl.pathname;

  // تنظیم CORS
  if (pathname === "/proxy-avatar") {
    res.setHeader("Access-Control-Allow-Origin", "*");
  } else {
    res.setHeader("Access-Control-Allow-Origin", frontendUrl);
  }

  res.setHeader("Access-Control-Allow-Methods", "GET, OPTIONS, POST");
  res.setHeader(
    "Access-Control-Allow-Headers",
    "Content-Type, Accept, Authorization",
  );

  if (req.method === "OPTIONS") {
    res.writeHead(204);
    return res.end();
  }

  if (pathname === "/health") {
    res.writeHead(200, { "Content-Type": "application/json" });
    return res.end(JSON.stringify({ status: "ok" }));
  }

  // 5️⃣ روت وبهوک تلگرام
  if (pathname === "/webhook" && req.method === "POST") {
    // خواندن Body و attach کردن آن به req برای Telegraf
    req.body = await parseJsonBody(req);
    return handleTelegramWebhook(req, res);
  }

  res.writeHead(404);
  res.end();
});

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
      // پاکسازی وبهوک قبلی و ست کردن وبهوک جدید
      await bot.telegram.deleteWebhook({ drop_pending_updates: true });
      await bot.telegram.setWebhook(`${backendUrl}/webhook`);
      console.log("🌐 Webhook successfully set to:", `${backendUrl}/webhook`);
    } catch (webhookError) {
      console.error("❌ Failed to set Telegram Webhook:", webhookError);
    }
  } else {
    // 🟢 اگر روی لوکال بودی، ربات رو با Polling روشن کن!
    await bot.telegram.deleteWebhook({ drop_pending_updates: true });
    bot.launch();
    console.log("🤖 Bot running in LOCAL mode using Polling!");
  }
});

process.once("SIGINT", () => {
  const { stopAllBotDrivers } = require("./src/services/botService");
  if (typeof stopAllBotDrivers === "function") stopAllBotDrivers();
  bot.stop("SIGINT");
});

process.once("SIGTERM", () => {
  const { stopAllBotDrivers } = require("./src/services/botService");
  if (typeof stopAllBotDrivers === "function") stopAllBotDrivers();
  bot.stop("SIGTERM");
});
