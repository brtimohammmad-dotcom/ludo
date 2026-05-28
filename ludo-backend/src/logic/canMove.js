const initialState = require("../models/initialState");
const playerStartIndex = {
  red: 0, // قرمز
  blue: 9, // آبی
  yellow: 18, // زرد
  green: 27, // سبز
};
const mainTrackLength = 36;
const maxTrackPosition = 35;

function globalPlayerIndex(pathIndex, playerColor) {
  return (playerStartIndex[playerColor] + pathIndex) % mainTrackLength;
}
function findKickToken(liveToken, diceValue, tokens) {
  const targetPosition = liveToken.position + diceValue;
  if (targetPosition > maxTrackPosition) {
    return null;
  }
  const kickedToken = tokens.find((token) => {
    // توکن حریف باید در مسیر اصلی باشد (0 تا 35) و نه در مسیر رنگی خودش (36 تا 39)
    const isOpponentTokenOnMainTrack =
      token.color !== liveToken.color &&
      token.position >= 0 &&
      token.position <= maxTrackPosition;
    const isTargetOnMainTrack =
      targetPosition >= 0 && targetPosition <= maxTrackPosition;

    if (!isOpponentTokenOnMainTrack || !isTargetOnMainTrack) {
      return false;
    }
    let globalLiveTokenPathIndex;
    const globalKickedTokenPathIndex = globalPlayerIndex(
      token.position,
      token.color,
    );
    if (liveToken.position === -1) {
      globalLiveTokenPathIndex = globalPlayerIndex(0, liveToken.color);
    } else {
      globalLiveTokenPathIndex = globalPlayerIndex(
        targetPosition,
        liveToken.color,
      );
    }
    if (globalLiveTokenPathIndex === globalKickedTokenPathIndex) {
      return token;
    }
    return null;
  });
  return kickedToken;
}

function canActivateToken(liveToken, gameState, diceValue) {
  if(liveToken.color!==gameState.current_turn){
    return false;
  }
  const targetPathIndex = liveToken.position + diceValue;
  let canNotActivateToken = false;
  canNotActivateToken = gameState.tokens.some((otherToken) => {
    return (
      isCellOccupiedBySamePlayer(otherToken, liveToken, diceValue) ||
      isCellHasTokenInSafeCell(otherToken, liveToken, diceValue) ||
      targetPathIndex > 39 ||
      liveToken.color !== gameState.current_turn
    );
  });
  return (
    (!canNotActivateToken && liveToken.position !== -1) ||
    (liveToken.position === -1 && !canNotActivateToken && diceValue === 6)
  );
}
function isCellOccupiedBySamePlayer(otherToken, liveToken, diceValue) {
  const targetPathIndex = liveToken.position + diceValue;
  const isSameToken =
    liveToken.id !== otherToken.id && liveToken.color === otherToken.color;
  return (
    (isSameToken &&
      otherToken.position === 0 &&
      liveToken.position === -1 &&
      diceValue === 6) ||
    (isSameToken &&
      otherToken.position === targetPathIndex &&
      liveToken.position !== -1 &&
      otherToken.position !== 39)
  );
}
function isCellHasTokenInSafeCell(otherToken, liveToken, diceValue) {
  if (otherToken.color === liveToken.color) {
    return false;
  }
  // محاسبه ایندکس مقصد مهره در مسیر خودش (قبل از تبدیل به ایندکس سراسری)
  const targetPathIndex =
    liveToken.position === -1 ? 0 : liveToken.position + diceValue;

  // اگر مقصد روی مسیر اصلی نیست، اصلاً خانه امن حریف محسوب نمی‌شود
  if (targetPathIndex < 0 || targetPathIndex > maxTrackPosition) {
    return false;
  }

  // تبدیل ایندکس مقصد به ایندکس سراسری (با در نظر گرفتن دور زدن مسیر)
  const globalTargetPathIndex = globalPlayerIndex(
    targetPathIndex,
    liveToken.color,
  );
  return (
    globalTargetPathIndex === playerStartIndex[otherToken.color] &&
    otherToken.position === 0
  );
}
module.exports = { canActivateToken, findKickToken };
