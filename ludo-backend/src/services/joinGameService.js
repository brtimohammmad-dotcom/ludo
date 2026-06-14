const { joinGameQueue } = require("./joinGameQueue.js");
const initialState = require("../models/initialState");
const { createNewGameInDatabase } = require("../database/games");
const {
  TOW_PLAYER_COLORS,
  FOUR_PLAYER_COLORS,
} = require("../constants/gameConfig");
const { addPlayerToGameOnDatabase } = require("../database/gamePlayers");

async function handleJoinGame(numberOfPlayers, socket) {
  console.log("player id: ", socket.data.telegramId, " joined");
  console.log("player name: ", socket.data.firstName, "joined");
  console.log("number of players is: ", numberOfPlayers);

  return await joinGameQueue(numberOfPlayers, async () => {
    const player = {
      username: socket.data.firstName,
      telegram_id: socket.data.telegramId,
    };

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
        const color =
          numberOfPlayers === 2
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
        game = initialState.getGameState(game.game_id);

        return { game: game };
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
      const color =
        numberOfPlayers === -2 ? TOW_PLAYER_COLORS[0] : FOUR_PLAYER_COLORS[0];

      // ۴. اضافه کردن سازنده بازی به دیتابیس بازی

      const playerInDataBase = await addPlayerToGameOnDatabase(
        player,
        room.game_id,
        color,
        room.game_mode,
      );

      // ۵. اضافه کردن سازنده بازی به وضعیت حافظه
      const correctPlayer = {
        ...playerInDataBase,
        color: color,
        player_status: "online",
        numberOfAbsences: 0,
        connection_status: "connected",
      };
      initialState.addPlayerToGameState(correctPlayer, room.game_id);
      room = initialState.getGameState(room.game_id);

      // ۶. تولید لینک دعوت عمیق (Deep Linking) برای ربات تلگرام

      return {
        game: room,
      };
    }
  });
}
async function handleJoinGameFriendly(socket) {
  return await joinGameQueue(socket.data.gameId, async () => {
    const player = {
      username: socket.data.firstName,
      telegram_id: socket.data.telegramId,
    };
    let game = initialState.getGameState(socket.data.gameId);
    console.log(game);
    const players = game.players;
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
      initialState.updateGameState(game.game_id, {
        players: correctPlayers,
      });
      game = initialState.getGameState(game.game_id);
      return { game: game };
    } else {
      if (game.game_status === "start") {
        socket.emit("game_already_started");
      }
      const color =
        game.numberOfPlayers === 2
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
      game = initialState.getGameState(game.game_id);

      return { game: game };
    }
  });
}
module.exports = { handleJoinGame, handleJoinGameFriendly };
