const {
    getOrCreatePlayer,
    updatePlayerFullInfo,
} = require("../database/players");
const initialState = require("../models/initialState");
const {getUserAvatarUrl} = require("../../bot");
const {uploadAvatarToSupabase} = require("../database/storage");
const {getUserVpnConfigs} = require("../services/vpnService");

async function handleAuth(initData, socket) {
    const isLocal = process.env.RENDER !== "true";

    try {
        let user;

        if (!isLocal) {
            const {validate, parse} = require("@tma.js/init-data-node");
            validate(initData, process.env.BOT_TOKEN);
            const parsedData = parse(initData);
            user = parsedData.user;

            if (!user || !user.id) {
                return socket.emit("initial_player", {
                    error: "Invalid Telegram initData",
                });
            }
        } else {
            user = initData;
        }

        // ۱. گرفتن یا ساخت اولیه بازیکن در دیتابیس
        let player = await getOrCreatePlayer(user.id, user.first_name);
        if (!player) {
            console.log("Player not found or database lag!");
            return socket.emit("initial_player", {
                error: "Player initialization failed",
            });
        }

        const now = new Date();

        // -------------------------------------------------------------
        // ۲. بررسی و به‌روزرسانی آواتار کاربر
        // -------------------------------------------------------------
        let avatarUrl = player.avatar_url;
        if (!isLocal) {
            const oneDayAgo = new Date(now - 24 * 60 * 60 * 1000);

            if (
                !player.avatar_url ||
                !player.last_avatar_update ||
                new Date(player.last_avatar_update) < oneDayAgo
            ) {
                const telegramFileLink = await getUserAvatarUrl(user.id);

                if (telegramFileLink) {
                    const supabaseAvatarUrl = await uploadAvatarToSupabase(
                        user.id,
                        telegramFileLink,
                    );
                    if (supabaseAvatarUrl) {
                        avatarUrl = supabaseAvatarUrl;
                        await updatePlayerFullInfo(user.id, {
                            avatar_url: avatarUrl,
                            last_avatar_update: now,
                        });
                    }
                }
            }
        } else {
            avatarUrl = player.avatar_url || "https://placeholder.com/avatar.png";
        }

        // -------------------------------------------------------------
        // ۳. دریافت لیست کامل کانفیگ‌های VPN مستقیماً از API
        // -------------------------------------------------------------
        const vpnData = await getUserVpnConfigs(user.id);

        // -------------------------------------------------------------
        // ۴. بررسی منطق جایزه روزانه
        // -------------------------------------------------------------
        const lastClaim = player.last_claim_date
            ? new Date(player.last_claim_date)
            : null;
        let canClaimDailyReward = false;

        if (!lastClaim) {
            canClaimDailyReward = true;
        } else {
            const isSameDay =
                now.getDate() === lastClaim.getDate() &&
                now.getMonth() === lastClaim.getMonth() &&
                now.getFullYear() === lastClaim.getFullYear();

            canClaimDailyReward = !isSameDay;
        }

        // -------------------------------------------------------------
        // ۵. ذخیره اطلاعات در حافظه سوکت
        // -------------------------------------------------------------
        socket.data.telegramId = player.telegram_id;
        socket.data.firstName = player.username;
        socket.data.coin = player.coin;
        socket.data.rewardStreak = player.reward_streak;
        socket.data.lastClaimDate = player.last_claim_date;
        socket.data.avatarUrl = avatarUrl;
        socket.data.wins = player.wins;
        socket.data.losses = player.losses;
        socket.data.canClaimDailyReward = canClaimDailyReward;
        socket.data.welcomeGift = player.welcome_gift;
        socket.data.vpnConfigs = vpnData.configs || [];

        // -------------------------------------------------------------
        // ۶. ارسال شیء نهایی یکپارچه به فلاتر
        // -------------------------------------------------------------
        const initialPayload = {
            ...player,
            avatar_url: avatarUrl,
            can_claim_daily_reward: canClaimDailyReward,
            // لیست کامل همه کانفیگ‌ها و اطلاعات کلی برای فرانت‌‌اند
            vpn_configs: vpnData.configs || [],
        };

        socket.emit("initial_player", initialPayload);
    } catch (err) {
        console.error("Auth error:", err.message || err);
    }
}

async function hasExistGame(player, socketId) {
    const existingGame = initialState.findPlayerGame(player.telegram_id);

    if (existingGame) {
        const currentPlayer = initialState.findPlayerInfoInGame(
            existingGame.game_id,
            player.telegram_id,
        );
        if (currentPlayer && currentPlayer.player_status === "online") {
            currentPlayer.socketId = socketId;
            currentPlayer.connection_status = "connected";

            const correctPlayers = existingGame.players.map((p) => {
                if (p.telegram_id === currentPlayer.telegram_id) {
                    return {...currentPlayer};
                }
                return p;
            });
            initialState.updateGameState(existingGame.game_id, {
                players: correctPlayers,
            });
            const correctGameState = initialState.getGameState(existingGame.game_id);
            return {
                game: correctGameState,
                player: currentPlayer,
            };
        } else {
            return {game: null, player: player};
        }
    } else {
        return {game: null, player: player};
    }
}

module.exports = {handleAuth, hasExistGame};