const {joinGameQueue, acquireGameLock} = require("./joinGameQueue.js");
const initialState = require("../models/initialState");
const {createGameInDataBase} = require("../database/games");
const {
    TWO_PLAYER_COLORS,
    FOUR_PLAYER_COLORS,
    LEVEL_COSTS,
} = require("../constants/gameConfig");
const {addPlayerToGameOnDatabase} = require("../database/gamePlayers");
const {reduceMultiplePlayersCoin} = require("../database/players.js");
const {updateGameState} = require("../database/games");
const {startTimer} = require("../services/turnTimerService");
const {updateLobbyMessage} = require("../../bot.js");
const {hasExistGame} = require("./authService.js");

const roomTimers = new Map();

async function handleJoinGame(data, socket, io, callback) {
    if (typeof callback === "function") {
        callback({success: true});
    }
    const {numberOfPlayers, gameType, gameLevel} = data;
    const telegramId = socket.data.telegramId;

    // ۱. قفل اول: انحصار بر اساس آیدی بازیکن
    return await joinGameQueue(telegramId, async () => {
        const player = {
            username: socket.data.firstName,
            telegram_id: telegramId,
            coin: socket.data.coin,
        };

        // بررسی بازی فعال و رها شده
        const result = await hasExistGame(player, socket.id);
        if (result.game) {
            socket.emit("in_another_game");
            const {handleRequestGameState} = require("./requestGameState.js");
            await handleRequestGameState(
                socket,
                {
                    gameType: gameType,
                    gameId: result.game.game_id,
                },
                io,
            );
            return;
        }

        const entryFee = gameType === "friendly" ? 0 : LEVEL_COSTS[gameLevel] || 0;

        // ----------------------------------------------------
        // بخش بازی‌های عمومی (Global)
        // ----------------------------------------------------
        if (gameType === "global") {
            if (player.coin < entryFee) {
                socket.emit("insufficient_coin");
                return;
            }

            let game;
            let isJoined = false;

            while (!isJoined) {
                game = initialState
                    .getAllGames()
                    .find(
                        (g) =>
                            g.game_status === "waitingForPlayer" &&
                            g.number_of_players === numberOfPlayers &&
                            g.game_type === "global" &&
                            g.game_level === gameLevel &&
                            g.players.length < numberOfPlayers,
                    );

                if (!game) {
                    const dbGame = await createGameInDataBase(numberOfPlayers, gameLevel, gameType);
                    game = initialState.createGameInGameState(
                        dbGame.game_id,
                        numberOfPlayers,
                        gameType,
                        gameLevel,
                    );
                }

                // ۲. قفل دوم: انحصار بر اساس آیدی بازی
                isJoined = await acquireGameLock(game.game_id, async () => {
                    const currentRoomState = initialState.getGameState(game.game_id);

                    if (
                        currentRoomState.players.length >=
                        currentRoomState.number_of_players
                    ) {
                        return false;
                    }

                    await addPlayerToGame(currentRoomState, player, socket);
                    return true;
                });
            }

            socket.data.gameId = game.game_id;
            await callFront(socket, io);
        }

        // ----------------------------------------------------
        // بخش بازی‌های دوستانه (Friendly)
        // ----------------------------------------------------
        else if (gameType === "friendly") {
            let room = await createGameInDataBase(numberOfPlayers, gameLevel, gameType);
            room = initialState.createGameInGameState(
                room.game_id,
                numberOfPlayers,
                gameType,
                "free",
            );

            const friendlyGameId = room.game_id;

            // بازی‌های دوستانه تازه ساخته شده‌اند اما برای رعایت ساختار استاندارد قفل آن را می‌گیریم
            await acquireGameLock(friendlyGameId, async () => {
                await addPlayerToGame(room, player, socket);
            });

            // 🌟 ثبت تایمر انقضای ۱۰ دقیقه‌ای برای پاکسازی رم سرور رندر در صورت رها شدن اتاق دوستانه
            const timeoutTimer = setTimeout(
                async () => {
                    const currentRoom = initialState.getGameState(friendlyGameId);
                    // اگر اتاق هنوز در رم بود و بازی استارت نخورده بود، آن را حذف کن
                    if (currentRoom && currentRoom.game_status === "waitingForPlayer") {
                         updateGameState(
                            friendlyGameId,
                            {
                                game_status: "cancel",
                                players: currentRoom.players,
                                end_at: new Date(),
                            },
                        );
                        initialState.updateGameState(friendlyGameId, {
                            game_status: "cancel",
                        });
                        await updateLobbyMessage(friendlyGameId);
                        initialState.deleteGameState(friendlyGameId);
                        roomTimers.delete(friendlyGameId);
                    }
                },
                10 * 60 * 1000,
            ); // ۱۰ دقیقه

            roomTimers.set(friendlyGameId, timeoutTimer);

            socket.data.gameId = friendlyGameId;
            await callFront(socket, io);
        }
    });
}

