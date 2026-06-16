const { Telegraf, Markup } = require("telegraf");
const initialState = require("./src/models/initialState");

// توکن ربات شما
const bot = new Telegraf(
  process.env.BOT_TOKEN || "8780116886:AAEkCv3L3WVnHIhI7fvOPMmj1mSe2QWz9Ho",
);

// متغیرهای ثابت برای جلوگیری از تکرار و تغییر راحت‌تر در آینده
const WEB_APP_URL = "https://ludo-tecb.onrender.com";
const BOT_USERNAME = "ludo_miniApp_bot"; // آیدی ربات بدون @
const APP_SHORT_NAME = "ludo"; // نام کوتاه مینی‌اپ شما در BotFather

// ----------------------------------------------------
// ۱. حالت استارت معمولی (وقتی کاربر دستی وارد ربات میشه)
// ----------------------------------------------------
bot.start((ctx) => {
  return ctx.reply(
    "🎮 Welcome to Ludo. Let's Play!",
    Markup.inlineKeyboard([
      Markup.button.webApp("🎲 شروع بازی عمومی", WEB_APP_URL),
    ]),
  );
});

// ----------------------------------------------------
// ۲. حالت اینلاین (زمانی که کاربر از داخل بازی دکمه دعوت رو میزنه)
// ----------------------------------------------------
bot.on("inline_query", async (ctx) => {
  const query = ctx.inlineQuery.query; // مقداری که جلوی آیدی ربات میاد، مثلاً: game_123

  // بررسی می‌کنیم که آیا این درخواست مربوط به بازی دوستانه هست یا نه
  if (query && query.startsWith("game_")) {
    const gameId = query.replace("game_", "");

    // گرفتن آخرین وضعیت بازی از حافظه (سرور سوکت)
    const game = initialState.getGameState(gameId);
    if (!game) return ctx.answerInlineQuery([]); // اگر بازی پیدا نشد، چیزی نشون نده

    const currentPlayers = game.players ? game.players.length : 1;
    const requiredPlayers = game.number_of_players;

    // لینکی که کاربر دوم با کلیک روی اون مستقیم و بدون دکمه استارت وارد مینی‌اپ میشه
    const directPlayUrl = `https://t.me/${BOT_USERNAME}/${APP_SHORT_NAME}?startapp=game_${gameId}`;

    // ساخت ساختار کارت اینلاین تلگرام
    const results = [
      {
        type: "article",
        id: gameId, // این آیدی بسیار مهمه، چون در مرحله بعد بهش نیاز داریم
        title: "🎲 دعوت به بازی منچ (Ludo)",
        description: `اتاق بازی دوستانه تشکیل شد. ظرفیت فعلی: ${currentPlayers}/${requiredPlayers}`,
        thumb_url: "https://ludo-tecb.onrender.com/assets/dice_logo.png", // 💡 اختیاری: آدرس لوگوی بازی برای قشنگی کارت
        input_message_content: {
          message_text: `🎲 **منچ دوستانه لودو**\n\nمن یک اتاق بازی ایجاد کردم! برای ورود مستقیم به بازی و رقابت، روی دکمه زیر کلیک کنید.\n\n👥 وضعیت بازیکنان: ${currentPlayers} از ${requiredPlayers}`,
          parse_mode: "Markdown",
        },
        ...Markup.inlineKeyboard([
          Markup.button.url(
            `⚔️ ورود به اتاق بازی (${currentPlayers}/${requiredPlayers})`,
            directPlayUrl,
          ),
        ]),
      },
    ];

    // ارسال پاسخ اینلاین به تلگرام (cache_time: 0 باعث میشه تعداد بازیکنا فورا آپدیت بشه و کش نشه)
    return ctx.answerInlineQuery(results, { cache_time: 0 });
  }
});

// ----------------------------------------------------
// ۳. شکار کردن آیدی پیام ارسال شده (مهم‌ترین بخش برای آپدیت زنده دکمه)
// ----------------------------------------------------
bot.on("chosen_inline_result", (ctx) => {
  const gameId = ctx.chosenInlineResult.result_id; // همان id که در بالا ست کردیم (gameId)
  const inlineMessageId = ctx.chosenInlineResult.inline_message_id; // آیدی منحصربه‌فرد پیام در آن گروه/چت

  if (inlineMessageId) {
    // این آیدی پیام رو درون حافظه بازی ذخیره می‌کنیم تا بعداً بتونیم دکمه رو ادیت کنیم
    initialState.updateGameState(gameId, {
      inline_message_id: inlineMessageId,
    });
    console.log(
      `[Telegram] Inline message ID saved for game ${gameId}: ${inlineMessageId}`,
    );
  }
});

// ----------------------------------------------------
// ۴. تابع صادراتی برای آپدیت زنده ویجتِ ارسال شده در گروه‌ها یا پی‌وی‌ها
// ----------------------------------------------------
async function updateTelegramInlineWidget(gameId, status) {
  const game = initialState.getGameState(gameId);
  // اگر بازی وجود نداشت یا کاربر هنوز پیام رو در گروه ارسال نکرده بود، کاری نکن
  if (!game || !game.inline_message_id) return;

  const directPlayUrl = `https://t.me/${BOT_USERNAME}/${APP_SHORT_NAME}?startapp=game_${gameId}`;
  let text = "";
  let buttons = [];

  const currentPlayers = game.players ? game.players.length : 0;
  const requiredPlayers = game.number_of_players;

  // بر اساس وضعیت جدید بازی، متن و دکمه رو تغییر میدیم
  if (status === "waiting") {
    text = `🎲 **منچ دوستانه لودو**\n\nمن یک اتاق بازی ایجاد کردم! برای ورود مستقیم به بازی و رقابت، روی دکمه زیر کلیک کنید.\n\n👥 وضعیت بازیکنان: ${currentPlayers} از ${requiredPlayers}`;
    buttons = [
      Markup.button.url(
        `⚔️ ورود به اتاق بازی (${currentPlayers}/${requiredPlayers})`,
        directPlayUrl,
      ),
    ];
  } else if (status === "running") {
    text = `🎮 **بازی منچ شروع شد!**\n\nظرفیت اتاق تکمیل شد و بازیکنان در حال رقابت هستند. ⚔️`;
    buttons = [Markup.button.url(`🎮 مشاهده وضعیت آنلاین بازی`, directPlayUrl)];
  } else if (status === "finished") {
    text = `🏁 **بازی به پایان رسید**\n\nاین مسابقه دوستانه با موفقیت خاتمه یافت.\n🏆 برنده بازی: ${game.winner || "نامشخص"}`;
    buttons = [
      Markup.button.url(
        `🎲 ساخت بازی جدید`,
        `https://t.me/${BOT_USERNAME}/${APP_SHORT_NAME}`,
      ),
    ];
  }

  try {
    // متد رسمی تلگرام برای ویرایش پیام‌هایی که از طریق اینلاین فرستاده شدن
    await bot.telegram.editMessageText(
      undefined,
      undefined,
      game.inline_message_id,
      text,
      {
        parse_mode: "Markdown",
        ...Markup.inlineKeyboard(buttons),
      },
    );
    console.log(
      `[Telegram] Widget updated to status: ${status} for game: ${gameId}`,
    );
  } catch (err) {
    console.error("Error updating telegram inline widget:", err.message);
  }
}

// اکسپورت کردن خود بات و تابع آپدیت برای استفاده در بخش سوکت‌ها
module.exports = { bot, updateTelegramInlineWidget };
