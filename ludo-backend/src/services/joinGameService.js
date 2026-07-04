const { joinGameQueue } = require("./joinGameQueue.js");
const initialState = require("../models/initialState");
const { createNewGameInDatabase } = require("../database/games");
const {
  TOW_PLAYER_COLORS,
  FOUR_PLAYER_COLORS,
} = require("../constants/gameConfig");
const { addPlayerToGameOnDatabase } = require("../database/gamePlayers");
const { updateGameState } = require("../database/games");
const { startTimer } = require("../services/turnTimerService");
const { error } = require("node:console");
const { updateLobbyMessage } = require("../../bot.js");
const { hasExistGame } = require("./authService.js");

async function handleJoinGame(numberOfPlayers, socket, io) {
  console.log("player id: ", socket.data.telegramId, " joined");
  console.log("player name: ", socket.data.firstName, "joined");
  console.log("number of players is: ", numberOfPlayers);

  return await joinGameQueue(numberOfPlayers, async () => {
    const player = {
      username: socket.data.firstName,
      telegram_id: socket.data.telegramId,
    };
    const result = await hasExistGame(player, socket.id);
    if (result.game) {
      socket.emit("in_another_game");
      return;
    }
    let gameOrRoom;
    // ----------------------------------------------------
    // بخش بازی‌های عمومی (مقادیر مثبت ۲ و ۴)
    // ----------------------------------------------------
    if (numberOfPlayers === 2 || numberOfPlayers === 4) {
      let game = initialState
        .getAllGames()
        .find(
          (g) =>
            g.game_status === "waitingForPlayer" &&
            g.number_of_players === numberOfPlayers &&
            g.game_mode === "global",
        );
      if (!game) {
        game = await createNewGameInDatabase(numberOfPlayers);
        game = initialState.createGameInGameState(
          game.game_id,
          numberOfPlayers,
        );
      }
      const players = initialState.getGameState(game.game_id).players;
      const playerIsInGame = players.some(
        (p) => p.telegram_id === socket.data.telegramId,
      );

      if (playerIsInGame) {
        const correctPlayers = game.players.map((p) => {
          if (p.telegram_id === socket.data.telegramId) {
            return { ...p, player_status: "online" };
          } else {
            return p;
          }
        });
        initialState.updateGameState(game.game_id, { players: correctPlayers });
        game = initialState.getGameState(game.game_id);
        return { game: game };
      } else {
        await addPlayerToGame(game, player);

        game = initialState.getGameState(game.game_id);
        gameOrRoom = game;
      }
    }

    // ----------------------------------------------------
    // بخش بازی‌های دوستانه (مقادیر منفی ۲- و ۴-)
    // ----------------------------------------------------
    if (numberOfPlayers === -2 || numberOfPlayers === -4) {
      // ۱. ساخت بازی در دیتابیس
      let room = await createNewGameInDatabase(numberOfPlayers);

      // ۲. ایجاد وضعیت بازی در حافظه (initialState)
      room = initialState.createGameInGameState(room.room_id, numberOfPlayers);

      // ۳. تعیین رنگ اولین بازیکن (سازنده بازی همیشه ایندکس ۰ است)
      await addPlayerToGame(room, player);
      room = initialState.getGameState(room.game_id);

      gameOrRoom = room;
    }
    socket.data.gameId = gameOrRoom.game_id;

    callFront(socket, io);
  });
}
async function handleJoinGameFriendly(socket, io) {
  console.log("joining game friendly");
  return await joinGameQueue(socket.data.gameId, async () => {
    const player = {
      username: socket.data.firstName,
      telegram_id: socket.data.telegramId,
    };
    try {
      const game = initialState.getGameState(socket.data.gameId);

      await addPlayerToGame(game, player);
      callFront(socket, io);
    } catch {
      console.log(error);
    }
  });
}
async function callFront(socket, io) {
  // سوکت را وارد روم کن
  socket.join(socket.data.gameId);

  // state فعلی بازی را بگیر
  let currentGameState = initialState.getGameState(socket.data.gameId);
  // ارسال state به همه
  socket.emit("game_state_update", currentGameState);
  const newPlayer = currentGameState.players.find(
    (p) => p.telegram_id === socket.data.telegramId,
  );
  if (newPlayer) {
    socket.to(socket.data.gameId).emit("player_joined", newPlayer);
  }

  // اگر بازی کامل شد → شروع کن
  if (
    currentGameState.players.length === currentGameState.number_of_players &&
    currentGameState.game_status === "waitingForPlayer"
  ) {
    currentGameState.game_status = "start";

    await updateGameState(
      socket.data.gameId,
      { game_status: "start" },
      currentGameState.game_mode,
    );
    initialState.updateGameState(socket.data.gameId, {
      game_status: "start",
    });

    io.to(socket.data.gameId).emit("game_started");

    startTimer(socket, io);
  }
  updateLobbyMessage(socket.data.gameId);
}
async function addPlayerToGame(game, player) {
  const players = game.players;

  const color =
    game.number_of_players === 2
      ? TOW_PLAYER_COLORS[players.length]
      : FOUR_PLAYER_COLORS[players.length];

  const playerInDataBase = await addPlayerToGameOnDatabase(
    player,
    game.game_id,
    color,
    game.game_mode,
  );
  const correctPlayer = {
    ...playerInDataBase,
    color: color,
    player_status: "online",
    numberOfAbsences: 0,
    connection_status: "connected",
  };
  initialState.addPlayerToGameState(correctPlayer, game.game_id);
}
module.exports = { handleJoinGame, handleJoinGameFriendly };