async function handleJoinGameFriendly(socket, io) {
    const telegramId = socket.data.telegramId;
    const gameId = socket.data.gameId;

    return await joinGameQueue(telegramId, async () => {
        const player = {
            username: socket.data.firstName,
            telegram_id: telegramId,
            coin: socket.data.coin,
        };
        try {
            await acquireGameLock(gameId, async () => {
                const game = initialState.getGameState(gameId);
                if (!game || game.players.length >= game.number_of_players) {
                    throw new Error("Room is full or doesn't exist");
                }
                await addPlayerToGame(game, player, socket);
            });

            await callFront(socket, io);
        } catch (err) {
            console.log("Error in joining friendly game:", err);
            socket.emit("join_error", {message: err.message});
        }
    });
}

async function callFront(socket, io) {
    const gameId = socket.data.gameId;
    const telegramId = socket.data.telegramId;

    socket.join(gameId);

    let currentGameState = initialState.getGameState(gameId);
    if (!currentGameState) return;

    socket.emit("game_state_update", currentGameState);

    const newPlayer = currentGameState.players.find(
        (p) => p.telegram_id === telegramId,
    );
    if (newPlayer) {
        socket.to(gameId).emit("player_joined", newPlayer);
    }

    if (
        currentGameState.players.length === currentGameState.number_of_players &&
        currentGameState.game_status === "waitingForPlayer"
    ) {
        currentGameState.game_status = "start";

        if (currentGameState.game_type === "friendly") {
            const activeTimer = roomTimers.get(gameId);
            if (activeTimer) {
                clearTimeout(activeTimer);
                roomTimers.delete(gameId);
            }
        }

        if (currentGameState.game_type === "global") {
            const coinCost = LEVEL_COSTS[currentGameState.game_level] || 0;

            if (coinCost > 0) {
                let playersTelegramId = [];

                const reducedPlayers = currentGameState.players.map((p) => {
                    playersTelegramId.push(p.telegram_id);
                    return {
                        ...p,
                        coin: p.coin - coinCost,
                    };
                });

                initialState.updateGameState(gameId, {
                    players: reducedPlayers,
                });

                try {
                    await reduceMultiplePlayersCoin(playersTelegramId, coinCost);
                } catch (dbError) {
                    console.error("Error reducing coins from DB:", dbError);
                }

                const sockets = await io.in(gameId).fetchSockets();
                sockets.forEach((s) => {
                    s.data.coin = s.data.coin - coinCost;
                });
            }
        }

         updateGameState(
            gameId,
            {game_status: "start"},
        );

        initialState.updateGameState(gameId, {
            game_status: "start",
        });

        io.to(gameId).emit("game_started");
        startTimer(socket, io);
    }

    await updateLobbyMessage(gameId);
}

async function addPlayerToGame(game, player, socket) {
    const players = game.players;

    const color =
        game.number_of_players === 2
            ? TWO_PLAYER_COLORS[players.length]
            : FOUR_PLAYER_COLORS[players.length];

    socket.data.color = color;
    const correctPlayer = {
        ...player,
        color: color,
        player_status: "online",
        number_of_absences: 0,
        connection_status: "connected",
        avatar_url: socket.data.avatarUrl,
        wins: socket.data.wins,
        losses: socket.data.losses,
    };
    initialState.addPlayerToGameState(correctPlayer, game.game_id);

     addPlayerToGameOnDatabase(player.telegram_id, game.game_id, color);
}

module.exports = {handleJoinGame, handleJoinGameFriendly};
