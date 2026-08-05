const { createInterval } = require("timerider");

const initialState = require("../models/initialState");
const {
  TWO_PLAYER_COLORS,
  FOUR_PLAYER_COLORS,
} = require("../constants/gameConfig");
const time = 10;
const activeTimers = new Map();

function startTimer(socket, io) {

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
        : TWO_PLAYER_COLORS.indexOf(game.current_turn);
    let delayedPlayer = null;
    let updatedPlayers = game.players.map((p) => {
      if (p.color === game.current_turn) {
        delayedPlayer = { ...p, number_of_absences: p.number_of_absences + 1 };
        return delayedPlayer;
      }
      return p;
    });
    initialState.updateGameState(socket.data.gameId, {
      players: updatedPlayers,
    });
    game = initialState.getGameState(socket.data.gameId);
    // ⭐ اصلاح: تعداد缺席 باید === 2 باشه (چون یک بار缺席 شده، الان دفعۀ دوم)
    if (delayedPlayer && delayedPlayer.number_of_absences === 3) {
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
          const { finishGame } = require("../helpers/game_helpers");

          // اتمام بازی
          await finishGame(
            socket.data.gameId,
            onlinePlayer,
            game.game_type,
            io,
          );
        }
        return; // مهم: خارج شدن از تابع
      }

      // به‌روزرسانی بازی بعد از آفلاین کردن
      game = initialState.getGameState(socket.data.gameId);
    }

    // پیدا کردن نفر بعدی (که آفلاین نباشد)
    const currentColorsList =
      game.number_of_players === 4 ? FOUR_PLAYER_COLORS : TWO_PLAYER_COLORS;
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
        number_of_absences: p.number_of_absences,
      })),
    };
    game = initialState.getGameState(socket.data.gameId);
    io.to(socket.data.gameId).emit("times_up", cleanTurnData);

  }, time * 1000);

  activeTimers.set(socket.data.gameId, timer);

}

function resetTimer(socket, io) {

  const timer = activeTimers.get(socket.data.gameId);
  if (timer) {
    if (typeof timer.clear === "function") {
      timer.clear(); // پاک کردن تایمر قدیمی
    } else if (typeof timer === "object") {
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
  }
}



function stopTimer(gameId) {

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


module.exports = {
  startTimer,
  resetTimer,
  pauseTimer,
  stopTimer,
};
