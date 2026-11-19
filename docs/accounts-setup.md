# Accounts setup: Sign in with Apple and Google (Supabase)

The code is in place (`Bahasa/Core/Account/`, `site/learn/account.js`, `supabase/schema.sql`). These steps
create the accounts and keys it needs. About 30 minutes. Nothing here needs a credit card.

## 1. Supabase project (free)
1. supabase.com → New project → name `learn-bahasa`, region **Southeast Asia (Singapore)**. Save the database password somewhere safe.
2. **SQL Editor** → paste all of `supabase/schema.sql` → Run.
3. **Project Settings › API**: copy the **Project URL** (`https://xxxx.supabase.co`) and the **anon public** key.
4. **Authentication › URL Configuration**:
   - Site URL: `https://learnbahasa.app/learn/`
   - Redirect URLs: add `https://learnbahasa.app/learn/`, `bahasa://auth-callback`, and `http://127.0.0.1:8765/learn/` (local testing).

## 2. Google
1. console.cloud.google.com → create project `Learn Bahasa` (no billing needed for sign-in).
2. **APIs & Services › OAuth consent screen**: External, app name "Learn Bahasa", support email hello@learnbahasa.app, authorised domain `learnbahasa.app`, privacy https://learnbahasa.app/privacy. Publish it (Testing mode only lets test users in).
3. **Credentials › Create credentials › OAuth client ID** → type **Web application**:
   - Authorised JavaScript origins: `https://learnbahasa.app`
   - Authorised redirect URIs: `https://xxxx.supabase.co/auth/v1/callback` (your project URL + `/auth/v1/callback`)
4. Copy the Client ID and Client secret → Supabase **Authentication › Providers › Google** → enable, paste both, save.
   (The iPhone app uses the same web flow in a secure sheet, so no separate iOS client is needed.)

## 3. Apple
In developer.apple.com › Certificates, Identifiers & Profiles:
1. **Identifiers › App IDs › com.justinpoh.bahasa** → enable **Sign in with Apple** (Xcode's automatic signing may already have done this from the entitlement).
2. **Identifiers › + › Services IDs** → `com.justinpoh.bahasa.web`, description "Learn Bahasa web" → enable Sign in with Apple → Configure:
   - Primary App ID: com.justinpoh.bahasa
   - Domains: `xxxx.supabase.co` and `learnbahasa.app`
   - Return URLs: `https://xxxx.supabase.co/auth/v1/callback`
3. **Keys › +** → name "Learn Bahasa Sign in with Apple" → enable Sign in with Apple (primary App ID com.justinpoh.bahasa) → download the `.p8` once. Note the **Key ID** and your **Team ID** (Y4648M7S2X).
4. Supabase **Authentication › Providers › Apple** → enable:
   - Client IDs: `com.justinpoh.bahasa.web,com.justinpoh.bahasa` (web Services ID first, then the app's bundle ID for native sign-in)
   - Secret key: generate it from the .p8 with Supabase's tool on that page (Team ID, Key ID, Services ID, .p8). Apple secrets expire after 6 months; set a reminder to renew.

## 4. Put the two public values in
- App: in Xcode › target › Build Settings, set `SUPABASE_HOST` to `xxxx.supabase.co` (no https://) and `SUPABASE_ANON_KEY` to the anon key, for both Debug and Release.
- Website: `site/learn/config.js` → `supabaseUrl: "https://xxxx.supabase.co"`, `supabaseAnonKey: "..."`, then redeploy.

## 5. App Store Connect privacy label
Add to the existing Purchases entry: Contact Info › Email Address, Identifiers › User ID, Contact Info › Name, User Content › Other User Content. All: App Functionality, **linked to the user**, not used for tracking.
