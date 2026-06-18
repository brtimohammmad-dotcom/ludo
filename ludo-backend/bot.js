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
  return ctx.reply(
    "🎮 Welcome to Ludo",
    Markup.inlineKeyboard([Markup.button.webApp("🎲 Play Now", WEB_APP_URL)]),
  );
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
        message_text: `🎲 Ludo Friendly Match ${game.number_of_players}\n\nClick the button below to join.`,
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

  if (!inlineMessageId) return;

  setGameMessage(gameId, {
    inline_message_id: inlineMessageId,
  });
});
const updateLobbyMessage = (gameId) => {
  const game = initialState.getGameState(gameId);
  const message = getGameMessage(gameId);

  if (!message?.inline_message_id) return;

  const joinUrl = `https://t.me/ludo_miniApp_bot?startapp=game_${gameId}`;

  bot.telegram.editMessageReplyMarkup(
    undefined,
    undefined,
    message.inline_message_id,
    {
      inline_keyboard: [
        [
          {
            text: `▶️ Play Game (${game.players.length}/${game.number_of_players})`,
            url: joinUrl,
          },
        ],
      ],
    },
  );
};
module.exports = { bot, updateLobbyMessage };
