const locks = new Map();

async function joinGameQueue(numberOfPlayers, callback) {
  const currentLock = locks.get(numberOfPlayers) || Promise.resolve();

  let release;

  const nextLock = new Promise((resolve) => {
    release = resolve;
  });

  locks.set(
    numberOfPlayers,
    currentLock.then(() => nextLock),
  );

  await currentLock;

  try {
    return await callback();
  } finally {
    release();

    if (locks.get(numberOfPlayers) === nextLock) {
      locks.delete(numberOfPlayers);
    }
  }
}

module.exports = {
   joinGameQueue,
};
