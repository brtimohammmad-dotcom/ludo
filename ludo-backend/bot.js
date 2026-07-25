const { Telegraf, Markup } = require("telegraf");
const initialState = require("./src/models/initialState");
const {
  setGameMessage,
  getGameMessage,
} = require("./src/models/gameMessageStore");

const bot = new Telegraf(
  process.env.BOT_TOKEN
);
const WEB_APP_URL = "https://ludo-tecb.onrender.com";
const PHOTO_FILE_ID =
  "AgACAgIAAxkBAAMJamTPuwINIBC30twypUjsgBSFbDgAAmkgaxvCqylL-GzRmOLntngBAAMCAANzAAM9BA";

// دستور استارت ربات در چت خصوصی
bot.start((ctx) => {
  return ctx.replyWithPhoto(PHOTO_FILE_ID, {
    caption: "🎮 Welcome to Ludo",
    ...Markup.inlineKeyboard([
      [Markup.button.webApp("🎲 Play Now", WEB_APP_URL)],
      [Markup.button.switchToChat("📢 Share with Friends", "share_bot")],
    ]),
  });
});

// مدیریت اینلاین کوئری‌ها (اصلاح شده به حالت Article برای ارسال تک‌کلیکه)
bot.on("inline_query", async (ctx) => {
  try {
    const query = ctx.inlineQuery.query;

    // ۱. اشتراک‌گذاری عمومی ربات (به صورت متنی و سریع)
    if (query === "share_bot") {
      return await ctx.answerInlineQuery([
        {
          type: "article",
          id: "share_main_bot",
          title: "🎮 Play Ludo Mini App",
          description: "Invite your friends to play Ludo together!",
          input_message_content: {
            message_text: `🎲 *Let's Play Ludo!*\n\nHey! I'm playing Ludo right inside Telegram. \nClick the button below to join the game and challenge me! 🚀`,
            parse_mode: "Markdown",
            disable_web_page_preview: false, // اگر لینک عکسی داری می‌توانی اینجا اضافه کنی
          },
          reply_markup: {
            inline_keyboard: [
              [
                {
                  text: "🎲 Play Now",
                  url: "https://t.me/LudoRushBot?startapp=main",
                },
              ],
            ],
          },
        },
      ]);
    }

    if (!query.startsWith("game_")) {
      return await ctx.answerInlineQuery([]);
    }

    const gameId = query.replace("game_", "");
    const game = initialState.getGameState(gameId);
    if (!game) {
      return await ctx.answerInlineQuery([]);
    }
    const joinUrl = `https://t.me/LudoRushBot?startapp=game_${gameId}`;

    // ۲. ارسال پیام دعوت بازی دوستانه (اصلاح شده به Article)
    return await ctx.answerInlineQuery([
      {
        type: "article",
        id: gameId,
        title: "🎲 Invite Friends to Ludo",
        description: `Click here to send invitation (${game.players.length}/${game.number_of_players} joined)`,
        input_message_content: {
          message_text: `🎲 *Ludo Friendly Match*\n\n👥 *Players:* ${game.players.length}/${game.number_of_players}\n\n🟢 ${ctx.from.first_name}\n\n⏳ Waiting for ${game.number_of_players - game.players.length} more player${game.number_of_players - game.players.length > 1 ? "s" : ""}...`,
          parse_mode: "Markdown",
        },
        reply_markup: {
          inline_keyboard: [
            [
              {
                text: `▶️ Play Game (${game.players.length}/${game.number_of_players} joined)`,
                url: joinUrl,
              },
            ],
          ],
        },
      },
    ]);
  } catch (error) {
    if (error.description && error.description.includes("query is too old")) {
      console.log(`[Inline Query] Timeout or invalid query ID. Ignored.`);
    } else {
      console.error("[Inline Query Error]:", error);
    }
  }
});

bot.on("chosen_inline_result", async (ctx) => {
  const gameId = ctx.chosenInlineResult.result_id;
  const inlineMessageId = ctx.chosenInlineResult.inline_message_id;

  if (!inlineMessageId) {
    console.log("NO inline_message_id:", ctx.chosenInlineResult);
    return;
  }
  setGameMessage(gameId, {
    inline_message_id: inlineMessageId,
  });
});

