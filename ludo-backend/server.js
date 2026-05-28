const http = require("http");
// پورتی که از فایل constants می‌آید را با حروف کوچک می‌آوریم تا با متغیر اصلی تداخل نکند
const { PORT, VERSION } = require("./src/constants/gameConfig");

// این خط طلایی مشکل رندر را حل می‌کند:

const server = http.createServer();
const io = require("socket.io")(server, {
  cors: { origin: "*" },
});

const registerGameHandlers = require("./src/sockets/gameHandler");

io.on("connection", registerGameHandlers(io));

// حالا به پورت واقعی و داینامیک گوش می‌دهیم
const port = process.env.PORT || 3000;

server.listen(port, "0.0.0.0", () => {
  console.log(`Server running on port ${port}`);
});
