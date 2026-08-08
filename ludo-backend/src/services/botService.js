/**
 * بک‌اند سرویس ربات بازی لودو (کاملاً با هماهنگی initialState و gameConfig)
 */

const initialState = require("../models/initialState");
const {
    TWO_PLAYER_COLORS,
    FOUR_PLAYER_COLORS,
    LEVEL_COSTS,
} = require("../constants/gameConfig");
const { addPlayerToGameOnDatabase } = require("../database/gamePlayers");
const {
    getOrCreatePlayer,
    reduceMultiplePlayersCoin,
} = require("../database/players");
const { updateGameState } = require("../database/games");
const { startTimer } = require("./turnTimerService");
const { canActivateToken, findKickToken } = require("../logic/canMove");
const { handleRollDice, handleMoveToken } = require("./gameService");
const { updateLobbyMessage } = require("../../bot");

const BOT_FALLBACK_ENABLED =
    (process.env.BOT_FALLBACK_ENABLED || "true") !== "false";
const BOT_FALLBACK_TIMEOUT = parseInt(
    process.env.BOT_FALLBACK_TIMEOUT || "6000",
    10,
);

let botIdCounter = 1;
const nextBotId = () => -(1000000 + botIdCounter++);

// دسته بندی اسامی به همراه جنسیت
const BOT_PROFILES = {
    female: [
        "⚡ سارا", "🌟 رها", "🃏 آوا", "✨ تینا", "💎 مریم", "🌸 نسترن", "🎨 پرنیا",
        "Valkyrie", "Luna", "Astra", "Mobina_T", "Fatemeh_M", "Yasaman_R"
    ],
    male: [
        "🎯 امیر", "🔥 نیما", "🎲 مهراد", "🚀 کیان", "👑 آرش", "🦁 دانیال", "🔱 یاسین", "🔮 کامران",
        "Alex_99", "Phoenix", "Shadow_Player", "CyberKing", "DarkKnight", "Blaze", "PixelHero", "Vortex", "Maverick", "Titan",
        "Saeid_Pro", "Mohsen_7", "Reza_Khan", "Ahmad_Ludo", "Ali_Z", "Hossein_V", "Ehsan_Player", "Mahdi_G", "Arman_X", "Sina_King"
    ],
    neutral: [
        "Nova_Gamer"
    ]
};

// دریافت نام و جنسیت تصادفی
function getRandomBotIdentity() {
    const genders = ["female", "male"];
    const chosenGender = genders[Math.floor(Math.random() * genders.length)];
    const nameList = BOT_PROFILES[chosenGender];
    const username = nameList[Math.floor(Math.random() * nameList.length)];
    return { username, gender: chosenGender };
}

// ساخت لینک آواتار متناسب با جنسیت (تصاویر پرتره با کیفیت و واقعی)
// دریافت لینک آواتار متناسب با جنسیت از Supabase Storage
function getRandomAvatarUrl(gender) {
    // تولید عدد تصادفی بین ۱ تا ۳۵
    const avatarIndex = Math.floor(Math.random() * 35) + 1;

    const baseUrl = "https://ryuwzehynsandwnbucpk.supabase.co/storage/v1/object/public";

    if (gender === "female") {
        return `${baseUrl}/women%20avatars%20bot/${avatarIndex}.jpg`;
    } else {
        return `${baseUrl}/men%20avatars%20bot/${avatarIndex}.jpg`;
    }
}

// محاسبه سکه متناسب با لول بازی
function calculateBotCoins(gameLevel) {
    const baseCost = LEVEL_COSTS[gameLevel] || 100;
    const multiplier = 1.5 + Math.random() * 2.5;
    return Math.floor(baseCost * multiplier);
}

// سوکت مجازی اصلاح‌شده
function botSocket(gameId, telegramId, color) {
    return {
        id: `bot_socket_${telegramId}`,
        data: { gameId, telegramId, color, isBot: true },
        emit: () => {},
        join: () => {},
        leave: () => {},
        to: () => ({ emit: () => {} }),
    };
}

async function createBotInDatabase(botId, username, gameId, color) {
    try {
        await addPlayerToGameOnDatabase(botId, gameId, color);
    } catch (e) {
        console.error(`[Bot] DB sync error for ${botId}:`, e.message);
    }
}

