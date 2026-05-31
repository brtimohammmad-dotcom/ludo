const http = require("http");
// پورتی که از فایل constants می‌آید را با حروف کوچک می‌آوریم تا با متغیر اصلی تداخل نکند
const { PORT, VERSION } = require("./src/constants/gameConfig");

// این خط طلایی مشکل رندر را حل می‌کند:

const server = http.createServer();
const io = require("socket.io")(server, {
  cors: {
    origin: "https://ludo-tecb.onrender.com", // دامین دقیق فرانت‌اندمان را اینجا بگذارید
    methods: ["GET", "POST"],
    allowedHeaders: ["Content-Type", "Authorization"],
    credentials: true
  },
//  connectionStateRecovery: {
//     // مدت زمان نگهداری اطلاعات (پیش‌فرض: 2 دقیقه)
//     maxDisconnectionDuration: 2 * 60 * 1000,
//     // آیا middlewareها در reconnect موفق رد شوند (پیش‌فرض: true)
//     skipMiddlewares: false,
//   },
  transports: ["websocket", "polling"]
});

const registerGameHandlers = require("./src/sockets/gameHandler");

io.on("connection", registerGameHandlers(io));

// حالا به پورت واقعی و داینامیک گوش می‌دهیم
const port = process.env.PORT || 3000;

server.listen(port, "0.0.0.0", () => {
  console.log(`Server running on port ${port}`);
});
