const { createInterval } = require("timerider");
const { updateGameState } = require("../database/games");
const initialState = require("../models/initialState");
const {
  TOW_PLAYER_COLORS,
  FOUR_PLAYER_COLORS,
} = require("../constants/gameConfig");
const time = 10;
const activeTimers = new Map();

function startTimer(gameId, io) {
  console.log("timer started for game:", gameId);

  // اگر تایمر قبلی وجود داره، اول پاکش کن
  if (activeTimers.has(gameId)) {
    const oldTimer = activeTimers.get(gameId);
    if (oldTimer && typeof oldTimer.clear === "function") {
      oldTimer.clear();
    }
    activeTimers.delete(gameId);
  }

  const timer = createInterval(async () => {
    let game = initialState.getGameState(gameId);

    // ⭐ بررسی کن بازی تموم شده یا نه
    if (game.game_status === "finished") {
      console.log(`Game ${gameId} already finished, stopping timer`);
      const activeTimer = activeTimers.get(gameId);
      if (activeTimer && typeof activeTimer.clear === "function") {
        activeTimer.clear();
      }
      activeTimers.delete(gameId);
      return;
    }

    let colorIdx =
      game.game_mode === 4
        ? FOUR_PLAYER_COLORS.indexOf(game.current_turn)
        : TOW_PLAYER_COLORS.indexOf(game.current_turn);
    let delayedPlayer = null;
    let updatedPlayers = game.players.map((p) => {
      if (p.color === game.current_turn) {
        delayedPlayer = { ...p, numberOfAbsences: p.numberOfAbsences + 1 };
        return delayedPlayer;
      }
      return p;
    });
    initialState.updateGameState(gameId, { players: updatedPlayers });
    game = initialState.getGameState(gameId);
    // ⭐ اصلاح: تعداد缺席 باید === 2 باشه (چون یک بار缺席 شده، الان دفعۀ دوم)
    if (delayedPlayer && delayedPlayer.numberOfAbsences === 3) {
      console.log(
        `Player ${game.current_turn} became offline after 2 absences`,
      );

      updatedPlayers = game.players.map((p) => {
        if (p.color === game.current_turn) {
          return { ...p, player_status: "offline" };
        }
        return p;
      });
      initialState.updateGameState(gameId, { players: updatedPlayers });
      game = initialState.getGameState(gameId);
      // شمارش تعداد بازیکنان آفلاین
      const offlineCount = updatedPlayers.filter(
        (p) => p.player_status === "offline",
      ).length;

      // اگر 3 نفر آفلاین شدند
      if (game.game_mode === 4 ? offlineCount === 3 : offlineCount === 1) {
        const onlinePlayer = updatedPlayers.find(
          (p) => p.player_status === "online",
        );

        if (onlinePlayer) {
          console.log(
            `Game ${gameId} finished, winner: ${onlinePlayer.username}`,
          );

          // اتمام بازی
          initialState.updateGameState(gameId, {
            game_status: "finished",
            winner: onlinePlayer,
            players: updatedPlayers,
          });
          const winnerGameState = initialState.getGameState(gameId);
          await updateGameState(gameId, {
            game_status: "finished",
            players: JSON.stringify(winnerGameState.players),

            winner: JSON.stringify(onlinePlayer),
            end_at: new Date(),
          });

          // ⭐ پاک کردن تایمر

          stopTimer(gameId);
          // فرستادن به کلاینت
          io.to(gameId).emit("game_finished", game);
          initialState.deleteGameState(gameId);
        }
        return; // مهم: خارج شدن از تابع
      }

      // به‌روزرسانی بازی بعد از آفلاین کردن
      game = initialState.getGameState(gameId);
    }

    // پیدا کردن نفر بعدی (که آفلاین نباشد)
    let nextPlayerIndex =
      game.game_mode === 4 ? (colorIdx + 1) % 4 : (colorIdx + 1) % 2;
    let checkedCount = 0;

    while (
      game.players[nextPlayerIndex].player_status === "offline" &&
      checkedCount < game.game_mode
    ) {
      game.game_mode === 4 ? (colorIdx + 1) % 4 : (colorIdx + 1) % 2;
      checkedCount++;

      // اگر همه آفلاین شدند (ایمنی)
      if (game.game_mode) {
        console.log(`All players offline for game ${gameId}`);

        // همه آفلاین هستند، بازی را تمام کن
        const activeTimer = activeTimers.get(gameId);
        if (activeTimer && typeof activeTimer.clear === "function") {
          activeTimer.clear();
        }
        stopTimer(gameId);
        initialState.updateGameState(gameId, {
          game_status: "finished",
        });

        io.to(gameId).emit("game_aborted", { reason: "all_offline" });
        return;
      }
    }

    // به‌روزرسانی نوبت
    initialState.updateGameState(gameId, {
      current_turn:
        game.game_mode === 4
          ? FOUR_PLAYER_COLORS[(colorIdx + 1) % game.game_mode]
          : TOW_PLAYER_COLORS[(colorIdx + 1) % game.game_mode],
      turn_status: "waitingForRoll",
      players: updatedPlayers,
    });

    game = initialState.getGameState(gameId);
    io.to(gameId).emit("times_up", game);
    console.log(
      `Turn changed to ${
        game.game_mode === 4
          ? FOUR_PLAYER_COLORS[(colorIdx + 1) % game.game_mode]
          : TOW_PLAYER_COLORS[(colorIdx + 1) % game.game_mode]
      } for game ${gameId}`,
    );
  }, time * 1000);

  activeTimers.set(gameId, timer);
  console.log(
    `Timer set for game ${gameId}, active timers: ${activeTimers.size}`,
  );
}

function resetTimer(gameId, io) {
  console.log(`Resetting timer for game ${gameId}`);

  const timer = activeTimers.get(gameId);
  if (timer) {
    if (typeof timer.clear === "function") {
      timer.clear(); // پاک کردن تایمر قدیمی
    } else if (typeof timer === "object" && timer !== null) {
      // اگر تایمر قدیمی setInterval عادی بود
      clearInterval(timer);
    }
  }
  activeTimers.delete(gameId);
  startTimer(gameId, io);
}

function pauseTimer(gameId) {
  const timer = activeTimers.get(gameId);
  if (timer && typeof timer.pause === "function") {
    timer.pause();
    console.log(`Timer paused for game ${gameId}`);
  }
}

function resumeTimer(gameId) {
  const timer = activeTimers.get(gameId);
  if (timer && typeof timer.resume === "function") {
    timer.resume();
    console.log(`Timer resumed for game ${gameId}`);
  }
}

function stopTimer(gameId) {
  console.log(`Stopping timer for game ${gameId}`);

  const timer = activeTimers.get(gameId);
  if (timer) {
    if (typeof timer.clear === "function") {
      timer.clear();
    } else if (typeof timer === "number" || typeof timer === "object") {
      clearInterval(timer);
    }
    activeTimers.delete(gameId);
  }
}

function getAllActiveTimers() {
  return Array.from(activeTimers.keys());
}

module.exports = {
  startTimer,
  resetTimer,
  pauseTimer,
  resumeTimer,
  stopTimer,
  getAllActiveTimers,
};
