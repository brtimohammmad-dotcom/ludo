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

console.log("Bot is running...");
module.exports = { bot };
