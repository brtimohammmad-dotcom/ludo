const { Telegraf, Markup } = require("telegraf");

const bot = new Telegraf(process.env.BOT_TOKEN);

const WEB_APP_URL = "https://ludo-tecb.onrender.com";

// فقط استارت
bot.start((ctx) => {
  return ctx.reply(
    "🎮 Welcome to Ludo",
    Markup.inlineKeyboard([Markup.button.webApp("🎲 Play Now", WEB_APP_URL)]),
  );
});

bot.launch();

console.log("Bot is running...");