function createBotPlayerObject({  color, gameLevel }) {
    const botId = nextBotId();
    const { username, gender } = getRandomBotIdentity();

    return {
        username,
        telegram_id: botId,
        coin: calculateBotCoins(gameLevel),
        color,
        player_status: "online",
        number_of_absences: 0,
        connection_status: "connected",
        avatar_url: getRandomAvatarUrl(gender), // لینک آواتار متناسب با جنسیت
        wins: Math.floor(Math.random() * 50) + 5,
        losses: Math.floor(Math.random() * 30) + 2,
        is_bot: true,
    };
}

const fallbackTimers = new Map();

function cancelFallback(gameId) {
    const timer = fallbackTimers.get(gameId);
    if (timer) {
        clearTimeout(timer);
        fallbackTimers.delete(gameId);
    }
}

async function fillRoomWithBots(gameId, io) {
    const game = initialState.getGameState(gameId);
    if (!game || game.game_status !== "waitingForPlayer") return;

    const humanCount = game.players.filter((p) => !p.is_bot).length;
    if (humanCount === 0) return;

    const colorList =
        game.number_of_players === 4
            ? FOUR_PLAYER_COLORS
            : TWO_PLAYER_COLORS;

    const usedColors = new Set(game.players.map((p) => p.color));
    const availableColors = colorList.filter((c) => !usedColors.has(c));

    const needed = game.number_of_players - game.players.length;
    if (needed <= 0) return;

    const addedPlayers = [];
    for (let i = 0; i < needed; i++) {
        const color = availableColors[i];
        if (!color) break;

        const botPlayer = createBotPlayerObject({
            gameId,
            color,
            gameLevel: game.game_level,
        });
        initialState.addPlayerToGameState(botPlayer, gameId);
        addedPlayers.push(botPlayer);

        createBotInDatabase(
            botPlayer.telegram_id,
            botPlayer.username,
            gameId,
            color,
        ).catch((e) => console.error("[Bot] DB async error:", e.message));
    }

    const freshGame = initialState.getGameState(gameId);
    if (!freshGame) return;

    console.log(
        `🤖 [Bot] Room ${gameId} filled with ${addedPlayers.length} bot(s). Total players: ${freshGame.players.length}`,
    );

    io.to(gameId).emit("game_state_update", freshGame);
    await finalizeGameStart(gameId, io);
    startBotDriver(gameId, io);
}

async function finalizeGameStart(gameId, io) {
    const game = initialState.getGameState(gameId);
    if (!game) return;

    game.game_status = "start";
    initialState.updateGameState(gameId, { game_status: "start" });

    if (game.game_type === "global") {
        const coinCost = LEVEL_COSTS[game.game_level] || 0;
        if (coinCost > 0) {
            const realPlayers = game.players.filter((p) => !p.is_bot);
            const realIds = realPlayers.map((p) => p.telegram_id);
            try {
                await reduceMultiplePlayersCoin(realIds, coinCost);
            } catch (dbError) {
                console.error("[Bot] reduce coins error:", dbError);
            }
            try {
                const sockets = await io.in(gameId).fetchSockets();
                sockets.forEach((s) => {
                    if (s.data && s.data.coin !== undefined && !s.data.isBot) {
                        s.data.coin -= coinCost;
                    }
                });
            } catch (e) {
                console.error("[Bot] fetchSockets error:", e);
            }
        }
    }

    try {
        await updateGameState(gameId, { game_status: "start" });
    } catch (e) {
        console.error("[Bot] updateGameState error:", e);
    }

    await updateLobbyMessage(gameId);
    io.to(gameId).emit("game_started");

    const firstPlayer =
        game.players.find((p) => p.color === game.current_turn) ||
        game.players[0];
    if (firstPlayer) {
        startTimer(
            botSocket(gameId, firstPlayer.telegram_id, firstPlayer.color),
            io,
        );
    }
}

function maybeScheduleFallback(gameId, io) {
    if (!BOT_FALLBACK_ENABLED) return;
    if (fallbackTimers.has(gameId)) return;

    const timer = setTimeout(async () => {
        fallbackTimers.delete(gameId);
        const game = initialState.getGameState(gameId);
        if (!game || game.game_status !== "waitingForPlayer") return;
        if (game.players.length >= game.number_of_players) return;
        await fillRoomWithBots(gameId, io);
    }, BOT_FALLBACK_TIMEOUT);

    fallbackTimers.set(gameId, timer);
}

// ---------------------------------------------------------------------
// منطق انتخاب مهره
// ---------------------------------------------------------------------
const safeStartIndexes = { red: 0, blue: 9, yellow: 18, green: 27 };

