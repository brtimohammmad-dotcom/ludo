const http = require("http");


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
