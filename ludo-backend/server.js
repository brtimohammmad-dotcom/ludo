const http = require("http");
// پورتی که از فایل constants می‌آید را با حروف کوچک می‌آوریم تا با متغیر اصلی تداخل نکند
const { PORT: defaultPort, VERSION } = require("./src/constants/gameConfig");

// این خط طلایی مشکل رندر را حل می‌کند:
const REAL_PORT = process.env.PORT || defaultPort || 3000;

const server = http.createServer();
const io = require("socket.io")(server, { 
  cors: { origin: "*" },
  transports: ['websocket', 'polling'] // حتماً این را هم اضافه کن تا وب‌سوکت فلاتر وب راحت‌تر وصل شود
});

const registerGameHandlers = require("./src/sockets/gameHandler");

io.on("connection", registerGameHandlers(io));

// حالا به پورت واقعی و داینامیک گوش می‌دهیم
server.listen(REAL_PORT, () => {
  console.log(`Server running on port ${REAL_PORT}`);
  console.log(`Server version: ${VERSION}`);
});
