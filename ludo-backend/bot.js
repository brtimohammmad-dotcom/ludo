const { Telegraf, Markup } = require("telegraf");

const bot = new Telegraf(process.env.BOT_TOKEN||"8780116886:AAEkCv3L3WVnHIhI7fvOPMmj1mSe2QWz9Ho");

bot.start((ctx) => {
  ctx.reply(
    "🎮 Welcome to Ludo. Let's Play!",
    Markup.inlineKeyboard([
      Markup.button.webApp("🎲 شروع بازی", "https://ludo-tecb.onrender.com"),
    ]),
  );
});

module.exports = bot;
