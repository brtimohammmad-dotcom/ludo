const { Telegraf, Markup } = require("telegraf");
const initialState = require("./src/models/initialState");
const {
  setGameMessage,
  getGameMessage,
} = require("./src/models/gameMessageStore");

const bot = new Telegraf(
  process.env.BOT_TOKEN || "8780116886:AAEkCv3L3WVnHIhI7fvOPMmj1mSe2QWz9Ho",
);

const WEB_APP_URL = "https://ludo-tecb.onrender.com";
// شناسه ثابت عکس بنر لودو
const PHOTO_FILE_ID =
  "AgACAgQAAxkBAANWaj7CJA8BUAYAAa-OFtVJ7M4hjQ4qAAMOaxthRfBR1YyGsvn7DdkBAAMCAAN4AAM8BA";

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

// مدیریت اینلاین کوئری‌ها (اشتراک‌گذاری)
bot.on("inline_query", async (ctx) => {
  const query = ctx.inlineQuery.query;

  // ۱. اشتراک‌گذاری عمومی ربات با عکس
  if (query === "share_bot") {
    return ctx.answerInlineQuery([
      {
        type: "photo",
        id: "share_main_bot",
        photo_file_id: PHOTO_FILE_ID,
        title: "🎮 Play Ludo Mini App",
        description: "Invite your friends to play Ludo together!",
        caption: `🎲 *Let's Play Ludo!* Hey! I'm playing Ludo right inside Telegram. \nClick the button below to join the game and challenge me! 🚀`,
        parse_mode: "Markdown",
        reply_markup: {
          inline_keyboard: [
            [
              {
                text: "🎲 Play Now",
                url: "https://t.me/ludo_miniApp_bot?startapp=main",
              },
            ],
          ],
        },
      },
    ]);
  }

  if (!query.startsWith("game_")) {
    return ctx.answerInlineQuery([]);
  }

  const gameId = query.replace("game_", "");
  const game = initialState.getGameState(gameId);
  if (!game) {
    return ctx.answerInlineQuery([]);
  }
  const joinUrl = `https://t.me/ludo_miniApp_bot?startapp=game_${gameId}`;

  // ۲. ارسال پیام دعوت بازی دوستانه (لابی) با عکس به جای متن خالی
  return ctx.answerInlineQuery([
    {
      type: "photo", // تغییر از article به photo برای داشتن عکس بالای لابی
      id: gameId,
      photo_file_id: PHOTO_FILE_ID,
      title: "🎲 Invite Friends",
      description: "Send this invitation to a friend",
      caption: `🎲 Ludo Friendly Match\n\nPlayers: ${game.players.length}/${game.number_of_players}\n\n🟢 ${ctx.from.first_name}\n\n⏳ Waiting for ${game.number_of_players - game.players.length} more player${game.number_of_players - game.players.length > 1 ? "s" : ""}...`,
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

// تابع بروزرسانی وضعیت لابی مسابقه
const { Telegraf, Markup } = require("telegraf");
const initialState = require("./src/models/initialState");
const {
  setGameMessage,
  getGameMessage,
} = require("./src/models/gameMessageStore");

const bot = new Telegraf(
  process.env.BOT_TOKEN || "8780116886:AAEkCv3L3WVnHIhI7fvOPMmj1mSe2QWz9Ho",
);

const WEB_APP_URL = "https://ludo-tecb.onrender.com";
// شناسه ثابت عکس بنر لودو
const PHOTO_FILE_ID =
  "AgACAgQAAxkBAANWaj7CJA8BUAYAAa-OFtVJ7M4hjQ4qAAMOaxthRfBR1YyGsvn7DdkBAAMCAAN4AAM8BA";

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

// مدیریت اینلاین کوئری‌ها (اشتراک‌گذاری)
bot.on("inline_query", async (ctx) => {
  const query = ctx.inlineQuery.query;

  // ۱. اشتراک‌گذاری عمومی ربات با عکس
  if (query === "share_bot") {
    return ctx.answerInlineQuery([
      {
        type: "photo",
        id: "share_main_bot",
        photo_file_id: PHOTO_FILE_ID,
        title: "🎮 Play Ludo Mini App",
        description: "Invite your friends to play Ludo together!",
        caption: `🎲 *Let's Play Ludo!* Hey! I'm playing Ludo right inside Telegram. \nClick the button below to join the game and challenge me! 🚀`,
        parse_mode: "Markdown",
        reply_markup: {
          inline_keyboard: [
            [
              {
                text: "🎲 Play Now",
                url: "https://t.me/ludo_miniApp_bot?startapp=main",
              },
            ],
          ],
        },
      },
    ]);
  }

  if (!query.startsWith("game_")) {
    return ctx.answerInlineQuery([]);
  }

  const gameId = query.replace("game_", "");
  const game = initialState.getGameState(gameId);
  if (!game) {
    return ctx.answerInlineQuery([]);
  }
  const joinUrl = `https://t.me/ludo_miniApp_bot?startapp=game_${gameId}`;

  // ۲. ارسال پیام دعوت بازی دوستانه (لابی) با عکس به جای متن خالی
  return ctx.answerInlineQuery([
    {
      type: "photo", // تغییر از article به photo برای داشتن عکس بالای لابی
      id: gameId,
      photo_file_id: PHOTO_FILE_ID,
      title: "🎲 Invite Friends",
      description: "Send this invitation to a friend",
      caption: `🎲 Ludo Friendly Match\n\nPlayers: ${game.players.length}/${game.number_of_players}\n\n🟢 ${ctx.from.first_name}\n\n⏳ Waiting for ${game.number_of_players - game.players.length} more player${game.number_of_players - game.players.length > 1 ? "s" : ""}...`,
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

// تابع بروزرسانی وضعیت لابی مسابقه
const updateLobbyMessage = async (gameId) => {
  const game = initialState.getGameState(gameId);
  const message = getGameMessage(gameId);

  if (!game || !message?.inline_message_id) return;

  const playersList = game.players
    .map((player) => `🟢 ${player.username || player.first_name}`)
    .join("\n");

  const playersCount = game.players.length;
  const maxPlayers = game.number_of_players;

  // متن جدید که قرار است به عنوان کپشن زیر عکس قرار بگیرد
  const text =
    game.game_status === "start"
      ? `🎲 Ludo Friendly Match\n\nPlayers: ${playersCount}/${maxPlayers}\n\n${playersList}\n\n🔥 All players are ready!\n\n🚀 The match is now in progress.`
      : game.game_status === "finished"
        ? `🏆 Match Complete\n\nPlayers: ${playersCount}/${maxPlayers}\n\n${playersList}\n\n🎉 ${game.winner ? game.winner.first_name : "Someone"} is winner!\n\nThanks for joining the game.`
        : game.game_status === "cancel"
          ? `⚠️ Match Cancelled\n\nPlayers: ${playersCount}/${maxPlayers}\n\n${playersList}\n\nThe lobby has been closed.`
          : `🎲 Ludo Friendly Match\n\nPlayers: ${playersCount}/${maxPlayers}\n\n${playersList}\n\n🎯 Waiting for ${maxPlayers - playersCount} more player${maxPlayers - playersCount > 1 ? "s" : ""} to join...`;

  const joinUrl = `https://t.me/ludo_miniApp_bot?startapp=game_${gameId}`;

  // استفاده از editMessageCaption به جای editMessageText چون پیام پایه ما حالا حاوی عکس است
  await bot.telegram.editMessageCaption(
    undefined,
    undefined,
    message.inline_message_id,
    text,
    {
      reply_markup:
        game.game_status === "finished" ||
        game.game_status === "cancel" ||
        game.game_status === "start"
          ? {
              inline_keyboard: [
                [
                  {
                    text: `play ludo`,
                    url: "https://t.me/ludo_miniApp_bot?startapp",
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
            },
    },
  );
};

module.exports = { bot, updateLobbyMessage };