const updateLobbyMessage = async (gameId) => {
  try {
    const game = initialState.getGameState(gameId);
    const message = getGameMessage(gameId);

    if (!game || !message?.inline_message_id) return;

    const playersList = game.players
      .map((player) => `🟢 ${player.username || player.first_name}`)
      .join("\n");

    const playersCount = game.players.length;
    const maxPlayers = game.number_of_players;

    const text =
      game.game_status === "start"
        ? `🎲 *Ludo Friendly Match*\n\n👥 *Players:* ${playersCount}/${maxPlayers}\n\n${playersList}\n\n🔥 *All players are ready!*\n\n🚀 The match is now in progress.`
        : game.game_status === "finished"
          ? `🏆 *Match Complete*\n\n👥 *Players:* ${playersCount}/${maxPlayers}\n\n${playersList}\n\n🎉 *${game.winner ? game.winner.username : "Someone"}* is the winner!\n\nThanks for joining the game.`
          : game.game_status === "cancel"
            ? `⚠️ *Match Cancelled*\n\n👥 *Players:* ${playersCount}/${maxPlayers}\n\n${playersList}\n\nThe lobby has been closed.`
            : `🎲 *Ludo Friendly Match*\n\n👥 *Players:* ${playersCount}/${maxPlayers}\n\n${playersList}\n\n🎯 Waiting for ${maxPlayers - playersCount} more player${maxPlayers - playersCount > 1 ? "s" : ""} to join...`;

    const joinUrl = `https://t.me/LudoRushBot?startapp=game_${gameId}`;

    const replyMarkup =
      game.game_status === "finished" ||
      game.game_status === "cancel" ||
      game.game_status === "start"
        ? {
            inline_keyboard: [
              [
                {
                  text: `Play Ludo`,
                  url: "https://t.me/LudoRushBot?startapp",
                },
              ],
            ],
          }
        : {
            inline_keyboard: [
              [
                {
                  text: `▶️ Join Game (${playersCount}/${maxPlayers})`,
                  url: joinUrl,
                },
              ],
            ],
          };

    // تغییر متد از editMessageCaption به editMessageText چون دیگر عکسی در کار نیست
    await bot.telegram
      .editMessageText(undefined, undefined, message.inline_message_id, text, {
        reply_markup: replyMarkup,
        parse_mode: "Markdown",
      })
      .catch((tgError) => {
        if (
          tgError.description &&
          tgError.description.includes("message is not modified")
        ) {
          console.log(
            `[Lobby Sync] Message unchanged for game ${gameId}. Update skipped.`,
          );
        } else {
          console.error(
            "[Telegram API Error]:",
            tgError.description || tgError,
          );
        }
      });
  } catch (globalError) {
    console.error("[Global Lobby Update Error]:", globalError);
  }
};
// تابع کمکی برای گرفتن لینک مستقیم عکس پروفایل کاربر از تلگرام
const getUserAvatarUrl = async (userId) => {
  try {
    // ۱. گرفتن لیست عکس‌های پروفایل (فقط آخرین آلبوم عکس)
    const photos = await bot.telegram.getUserProfilePhotos(userId, {
      limit: 1,
    });

    if (!photos || photos.total_count === 0) {
      return null; // کاربر عکس پروفایل ندارد
    }

    // ۲. انتخاب بالاترین کیفیت (آخرین سایز در آرایه)
    const photoSizes = photos.photos[0];
    const fileId = photoSizes[photoSizes.length - 1].file_id;

    // ۳. گرفتن لینک مستقیم و زنده فایل از سرورهای تلگرام
    const fileLink = await bot.telegram.getFileLink(fileId);

    // خروجی متد getFileLink در نسخه‌های مختلف تله‌گراف ممکنه شیء URL باشه، پس href رو می‌گیریم
    return fileLink.href || fileLink;
  } catch (error) {
    console.error(
      `[Avatar Fetch Error] Failed for user ${userId}:`,
      error.message,
    );
    return null;
  }
};
module.exports = { bot, updateLobbyMessage, getUserAvatarUrl };
