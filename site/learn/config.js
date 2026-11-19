// Supabase project for optional sign-in and progress sync. Both values are public by design
// (the anon key only works with the row-level security rules in supabase/schema.sql).
// Leave empty to hide accounts on the website.
window.LB_CONFIG = {
  supabaseUrl: "https://nwndbecvttzazmacrgfh.supabase.co",      // e.g. "https://abcd1234.supabase.co"
  supabaseAnonKey: "sb_publishable_CmWpkVjw1YnNumE1zEwk1Q_ZW34Qu1E",
  // Google "Web application" OAuth client (public). Used for Google's own button, so the sign-in
  // screen names learnbahasa.app instead of the Supabase address.
  googleClientId: "716290769990-7el08j1j859k4ks9qldml6djdgvebjkm.apps.googleusercontent.com",
};
