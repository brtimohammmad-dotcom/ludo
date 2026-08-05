const userLocks = new Map();
const gameLocks = new Map();

/**
 * مکانیزم عمومی اعمال قفل انحصاری
 */
async function acquireLock(lockMap, key, callback) {
  const currentLock = lockMap.get(key) ||  Promise.resolve();
  let release;
  const nextLock = new Promise((resolve) => {
    release = resolve;
  });

  lockMap.set(
    key,
    currentLock.then(() => nextLock),
  );
  await currentLock;

  try {
    return await callback();
  } finally {
    release();
    if (lockMap.get(key) === nextLock) {
      lockMap.delete(key);
    }
  }
}

async function joinGameQueue(playerId, callback) {
  return  acquireLock(userLocks, playerId, callback);
}

async function acquireGameLock(gameId, callback) {
  return  acquireLock(gameLocks, gameId, callback);
}

module.exports = {
  joinGameQueue,
  acquireGameLock,
};
