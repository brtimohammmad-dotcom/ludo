// db.js
const { createClient } = require("@supabase/supabase-js");

// خواندن مستقیم از متغیرهای محیطی که در مرحله قبل ساختیم
const supabaseUrl = process.env.SUPABASE_URL;
const supabaseKey = process.env.SUPABASE_KEY;

if (!supabaseUrl || !supabaseKey) {
  console.error(
    "❌ Error: SUPABASE_URL or SUPABASE_KEY is missing in environment variables!",
  );
}

const supabase = createClient(supabaseUrl, supabaseKey);

module.exports = supabase;
