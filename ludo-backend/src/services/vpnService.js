const axios = require("axios");
const https = require("https");

const VPN_API_KEY = process.env.VPN_PARTNER_API_KEY;
const VPN_BASE_URL = process.env.VPN_API_BASE_URL || "https://bot.ir-bahmani.ir";

const vpnApiClient = axios.create({
    baseURL: VPN_BASE_URL,
    headers: {
        "Content-Type": "application/json",
        "X-API-Key": VPN_API_KEY,
    },
    timeout: 10000,
    httpsAgent: new https.Agent({rejectUnauthorized: false}),
});

function calculateRemainingDays(expireDateStr) {
    if (!expireDateStr) return 0;
    const diffTime = new Date(expireDateStr) - new Date();
    return diffTime > 0 ? Math.ceil(diffTime / (1000 * 60 * 60 * 24)) : 0;
}

/**
 * دریافت لیست کامل کانفیگ‌های یک کاربر
 */
async function getUserVpnConfigs(telegramId) {
    try {
        const response = await vpnApiClient.get(`/api/v1/partners/user/${telegramId}`);
        const data = response.data;

        if (data?.success && Array.isArray(data.configs) && data.configs.length > 0) {
            // نگاشت و استانداردسازی تمام کانفیگ‌ها برای فرانت‌‌اند
            const formattedConfigs = data.configs.map((config) => ({
                userVpnId: config.userVpnId,
                subscriptionUrl: config.subscriptionUrl,
                status: config.status, // ENABLE, DISABLE, etc.
                totalGb: config.totalTrafficGb ?? 0,
                remainingGb: config.remainingTrafficGb ?? 0,
                remainingDays: calculateRemainingDays(config.expireDate),
                expireDate: config.expireDate,
                createdAt: config.createdAt,
            }));

            return {
                success: true,
                registeredInBot: data.registeredInBot ?? false,
                configCount: data.configCount ?? formattedConfigs.length,
                maxAllowed: data.maxAllowed ?? 3,
                configs: formattedConfigs,
            };
        }

        return {
            success: true,
            registeredInBot: data?.registeredInBot ?? false,
            configCount: 0,
            maxAllowed: data?.maxAllowed ?? 3,
            configs: [],
        };
    } catch (err) {
        if (err.response?.status !== 404) {
            console.error("[VPN Service - GetConfigs Error]:", err.response?.data || err.message);
        }
        return {
            success: false,
            registeredInBot: false,
            configCount: 0,
            maxAllowed: 3,
            configs: [],
        };
    }
}

/**
 * خرید / تبدیل سکه به کانفیگ جدید
 */
async function redeemCoinsForVpn(socket, trafficGb) {
    try {
        const response = await vpnApiClient.post("/api/v1/partners/config", {
            gameUserId: String(socket.data.telegramId),
            trafficGb: Number(trafficGb),
            durationDays: 30,
        });

        const data = response.data;

        if (data?.success && Array.isArray(data.configs) && data.configs.length > 0) {
            const config = data.configs[0];

            const totalTraffic = Number(config.trafficLimit ?? trafficGb);
            const remainingDays = calculateRemainingDays(config.expireDate);

            return {
                success: true,
                newConfig: {
                    subscriptionUrl: config.subscriptionUrl || "",
                    totalGb: totalTraffic,
                    remainingGb: totalTraffic, // برای کانفیگ جدید، حجم باقی‌مانده برابر کل است
                    remainingDays: Number(remainingDays) || 0,
                    status: "ENABLE", // هماهنگ با مدل فلاتر
                },
                accountCredit: data.remainingCredit
            };
        }

        return { success: false, message: data?.message || "خطا در صدور کانفیگ" };
    } catch (err) {
        const errorMsg = err.response?.data?.message || err.message;
        console.error("[VPN Service - Redeem Error]:", errorMsg);
        return { success: false, message: errorMsg };
    }
}
module.exports = {
    getUserVpnConfigs,
    redeemCoinsForVpn,
};