function chooseTokenToMove(gameId) {
    const game = initialState.getGameState(gameId);
    if (!game) return null;

    const dice = game.last_dice_value;
    const botTokens = game.tokens.filter((t) => t.color === game.current_turn);
    const movable = botTokens.filter((t) => canActivateToken(t, game, dice));
    if (!movable.length) return null;

    let best = movable[0];
    let bestScore = -Infinity;

    for (const token of movable) {
        const score =
            scoreTokenMove(token, game, dice) + (Math.random() - 0.5) * 4;
        if (score > bestScore) {
            bestScore = score;
            best = token;
        }
    }
    return best;
}

function scoreTokenMove(token, game, dice) {
    let score = 0;
    const target =
        token.position === -1
            ? dice === 6
                ? 0
                : -1
            : token.position + dice;

    if (token.position === -1) {
        return 140 + Math.random() * 20;
    }
    if (findKickToken(token, dice, game.tokens)) {
        score += 250;
    }
    if (target === 39) {
        score += 320;
    }
    score += target * 3;

    const baseIndex = safeStartIndexes[token.color] || 0;
    const globalIdx = (baseIndex + target) % 36;
    if (Object.values(safeStartIndexes).includes(globalIdx)) {
        score += 40;
    }

    score += (token.position % 3) * 2;
    return score;
}

// ---------------------------------------------------------------------
// درایور نوبت ربات‌ها
// ---------------------------------------------------------------------
const botDrivers = new Map();
const botBusy = new Set();

const randomDelay = (min, max) => min + Math.random() * (max - min);

function isBotTurn(game, color) {
    return game.players.some((p) => p.color === color && p.is_bot);
}

function startBotDriver(gameId, io) {
    if (botDrivers.has(gameId)) return;
    if (!BOT_FALLBACK_ENABLED) return;

    const interval = setInterval(() => {
        const game = initialState.getGameState(gameId);
        if (!game || game.game_status !== "start") {
            stopBotDriver(gameId);
            return;
        }

        if (botBusy.has(gameId)) return;

        const currentTurnColor = game.current_turn;
        if (!isBotTurn(game, currentTurnColor)) return;

        const botPlayer = game.players.find(
            (p) => p.color === currentTurnColor && p.is_bot,
        );

        if (!botPlayer) return;

        if (game.turn_status === "waitingForRoll") {
            botBusy.add(gameId);
            const delay = randomDelay(800, 1800);
            setTimeout(() => {
                try {
                    const latestGame = initialState.getGameState(gameId);
                    if (
                        latestGame &&
                        latestGame.current_turn === currentTurnColor &&
                        latestGame.turn_status === "waitingForRoll"
                    ) {
                        handleRollDice(
                            botSocket(
                                gameId,
                                botPlayer.telegram_id,
                                botPlayer.color,
                            ),
                            io,
                            () => {},
                        );
                    }
                } catch (err) {
                    console.error("[Bot] roll error:", err);
                } finally {
                    setTimeout(() => botBusy.delete(gameId), 400);
                }
            }, delay);
        } else if (game.turn_status === "waitingForMove") {
            botBusy.add(gameId);
            const delay = randomDelay(600, 1400);
            setTimeout(() => {
                try {
                    const latestGame = initialState.getGameState(gameId);
                    if (
                        latestGame &&
                        latestGame.current_turn === currentTurnColor &&
                        latestGame.turn_status === "waitingForMove"
                    ) {
                        const token = chooseTokenToMove(gameId);
                        if (token) {
                            handleMoveToken(
                                botSocket(
                                    gameId,
                                    botPlayer.telegram_id,
                                    botPlayer.color,
                                ),
                                token,
                                io,
                                () => {},
                            );
                        }
                    }
                } catch (err) {
                    console.error("[Bot] move error:", err);
                } finally {
                    setTimeout(() => botBusy.delete(gameId), 400);
                }
            }, delay);
        }
    }, 500);

    botDrivers.set(gameId, interval);
}

function stopBotDriver(gameId) {
    const interval = botDrivers.get(gameId);
    if (interval) {
        clearInterval(interval);
        botDrivers.delete(gameId);
    }
    botBusy.delete(gameId);
}

function stopAllBotDrivers() {
    botDrivers.forEach((interval) => clearInterval(interval));
    botDrivers.clear();
    botBusy.clear();
    fallbackTimers.forEach((timer) => clearTimeout(timer));
    fallbackTimers.clear();
}

module.exports = {
    maybeScheduleFallback,
    cancelFallback,
    startBotDriver,
    stopBotDriver,
    stopAllBotDrivers,
    fillRoomWithBots,
};