const { getOrCreatePlayer } = require("../database/players");
const initialState = require("../models/initialState");
const { getUserAvatarUrl } = require("../../bot");
const { updatePlayerAvatar } = require("../database/players");
const { uploadAvatarToSupabase } = require("../database/storage");

async function handleAuth(initData, socket) {
  const isLocal = process.env.RENDER !== "true";

  try {
    let user;

    if (!isLocal) {
      const { validate, parse } = require("@tma.js/init-data-node");
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

    console.log(
      `User authorized successfully: ${user.first_name} (${user.id})`,
    );

    // ۱. گرفتن یا ساخت بازیکن در دیتابیس
    let player = await getOrCreatePlayer(user.id, user.first_name);
    if (!player) {
      console.log("Player not found or database lag!");
      return socket.emit("initial_player", {
        error: "Player initialization failed",
      });
    }

    // ۲. مدیریت و هماهنگ‌سازی عکس پروفایل (آواتار)
    let avatarUrl = player.avatar_url;
    const now = new Date();

    if (!isLocal) {
      const oneDayAgo = new Date(now - 24 * 60 * 60 * 1000);

      // اگر آواتار ندارد یا بیشتر از ۲۴ ساعت از آخرین آپدیت گذشته است
      if (
        !player.avatar_url ||
        !player.last_avatar_update ||
        new Date(player.last_avatar_update) < oneDayAgo
      ) {
        console.log(
          `[Avatar Sync] Fetching fresh avatar from Telegram for ${user.id}...`,
        );
        const telegramFileLink = await getUserAvatarUrl(user.id);

        if (telegramFileLink) {
          const supabaseAvatarUrl = await uploadAvatarToSupabase(
            user.id,
            telegramFileLink,
          );
          if (supabaseAvatarUrl) {
            avatarUrl = supabaseAvatarUrl;
            player.avatar_url = avatarUrl;
            player.last_avatar_update = now;

            // آپدیت دیتابیس با لینک دائمی استوریج خودت
            await updatePlayerAvatar(user.id, avatarUrl, now).catch((err) => {
              console.error("[Database Avatar Sync Error]:", err.message);
            });
          }

          // آپدیت آنی دیتابیس سوپابیس با لینک زنده تلگرام
          await updatePlayerAvatar(user.id, avatarUrl, now).catch((err) => {
            console.error("[Database Avatar Sync Error]:", err.message);
          });
        }
      }
    } else {
      avatarUrl = player.avatar_url || "https://placeholder.com/avatar.png";
    }

    // ذخیره در دیتای سوکت
    socket.data.telegramId = player.telegram_id;
    socket.data.firstName = player.username;
    socket.data.coin = player.coin;
    socket.data.rewardStreak = player.reward_streak;
    socket.data.lastClaimDate = player.last_claim_date;
    socket.data.avatarUrl = avatarUrl; // ذخیره در سوکت برای دسترسی‌های بعدی

    // ۳. بررسی منطق دیلی ریوارد
    const lastClaim = socket.data.lastClaimDate
      ? new Date(socket.data.lastClaimDate)
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

    // الحاق آواتار و وضعیت جایزه روزانه به شیء نهایی پلیر جهت ارسال به فرانت
    player = {
      ...player,
      avatar_url: avatarUrl,
      can_claim_daily_reward: canClaimDailyReward,
    };

    socket.data.canClaimDailyReward = canClaimDailyReward;

    // ارسال اطلاعات کامل (شامل لینک عکس جدید) به فلاتر
    socket.emit("initial_player", player);
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
          return { ...currentPlayer };
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
      return { game: null, player: player };
    }
  } else {
    return { game: null, player: player };
  }
}

module.exports = { handleAuth, hasExistGame };
