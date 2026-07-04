const { createInterval } = require("timerider");
const { updateGameState } = require("../database/games");
const { updateLobbyMessage } = require("../../bot");

const initialState = require("../models/initialState");
const {
  TOW_PLAYER_COLORS,
  FOUR_PLAYER_COLORS,
} = require("../constants/gameConfig");
const time = 10;
const activeTimers = new Map();

function startTimer(socket, io) {
  console.log("timer started for game:", socket.data.gameId);

  // اگر تایمر قبلی وجود داره، اول پاکش کن
  if (activeTimers.has(socket.data.gameId)) {
    const oldTimer = activeTimers.get(socket.data.gameId);
    if (oldTimer && typeof oldTimer.clear === "function") {
      oldTimer.clear();
    }
    activeTimers.delete(socket.data.gameId);
  }

  const timer = createInterval(async () => {
    let game = initialState.getGameState(socket.data.gameId);

    // ⭐ بررسی کن بازی تموم شده یا نه
    if (game.game_status === "finished") {
      console.log(
        `Game ${socket.data.gameId} already finished, stopping timer`,
      );
      const activeTimer = activeTimers.get(socket.data.gameId);
      if (activeTimer && typeof activeTimer.clear === "function") {
        activeTimer.clear();
      }
      activeTimers.delete(socket.data.gameId);
      return;
    }

    let colorIdx =
      game.number_of_players === 4
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
    initialState.updateGameState(socket.data.gameId, {
      players: updatedPlayers,
    });
    game = initialState.getGameState(socket.data.gameId);
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
      initialState.updateGameState(socket.data.gameId, {
        players: updatedPlayers,
      });
      game = initialState.getGameState(socket.data.gameId);
      // شمارش تعداد بازیکنان آفلاین
      const offlineCount = updatedPlayers.filter(
        (p) => p.player_status === "offline",
      ).length;

      // اگر 3 نفر آفلاین شدند
      if (
        game.number_of_players === 4 ? offlineCount === 3 : offlineCount === 1
      ) {
        const onlinePlayer = updatedPlayers.find(
          (p) => p.player_status === "online",
        );

        if (onlinePlayer) {
          console.log(
            `Game ${socket.data.gameId} finished, winner: ${onlinePlayer.username}`,
          );

          // اتمام بازی
          initialState.updateGameState(socket.data.gameId, {
            game_status: "finished",
            winner: onlinePlayer,
            players: updatedPlayers,
          });
          updateLobbyMessage(socket.data.gameId);

          const winnerGameState = initialState.getGameState(socket.data.gameId);
          await updateGameState(
            socket.data.gameId,
            {
              game_status: "finished",
              players: winnerGameState.players,

              winner: onlinePlayer,
              end_at: new Date(),
            },
            winnerGameState.game_mode,
          );

          // ⭐ پاک کردن تایمر

          stopTimer(socket.data.gameId);
          // فرستادن به کلاینت
          io.to(socket.data.gameId).emit(
            "game_finished",
            winnerGameState.winner,
          );
          initialState.deleteGameState(socket.data.gameId);
        }
        return; // مهم: خارج شدن از تابع
      }

      // به‌روزرسانی بازی بعد از آفلاین کردن
      game = initialState.getGameState(socket.data.gameId);
    }

    // پیدا کردن نفر بعدی (که آفلاین نباشد)
    const currentColorsList =
      game.number_of_players === 4 ? FOUR_PLAYER_COLORS : TOW_PLAYER_COLORS;
    let nextColorIdx = colorIdx;
    let nextPlayer = null;

    // حداکثر به تعداد کل بازیکنان می‌گردیم تا در صورت بروز هر مشکلی در حلقه بی‌نهایت گیر نکنیم
    for (let i = 0; i < game.number_of_players; i++) {
      nextColorIdx = (nextColorIdx + 1) % game.number_of_players;
      const nextColor = currentColorsList[nextColorIdx];

      // پیدا کردن شیء بازیکن متناظر با این رنگ
      nextPlayer = updatedPlayers.find((p) => p.color === nextColor);

      // اگر بازیکن وجود داشت و آفلاین نبود، همین نوبت بعدی است
      if (nextPlayer && nextPlayer.player_status !== "offline") {
        break;
      }
    }

    // اگر بازیکن آنلاین پیدا شد (که قطعاً با توجه به شروط بالا حداقل یک نفر هست)
    const nextTurnColor = nextPlayer
      ? nextPlayer.color
      : currentColorsList[nextColorIdx];

    // به‌روزرسانی نوبت در وضعیت بازی
    initialState.updateGameState(socket.data.gameId, {
      current_turn: nextTurnColor,
      turn_status: "waitingForRoll",
      players: updatedPlayers,
    });
    const cleanTurnData = {
      currentTurn: nextTurnColor,
      turnStatus: "waitingForRoll",
      // فرستادن اطلاعات غیبت‌ها و وضعیت آنلاین/آفلاین بازیکن‌ها برای به‌روزرسانی UI فرانت
      playersStatus: updatedPlayers.map((p) => ({
        userId: socket.data.telegramId,
        color: p.color,
        playerStatus: p.player_status,
        numberOfAbsences: p.numberOfAbsences,
      })),
    };
    game = initialState.getGameState(socket.data.gameId);
    io.to(socket.data.gameId).emit("times_up", cleanTurnData);
    console.log(
      `Turn changed to ${
        game.number_of_players === 4
          ? FOUR_PLAYER_COLORS[(colorIdx + 1) % game.number_of_players]
          : TOW_PLAYER_COLORS[(colorIdx + 1) % game.number_of_players]
      } for game ${socket.data.gameId}`,
    );
  }, time * 1000);

  activeTimers.set(socket.data.gameId, timer);
  console.log(
    `Timer set for game ${socket.data.gameId}, active timers: ${activeTimers.size}`,
  );
}

function resetTimer(socket, io) {
  console.log(`Resetting timer for game ${socket.data.gameId}`);

  const timer = activeTimers.get(socket.data.gameId);
  if (timer) {
    if (typeof timer.clear === "function") {
      timer.clear(); // پاک کردن تایمر قدیمی
    } else if (typeof timer === "object" && timer !== null) {
      // اگر تایمر قدیمی setInterval عادی بود
      clearInterval(timer);
    }
  }
  activeTimers.delete(socket.data.gameId);
  startTimer(socket, io);
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
