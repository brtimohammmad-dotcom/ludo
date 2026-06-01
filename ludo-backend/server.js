const http = require("http");

const server = http.createServer((req, res) => {
  if (req.url === "/health") {
    res.writeHead(200, {
      "Content-Type": "application/json",
    });

    res.end(
      JSON.stringify({
        status: "ok",
      }),
    );

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
    maxDisconnectionDuration: 60 * 1000,
    skipMiddlewares: false,
  },
  transports: ["websocket", "polling"],
});

const registerGameHandlers = require("./src/sockets/gameHandler");

io.on("connection", registerGameHandlers(io));

const port = process.env.PORT || 3000;

server.listen(port, "0.0.0.0", () => {
  console.log(`Server running on port ${port}`);
});
