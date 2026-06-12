const http = require("http");
const bot = require("./bot"); // فایل بالا

const server = http.createServer((req, res) => {
  res.setHeader(
    "Access-Control-Allow-Origin",
    "https://ludo-tecb.onrender.com",
  );

  res.setHeader("Access-Control-Allow-Methods", "GET, OPTIONS");

  res.setHeader("Access-Control-Allow-Headers", "Content-Type");

  if (req.method === "OPTIONS") {
    res.writeHead(204);
    return res.end();
  }

  if (req.url === "/health") {
    res.writeHead(200, {
      "Content-Type": "application/json",
    });

    return res.end(
      JSON.stringify({
        status: "ok",
      }),
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
const isLocal = process.env.RENDER !== "true";

const io = require("socket.io")(server, {
  cors: {
    origin: isLocal
      ? "http://localhost:3000"
      : "https://ludo-tecb.onrender.com",
    methods: ["GET", "POST"],
    allowedHeaders: ["Content-Type", "Authorization"],
    credentials: true,
  },
  connectionStateRecovery: {
    maxDisconnectionDuration: 20 * 1000,
    skipMiddlewares: false,
  },
  pingInterval: 5000, // هر ۵ ثانیه سرور به کلاینت پینگ می‌فرستد
  pingTimeout: 3000, // اگر کلاینت تا ۳ ثانیه بعد جواب نداد، سرور فرض می‌کند قطع شده است
  transports: ["websocket", "polling"],
});

const registerGameHandlers = require("./src/sockets/gameHandler");

io.on("connection", registerGameHandlers(io));

const port = process.env.PORT || 3000;

server.listen(port, "0.0.0.0", () => {
  console.log(`Server running on port ${port}`);
});
