const http = require("http");
const { PORT, VERSION } = require("./src/constants/gameConfig");

const server = http.createServer();
const io = require("socket.io")(server, { cors: { origin: "*" } });

const registerGameHandlers = require("./src/sockets/gameHandler");

io.on("connection", registerGameHandlers(io));

server.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
  console.log(`Server version: ${VERSION}`);
});
