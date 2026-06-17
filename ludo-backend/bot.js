const { Telegraf, Markup } = require("telegraf");

const bot = new Telegraf(
  process.env.BOT_TOKEN || "8780116886:AAEkCv3L3WVnHIhI7fvOPMmj1mSe2QWz9Ho",
);

const WEB_APP_URL = "https://ludo-tecb.onrender.com";

bot.start((ctx) => {
  return ctx.reply(
    "🎮 Welcome to Ludo",
    Markup.inlineKeyboard([Markup.button.webApp("🎲 Play Now", WEB_APP_URL)]),
  );
});
bot.on("inline_query", async (ctx) => {
  const query = ctx.inlineQuery.query;

  if (!query.startsWith("game_")) {
    return ctx.answerInlineQuery([], {
      cache_time: 0,
    });
  }

  const gameId = query.replace("game_", "");

  const joinUrl = `https://t.me/${BOT_USERNAME}?startapp=game_${gameId}`;

  return ctx.answerInlineQuery(
    [
      {
        type: "article",
        id: gameId,
        title: "🎲 Join Ludo Game",
        description: "Tap to send game invitation",

        input_message_content: {
          message_text:
            "🎲 Ludo Friendly Match\n\nClick the button below to join the game.",
        },

        reply_markup: {
          inline_keyboard: [
            [
              {
                text: "▶️ Play Now",
                url: joinUrl,
              },
            ],
          ],
        },
      },
    ],
    {
      cache_time: 0,
    },
  );
});
module.exports = { bot };
