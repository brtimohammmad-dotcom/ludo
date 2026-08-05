const axios = require("axios");
const supabase = require("../../postgresql");

const uploadAvatarToSupabase = async (userId, telegramFileLink) => {
  try {
    // ۱. دانلود عکس از تلگرام به صورت Buffer
    const response = await axios.get(telegramFileLink, {
      responseType: "arraybuffer",
    });
    const buffer = Buffer.from(response.data, "binary");

    // تعیین نام فایل منحصر به فرد برای هر کاربر
    const fileName = `${userId}.jpg`;

    // ۲. آپلود مستقیم به باکت سوپابیس (با فرض اینکه اسمی باکت avatars است)
    // گزینه upsert: true باعث می‌شود اگر کاربر عکس جدید گرفت، روی قبلی جایگزین شود
    const { error } = await supabase.storage
      .from("avatars")
      .upload(fileName, buffer, {
        contentType: "image/jpeg",
        upsert: true,
      });

    if (error) throw error;

    // ۳. گرفتن لینک عمومی (Public URL) فایل آپلود شده
    const { data: publicUrlData } = supabase.storage
      .from("avatars")
      .getPublicUrl(fileName);

    return publicUrlData.publicUrl; // این همان لینکی است که در دیتابیس ذخیره می‌شود
  } catch (error) {
    console.error(
      `[Supabase Storage Error] Upload failed for user ${userId}:`,
      error.message,
    );
    return null;
  }
};
module.exports = {uploadAvatarToSupabase}