// Runtime settings. Left empty, the app runs in standalone mode and saves to this browser only.
// On Vercel, scripts/build.mjs overwrites this file from the SUPABASE_URL and SUPABASE_PUBLISHABLE_KEY
// environment variables. Both values are public by design: row level security protects the data.
window.PD_CONFIG = { supabaseUrl: "", supabaseKey: "" };
