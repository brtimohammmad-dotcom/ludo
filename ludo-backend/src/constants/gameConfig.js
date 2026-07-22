const packageJson = require("../../package.json");

module.exports = {
  BOT_TOKEN: "365911666:EB6GYypwmLmqear51OxarplQX5P_TJhxOBI",
  PORT: 3000,
  TWO_PLAYER_COLORS: ["red", "yellow"],
  FOUR_PLAYER_COLORS: ["red", "blue", "yellow", "green"],
  MAX_PLAYERS: 4,
  VERSION: packageJson.version,
  LEVEL_COSTS: {
    free: 0,
    bronze: 50,
    silver: 200,
    gold: 500,
    vip: 1000,
  },
  WIN_AMOUNT: {
    free: { 2: 0, 4: 0 },
    bronze: { 2: 90, 4: 150 },
    silver: { 2: 360, 4: 600 },
    gold: { 2: 900, 4: 1500 },
    vip: { 2: 1800, 4: 3000 },
  },
};
