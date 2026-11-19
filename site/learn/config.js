// Supabase project for optional sign-in and progress sync. Both values are public by design
// (the anon key only works with the row-level security rules in supabase/schema.sql).
// Leave empty to hide accounts on the website.
window.LB_CONFIG = {
  supabaseUrl: "",      // e.g. "https://abcd1234.supabase.co"
  supabaseAnonKey: "",
};
