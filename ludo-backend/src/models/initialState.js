const activeGames = new Map(); // gameId -> gameState

// توابع پایه
const getGameState = (gameId) => activeGames.get(gameId);

const setGameState = (gameId, gameState) => {
  activeGames.set(gameId, gameState);
  return gameState;
};

const updateGameState = (gameId, updates) => {
  const game = activeGames.get(gameId);
  if (game) {
    Object.assign(game, updates);
    activeGames.set(gameId, game);
    return game;
  }
  return null;
};

const getAllGames = () => Array.from(activeGames.values());

// توابع دیگر که به توابع پایه نیاز دارند
const addPlayerToGameState = (newPlayer, gameId) => {
  const currentGame = getGameState(gameId);
  if (currentGame) {
    const updatedPlayers = [...(currentGame.players || []), newPlayer];
    updateGameState(gameId, { players: updatedPlayers });
  }
};

const createGameInGameState = (gameId, numberOfPlayers) => {
  let invitationLink = null;
  let tokens;

  if (numberOfPlayers < 0) {
    const botUsername = "ludo_miniApp_bot";

     invitationLink = `https://t.me/${botUsername}?startapp=game_${gameId}`;
  }

  if (numberOfPlayers === 2 || numberOfPlayers === -2) {
    tokens = [
      { id: 1, position: -1, color: "red" },
      { id: 2, position: -1, color: "red" },
      { id: 3, position: -1, color: "red" },
      { id: 4, position: -1, color: "red" },
      { id: 5, position: -1, color: "yellow" },
      { id: 6, position: -1, color: "yellow" },
      { id: 7, position: -1, color: "yellow" },
      { id: 8, position: -1, color: "yellow" },
    ];
  } else {
    tokens = [
      { id: 1, position: -1, color: "red" },
      { id: 2, position: -1, color: "red" },
      { id: 3, position: -1, color: "red" },
      { id: 4, position: -1, color: "red" },
      { id: 5, position: -1, color: "blue" },
      { id: 6, position: -1, color: "blue" },
      { id: 7, position: -1, color: "blue" },
      { id: 8, position: -1, color: "blue" },
      { id: 9, position: -1, color: "yellow" },
      { id: 10, position: -1, color: "yellow" },
      { id: 11, position: -1, color: "yellow" },
      { id: 12, position: -1, color: "yellow" },
      { id: 13, position: -1, color: "green" },
      { id: 14, position: -1, color: "green" },
      { id: 15, position: -1, color: "green" },
      { id: 16, position: -1, color: "green" },
    ];
  }

  setGameState(gameId, {
    game_id: gameId,
    last_dice_value: 1,
    game_status: "waitingForPlayer",
    turn_status: "waitingForRoll",
    current_turn: "red",
    winner: null,
    players: [],
    tokens: tokens,
    number_of_players: numberOfPlayers > 0 ? numberOfPlayers : -numberOfPlayers,
    invitationLink: invitationLink,
    game_mode: numberOfPlayers > 0 ? "global" : "friendly",
    inline_message_id: null,
  });

  return getGameState(gameId);
};

const findPlayerGame = (playerId) => {
  console.log(playerId);
  return getAllGames().find((game) => {
    console.log(game);
    return game.players?.some(
      (p) => p.telegram_id === playerId && p.player_status === "online",
    );
  });
};

const findPlayerInfoInGame = (gameId, playerId) =>
  getGameState(gameId)?.players.find((p) => p.telegram_id === playerId);

// export کردن
module.exports = {
  getGameState,
  setGameState,
  deleteGameState: (gameId) => activeGames.delete(gameId),
  updateGameState,
  getAllGames,
  hasGame: (gameId) => activeGames.has(gameId),
  addPlayerToGameState,
  createGameInGameState,
  findPlayerGame,
  findPlayerInfoInGame,
};
