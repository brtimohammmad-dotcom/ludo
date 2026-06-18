const gameMessages = new Map(); // gameId -> message info

const getGameMessage = (gameId) => gameMessages.get(gameId);

const setGameMessage = (gameId, data) => {
  gameMessages.set(gameId, data);
  return data;
};

const updateGameMessage = (gameId, updates) => {
  const current = gameMessages.get(gameId);

  if (!current) return null;

  const updated = { ...current, ...updates };

  gameMessages.set(gameId, updated);

  return updated;
};

module.exports = {
  gameMessages,
  getGameMessage,
  setGameMessage,
  updateGameMessage,
};
