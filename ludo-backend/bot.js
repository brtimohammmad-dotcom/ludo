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
bot.start((ctx) => {
  // استفاده از file_id به جای لینک اینترنتی برای لود فوق‌العاده سریع
  const PHOTO_FILE_ID =
    "AgACAgQAAxkBAAErUx1qPsAK0Vnzzu1yyQWz21xi2htjjwADDmsbYUXwURvSMz42vBehAQADAgADeAADPAQ";

  return ctx.replyWithPhoto(PHOTO_FILE_ID, {
    caption: "🎮 Welcome to Ludo",
    ...Markup.inlineKeyboard([
      [Markup.button.webApp("🎲 Play Now", WEB_APP_URL)],
      [Markup.button.switchToChat("📢 Share with Friends", "")],
    ]),
  });
});
bot.on("photo", (ctx) => {
  // گرفتن باکیفیت‌ترین عکس
  const fileId = ctx.message.photo[ctx.message.photo.length - 1].file_id;
  console.log("------------------------");
  console.log("YOUR BOT FILE_ID:", fileId);
  console.log("------------------------");
  ctx.reply("آیدی عکس در کنسول چاپ شد! دمت گرم.");
});

bot.on("inline_query", async (ctx) => {
  const query = ctx.inlineQuery.query;

  if (!query.startsWith("game_")) {
    return ctx.answerInlineQuery([]);
  }

  const gameId = query.replace("game_", "");
  const game = initialState.getGameState(gameId);
  if (!game) {
    return ctx.answerInlineQuery([]);
  }
  const joinUrl = `https://t.me/ludo_miniApp_bot?startapp=game_${gameId}`;

  return ctx.answerInlineQuery([
    {
      type: "article",
      id: gameId,

      title: "🎲 Invite Friends",

      description: "Send this invitation to a friend",

      input_message_content: {
        message_text: `🎲 Ludo Friendly Match

Players: ${game.players.length}/${game.number_of_players}

🟢 ${ctx.from.first_name}

⏳ Waiting for ${game.number_of_players - game.players.length} more player${game.number_of_players - game.players.length > 1 ? "s" : ""}...`,
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
});
bot.on("chosen_inline_result", async (ctx) => {
  const gameId = ctx.chosenInlineResult.result_id;

  const inlineMessageId = ctx.chosenInlineResult.inline_message_id;
  if (!inlineMessageId) {
    // مهم: لاگ کن ببین واقعاً چی میاد
    console.log("NO inline_message_id:", ctx.chosenInlineResult);
    return;
  }
  setGameMessage(gameId, {
    inline_message_id: inlineMessageId,
  });
});
const updateLobbyMessage = async (gameId) => {
  const game = initialState.getGameState(gameId);
  const message = getGameMessage(gameId);

  if (!game || !message?.inline_message_id) return;

  const playersList = game.players
    .map((player) => `🟢 ${player.username}`)
    .join("\n");

  const playersCount = game.players.length;
  const maxPlayers = game.number_of_players;

  const text =
    game.game_status === "start"
      ? `🎲 Ludo Friendly Match

Players: ${playersCount}/${maxPlayers}

${playersList}

🔥 All players are ready!

🚀 The match is now in progress.`
      : game.game_status === "finished"
        ? `🏆 Match Complete

Players: ${playersCount}/${maxPlayers}

${playersList}

🎉 ${game.winner.first_name} is winner!

Thanks for joining the game.`
        : game.game_status === "cancel"
          ? `⚠️ Match Cancelled

Players: ${playersCount}/${maxPlayers}

${playersList}

The lobby has been closed.`
          : `🎲 Ludo Friendly Match

Players: ${playersCount}/${maxPlayers}

${playersList}

🎯 Waiting for ${maxPlayers - playersCount} more player${maxPlayers - playersCount > 1 ? "s" : ""} to join...`;

  const joinUrl = `https://t.me/ludo_miniApp_bot?startapp=game_${gameId}`;

  await bot.telegram.editMessageText(
    undefined,
    undefined,
    message.inline_message_id,
    text,
    {
      reply_markup:
        game.game_status === "finished" || game.game_status === "cancel"
          ? {
              inline_keyboard: [
                [
                  {
                    text: `play ludo`,
                    url: "https://t.me/ludo_miniApp_bot?startapp=main",
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
