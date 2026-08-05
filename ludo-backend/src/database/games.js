// اتصال به کلاینت جدید دیتابیس
const supabase = require("../../postgresql");
const initialState = require("../models/initialState");

/**
 * ایجاد یک بازی جدید در دیتابیس
 */
async function createGameInDataBase(numberOfPlayers, gameLevel, gameType) {
    try {
        const {data: newGame} = await supabase
            .from("game")
            .insert([
                {
                    number_of_players: numberOfPlayers,
                    game_level: gameLevel,
                    game_type: gameType,
                },
            ])
            .select()
            .single();


        return newGame; // شامل game_id تولید شده به همراه مقادیر پیش‌فرض (started_at و ...)
    } catch (error) {
        console.error("خطا در ایجاد بازی جدید:", error);
        throw error;
    }
}

/**
 * به‌روزرسانی فیلدهای داینامیک بازی
 */
async function updateGameState(id, fields) {
    try {
        const { data: updatedGame, error } = await supabase
            .from("game")
            .update(fields)
            .eq("game_id", id)
            .select()
            .single();

        if (error) {
            console.error("خطا از سمت Supabase:", error);
            return null;
        }

        console.log("آپدیت با موفقیت انجام شد:", updatedGame);

        // دریافت لیست بازیکنان از استیت لوکال برنامه
        const players = initialState.getGameState(id)?.players || [];

        return {
            ...updatedGame,
            players: players.map((p) => ({
                telegramId: p.telegram_id,
                color: p.color,
                username: p.username,
                player_status: p.player_status,
            })),
        };
    } catch (error) {
        console.error("خطا در به‌روزرسانی وضعیت بازی:", error);
        throw error;
    }
}
async function getGameState(gameId) {
    // روش 3: بدون single() - همیشه یک آرایه برمی‌گردد
    const {data: games, error} = await supabase
        .from("game")
        .select("*")
        .eq("game_id", gameId);

    if (error) {
        console.error("خطا:", error);
    } else if (games.length === 0) {
        console.log("بازی پیدا نشد");
    } else {
        return games[0];
    }
}

module.exports = {
    createGameInDataBase,
    updateGameState,
    getGameState,
};
