// db.js
const { createClient } = require("@supabase/supabase-js");

// این مقادیر را باید از پنل Supabase (بخش Project Settings > API) برداری
const supabaseUrl =
  process.env.SUPABASE_URL || "https://ryuwzehynsandwnbucpk.supabase.co";
const supabaseKey =
  process.env.SUPABASE_KEY || "sb_publishable_0jxBzVe6foJFpCj8lawrsg_qHPucRIk";

// ساخت کلاینت سوپابیس برای ارتباط با دیتابیس
const supabase = createClient(supabaseUrl, supabaseKey);

module.exports = supabase;
