const { Telegraf, Markup } = require("telegraf");

const bot = new Telegraf(process.env.BOT_TOKEN);

bot.start((ctx) => {
  ctx.reply(
    "🎮 Welcome to Ludo. Let's Play!",
    Markup.inlineKeyboard([
      Markup.button.webApp("🎲 شروع بازی", "https://ludo-tecb.onrender.com"),
    ]),
  );
});

module.exports = bot;
