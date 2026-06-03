const locks = new Map();

async function joinGameQueue(gameMode, callback) {
  const currentLock = locks.get(gameMode) || Promise.resolve();

  let release;

  const nextLock = new Promise((resolve) => {
    release = resolve;
  });

  locks.set(
    gameMode,
    currentLock.then(() => nextLock),
  );

  await currentLock;

  try {
    return await callback();
  } finally {
    release();

    if (locks.get(gameMode) === nextLock) {
      locks.delete(gameMode);
    }
  }
}

module.exports = {
   joinGameQueue,
};
