# Bahasa — Indonesian for English speakers living in Indonesia

Native **SwiftUI** iOS app (iOS 17+, iPhone, portrait, light mode). Goal: a beautiful, modern app that teaches **how Indonesian sentences work** and gets learners **holding real conversations** (warung, market, Gojek, renting a room, small talk). Existing App Store apps feel dated and shallow; this one should feel crafted.

## Direction (2026-11)

The chat feature is the core of the app. The learning format is **Rehearsal Learning**, specified in [docs/rehearsal-learning-spec.md](docs/rehearsal-learning-spec.md). Lessons, patterns and phrases become complements to Scenes. The format must stay language-agnostic, because other languages will follow. Where this file disagrees with the spec, the spec wins.

## Status (handoff)

Already in place:
- `Bahasa.xcodeproj` was hand-written. It uses objectVersion 77 with a **file-system synchronized group**, so any file under `Bahasa/` is compiled automatically and you don't need to edit the pbxproj when adding files. Bundle ID `com.justinpoh.bahasa`, Swift 5 mode, iOS 17 target, `UIUserInterfaceStyle = Light`.
- A shared scheme `Bahasa` exists. The app builds and runs: `xcodebuild -project Bahasa.xcodeproj -scheme Bahasa -destination 'platform=iOS Simulator,name=<an installed iPhone>' build`.
- **Rehearsal Learning (2026-11-17):** five Scenes, one per Place, each running all five stages: `id.warung.lunch`, `id.jalan.ojek`, `id.pasar.sarong`, `id.kos.kamar`, `id.teman.ngopi`. The old Quick chats (`ChatView`, `Scenario`) are gone; `bahasa://talk/s1…s5` deep links map to the Scenes via `SceneLibrary.legacyIDs`.
  - Model and engine: `Core/SceneModels.swift` (Scene, Node, ReplyOption, LanguagePack, slots), `Core/Matcher.swift` (fuzzy token matching with casual-form folding), `Core/RehearsalState.swift` (per-Scene marks, Your Lines, Recall queue; own UserDefaults key; tolerant decoding so new fields never wipe progress), `Core/SpeechInput.swift` (id-ID, on-device recognition only).
  - Content: `Content/Scenes/` (one file per Place). `SceneValidator` checks graph integrity, ≥2 Natural replies per node, a reaction and coach note on every wrong reply, required goals reachable on every path in every mood, and that each reply matches itself. It runs at DEBUG launch (assertionFailure on problems).
  - UI: `Features/Scene/` (SceneHome, ScenePlayer + RehearsalSession, LiveCard). Talk tab = Scene cards + check-in and Recall banners. Phrases tab shows Your Lines on top.
  - Illustrations: `Features/Scene/Illustrations/`. `IllustrationKit.swift` holds the shared framing (`Illo.fit`, 400×260 design space), scenery and `Figure` (people with hair/outfit/expression/speaking/gestures). One `PlaceDrawing` per Place, dispatched by `PlaceIllustration` on `scene.place`. Animation pauses off screen, in the background and under Reduce Motion. A new Place needs a drawing; otherwise it falls back to a kawung field.
  - Word lookup: every Indonesian word in a chat bubble is a link (`WordLookup.swift`); tapping opens Kak Dewi's sheet from `Content/Lexicon.swift` (meaning, role colour, tip; understands -nya/-mu/-ku, doubled words, place and country names). The word-by-word button under a line shows each word's meaning in sentence order. **Every new Scene word needs a Lexicon entry.**
  - Chat follows the newest message unless the learner scrolls up (iOS 18+), with a jump-to-latest button.
  - Launch: `Supporting/Info.plist` `UILaunchScreen` shows paper (`LaunchBackground`) with Ibu Wayan's portrait (`LaunchMark`, 150 pt); `SplashView` starts from the same spot, she says "Halo!", then the name appears (~2 s, tap to skip). First run shows `OnboardingView` (welcome, neighbours, how a chat works, tap-a-word, name and country), stored in `@AppStorage("bahasa.onboarded")`; "Start my first chat" opens the warung Scene. Profile sheet → "Show the welcome again". DEBUG: `-onboarding` forces it, `-noIntro` skips splash and onboarding; any `-tab`/`-scene`/`-lesson` arg also skips them.
  - DEBUG launch args: `-scene <id> -stage watch|rehearse|perform|live|recall` (opens past locks), `-resetRehearsal`, `-liveDelay <seconds>`.
  - Profile, pace and placement (2026-11-18): every tab has a profile button top right (`CozyPage(profile: true)` → `Features/Profile/ProfileView.swift`): traveller avatars (`Cast.avatars`, drawn with `Figure`, which now has `hairColor`, `.long` and `.hat`), Plus status and restore, details, level, chat speed. `ChatPace` (`Core/ChatPace.swift`, Relaxed/Normal/Like a local) scales every chat pause and the voice rate; "Wait for me" holds listening chats until Next; the pace pill sits in every chat header. Onboarding is 7 pages with a level gauge and a 3-line quick check that set `LearnerProfile.level` (`LearnerLevel`); `ProgressStore.nextLesson` starts at the placed unit. Onboarding uses its own pager (the paging TabView jumped back to page 1 when a page's state changed). Talk shows a Plus nudge after the first finished chat.
  - Curriculum (2026-11-18): 11 units, 38 lessons. Added 1.3 Apa kabar, 1.4 tolong/minta/silakan, 2.4 plurals, 3.3 telling the time, 3.4 days and plans, 4.3 saying yes (echo the verb), 5.3 directions, 5.4 paying, 6.3 -nya, 6.4 -an nouns, 7.3 reactions, 7.4 small talk, and new units 8 Makan (ordering, taste and diet, table talk), 9 Jalan-jalan (rides, stays, help), 10 Budaya (Bali manners, compliments), 11 Sambung (connectors, kalau/sebelum/setelah, comparing). Units 8–11 have their own `UnitBadge` drawings. `LessonValidator` runs at DEBUG launch (unique ids, answer among options, no decoy tile that repeats an answer word). Phrasebook gained Travel & stays, Time & days and Culture. Scene warm-ups point at the new lessons where they fit. All new Indonesian still needs the native-speaker check.
  - Web learning (2026-11-19): `site/learn/` (index.html, app.js, learn.css) is a no-build web app at learnbahasa.app/learn and is **fully free: no Plus gating on the web**. `tools/content-export/export.sh` (compiles the app's Swift content on macOS with a small stub) writes every lesson and chat to `site/data/content.json`; re-run it and redeploy after content changes. Home is a stage path: each unit is a Stage that opens when the previous one is finished (or after a two-tap "Skip ahead", stored as `lb.skipTo`); chats sit in the stage that opens them (`STAGE_CHATS` in app.js); a level card shows stage, XP and counts; "Quick review" (`#/lesson/review`, 8 graded steps from finished lessons) appears after two lessons; finishing a stage shows "Stage N done!". Also: lesson player (learn, pick, arrange, hear; wrong steps come back once), chats in choose-a-reply mode with reactions, coach notes and goals, tap-a-word lookup, phrasebook with search, patterns, chat speed. Progress lives in localStorage. Voices: `tools/voice/make_audio.py --engine supertonic` (run with a venv that has `pip install supertonic`; Supertonic-3, OpenRAIL-M, commercial use allowed, output is ours) makes one MP3 per line and speaker into `site/audio/` plus `index.json` (speaker voices and speeds in `ST_VOICES`; only missing lines unless `--force`; ~1 s per line on this Mac). The licence requires telling listeners the voices are computer-generated: keep the footer note on /learn and the line on /privacy. Gemini (`GEMINI_API_KEY`, 10 requests per model per day) and Google Cloud (`GOOGLE_TTS_API_KEY`) engines remain in the script. The site plays a recording when one exists, else the best browser id-ID voice.
  - Website (2026-11-18): `site/` is a static site for learnbahasa.app (home, `/privacy/`, `/support/`, `/talk/*` fallback for shared chat links, `.well-known/apple-app-site-association` for applinks `/talk/*`). Drawings in `site/assets/` are PNG exports of the app's Canvas drawings; re-export if the drawings change. `vercel.json` / `_headers` / `_redirects` serve the AASA as application/json and route `/talk/*`. The app does not yet declare Associated Domains or handle https `/talk/` links.
  - **Bahasa Plus (2026-11-18):** (now via RevenueCat, see below) `Core/PurchaseManager.swift` (`ProductIDs` monthly/annual, `Access` rules: free = warung + ojek Scenes and Learn units 1–2; plan cached in UserDefaults `bahasa.plan`, `LegalLinks`). `Features/Paywall/PaywallView.swift` (`PaywallContext` .scene/.unit/.general, `.paywall($ctx)` modifier, `PlusBadge`). Every way into a Scene goes through `TalkView.open`; lessons through `LearnView.open`. Plus row lives in ProfileSheet. Test config `Config/Bahasa.storekit` is wired into the scheme (works when run from Xcode, not `simctl launch`). DEBUG: `-plus`/`-free` pin the plan, `-paywall` opens it, `-paywallPreview` shows sample prices. `Bahasa/PrivacyInfo.xcprivacy` declares UserDefaults CA92.1.
  - **RevenueCat + production prep (2026-11-19):** purchases now go through RevenueCat (SPM `purchases-ios-spm` 5.103.x, added by hand to the pbxproj). `PurchaseManager` configures `Purchases` (StoreKit 2) in `start()`, loads the current offering's Annual/Monthly packages (so Test Store IDs `yearly`/`monthly` and App Store IDs both work), buys packages, restores, and treats any active entitlement as Plus (cached in `bahasa.plan`). Key: Info.plist `RevenueCatAPIKey` = `$(REVENUECAT_API_KEY)`; Debug uses the RevenueCat Test Store key (simulated purchase sheet, verified end to end), **Release is empty and must be set to the `appl_` key before archiving** (otherwise the paywall says purchases aren't set up). Display name is now "Learn Bahasa"; `ITSAppUsesNonExemptEncryption = NO`; category Education; `Supporting/Bahasa.entitlements` has `applinks:learnbahasa.app` and `EventRouter.open` accepts `https://learnbahasa.app/talk/<id>`. `PrivacyInfo.xcprivacy` declares Purchase History (not linked, not tracking, app functionality); the privacy page mentions RevenueCat. App Store privacy label: Purchases › Purchase History, App Functionality, not linked, no tracking.
  - **Accounts and sync (2026-11-19):** optional Sign in with Apple (native, nonce) and Google (Supabase OAuth in an ASWebAuthenticationSession, redirect `bahasa://auth-callback`) via Supabase (`supabase-swift` 2.55.x SPM). `Core/Account/AccountManager.swift` (sign in/out, `sync()` pull → `SyncMerge.merge` → `ProgressStore.adopt` → upsert, debounced on progress changes and on app activation, `delete_my_account` RPC, RevenueCat `logIn(userID)` so Plus follows the account) and `SyncDocument.swift` (shared doc: `lessons`, `xp`, `chats{stars,lived}`, `profile`, plus `app` full backup of `ProgressStore.State` + `RehearsalState`; merges only grow progress). Account section in ProfileSheet (hidden when not configured). Web: `site/learn/account.js` + `config.js` (supabase-js 2.118.0 UMD), same document, Apple/Google buttons on the Learn home. DB: `supabase/schema.sql` (table `progress`, RLS own-row, `delete_my_account()`). Config: build settings `SUPABASE_HOST`/`SUPABASE_ANON_KEY` → Info.plist; web `config.js`. Setup steps: `docs/accounts-setup.md`. Entitlement `com.apple.developer.applesignin`. Privacy manifest declares email, user ID, name, other user content, purchase history (linked, app functionality); privacy page updated. Not yet tested against a live Supabase project.
  - **More Scenes (2026-11-18):** four Plus Scenes, each with a new Place, character and drawing: `id.laundry.kiloan` (Mbok Kadek, Survive), `id.apotek.obat` (Mbak Rina, Get by), `id.bengkel.ban` (Bli Made, Get by), `id.tetangga.mampir` (Pak Nyoman, Connect). Drawings: `LaundryDrawing`, `ApotekDrawing`, `BengkelDrawing`, `TetanggaDrawing`; `Figure.Hair.udeng` added for Pak Nyoman. `mbok`/`bli` are matcher particles. `SceneValidator.validateAll` now also runs `lexiconGaps`, so any bubble word without a Lexicon entry fails the DEBUG launch. The paywall `NeighboursBand`, onboarding neighbours and `site/` still show only the first five characters/Scenes.
  - Screenshot a Scene with `-tab talk -scene <id>` (`-scene` alone only works once the Talk tab is showing).
  - Not done yet: callbacks inside other Scenes and the Daily Scene, a `{job}` slot, and the native-speaker check of all Indonesian (required by spec §12.1 before shipping).

## Design direction

Warm, editorial and calm, with a Bali touch. No cartoon mascots and no clutter.

- **Palette:** paper `#F6F1E8` (background), card `#FFFCF6`, ink `#1D1A16`, inkSoft `#6B645A`, line `#E6DDCD`.
  - Accents: sambal `#D4512A` (primary), indigo `#2F3E6B`, kunyit/turmeric `#E3A126`, sawah/rice-paddy `#2E7D5B`, jambu/berry `#B7385E`, laut/sea `#1F7A8C`, kopi `#6F4E37`.
- **Type (updated 2026-11-17):** SF Rounded everywhere, for a cute, soft feel. `Font.display` is rounded and a notch heavier for headings and Indonesian; `Font.ui` and `Font.rounded` are rounded too. The nav bar uses rounded via UIAppearance.
- **Structure (2026-11-17):** every tab and Scene home uses `CozyPage` (`Components/Cozy.swift`): a drawing across the top, then a paper sheet with a big rounded title, one short subtitle and evenly spaced `CozySection`s holding `cozyCard`s. One nudge at most at the top of a page. Keep copy short: one line, no taglines, no stats walls. Each tab has its own drawing in `TabArt` (`Illustrations/Vignettes.swift`). Stage names (Watch, Rehearse, Perform, Live, Recall) are internal only: the UI never shows them. A Scene page has one button (Start / Continue / Play again) and `SceneHomeView.nextStage` picks the practice behind it.
- **Motif:** a subtle **kawung** batik pattern (four-petal ellipses on a grid) drawn with `Canvas`, at low opacity over coloured hero cards. Use it for the app icon too: cream kawung on sambal.
- **Interactions:** "chunky" primary button (darker base layer offset ~4pt, presses down), haptics on select, correct and wrong, and spring animations. Use `matchedGeometryEffect` for word tiles moving between the bank and the answer.
- **Speech:** `AVSpeechSynthesizer` with voice `id-ID`, rate ~0.47 normal and ~0.32 for "slow" (tortoise button). Every Indonesian sentence has a speaker button.

## Architecture

- `BahasaApp` → `RootView` with a `TabView`. Name the enum `AppTab` to avoid clashing with SwiftUI's `Tab`. Tabs:
  - **Learn** (`book.closed.fill`)
  - **Talk** (`bubble.left.and.bubble.right.fill`)
  - **Patterns** (`square.grid.3x2.fill`)
  - **Phrases** (`text.book.closed.fill`)
- Lessons and conversations open as `fullScreenCover`.
- `ProgressStore: ObservableObject` (environment object), persisted as Codable JSON in UserDefaults. It tracks:
  - completed lesson IDs and completed scenario IDs
  - total XP and today's XP (reset on day change; daily goal 30)
  - streak, based on the last active day (`yyyy-MM-dd`): same day = no change, yesterday = +1, otherwise reset to 1
- `Speaker` (singleton, publishes `speakingText`), plus `Haptics` helpers.
- `FlowLayout: Layout` for wrapping chips and word tiles.
- **DEBUG launch args** for screenshot testing: `-tab learn|talk|patterns|phrases`, `-lesson <id>`, `-scenario <id>`.

### Content model
```swift
enum Role { subject(S), verb(V), object(O), time(T), helper(H), negation(N), describe(D), question(Q), link(L), other(X) }  // each has a colour + short label
struct Chip { text; role }            // parse from "Saya/S makan/V nasi_goreng/O" (underscore = space)
struct Example { indo; en; note? }
enum Step { concept(Concept), choice(Choice), build(Build), listen(Listen) }
// builders: .learn(title, body, pattern:, examples:)  .pick(prompt, say:, options, answer:, why:)
//           .arrange(english, "answer words", alt: [...], extras: [...], why:)  .hear(indo, options, answer:, why:)
struct Lesson { id; title; subtitle; symbol; steps }
struct Unit { id; number; indoTitle; title; blurb; color; symbol; lessons }
struct Scenario { id; title; indoTitle; place; symbol; color; character; characterRole; intro; turns: [Turn] }
struct Turn { them: Line(indo, en); replies: [Reply(indo, en, correct, hint?)] }   // last turn has no replies
struct PhraseCategory { title; indoTitle; symbol; color; phrases: [Phrase(indo, en, note?)] }
```

## Screens

- **Learn/Home:**
  - Time-based greeting in serif ("Selamat pagi/siang/sore/malam": before 11, before 15, before 18, otherwise malam), with the English and the date beneath.
  - Streak badge, plus a stats card (daily-goal ring, XP, lessons done).
  - "Up next" hero card in the unit colour with the kawung overlay.
  - The unit path: number badge "01", titles and blurb, and lesson rows marked done ✓ / next / open. All lessons are open; "next" is just highlighted.
- **Lesson player:**
  - Top: close button and an animated progress capsule.
  - Graded steps: the Check button opens a feedback panel. Correct is green "Benar!"; wrong is red "Belum tepat" with the correct answer and a "why" line.
  - Wrong steps are re-queued once at the end.
  - Concept cards show the pattern as coloured role chips with role labels underneath, plus example rows with speaker buttons.
  - Build steps use a Duolingo-style tile bank (a ghost slot stays behind), and accept `alt` answers. Comparison ignores case and punctuation.
  - Listen steps auto-play, with a big play button and a slow button. The Indonesian text is revealed after answering.
  - Completion screen: "Bagus sekali!" with XP (10 + accuracy×10), accuracy, and a confetti burst.
- **Talk:**
  - Scenario cards.
  - Chat view: avatar header, typing indicator before each of their lines, and auto-speak. Tap their bubble to reveal the English.
  - Reply options are shown in Indonesian, with an eye toggle for English hints. A wrong pick shakes and shows its hint. A correct pick appears as your bubble.
  - End card with XP.
- **Patterns:** a grammar cheat sheet made from every concept step, grouped by unit, plus a role colour legend. Rows open a detail view that reuses the concept view.
- **Phrases:** `.searchable`, a horizontal category picker, and phrase rows. Tapping a row speaks it.

## Curriculum (drafted; check the Indonesian when writing it up)

**Unit 1 · Halo! (sambal)**
- **1.1 Greetings**
  - Selamat pagi / siang / sore / malam and their time ranges.
  - Terima kasih → sama-sama; permisi; maaf.
  - Exercises: pick the greeting for 4pm (sore), build "Terima kasih banyak", reply to "Terima kasih!"
- **1.2 Introduce yourself**
  - Nama saya… (possession comes after the noun), Siapa nama Anda / namamu?
  - Saya dari Australia (no "am"), Saya tinggal di Canggu.
  - Senang bertemu dengan Anda, Salam kenal.

**Unit 2 · Pola Dasar (indigo)**
- **2.1 S·V·O**
  - Saya makan nasi. Verbs never conjugate.
  - Pronouns: saya/aku, Anda/kamu, dia (no gender), kita (includes the listener) vs kami (excludes), mereka.
- **2.2 No "to be"**
  - Saya lapar. Kopinya enak. Dia di kantor.
  - adalah is formal and only goes between nouns. Never before an adjective: *Rumah itu adalah besar* is wrong, and that makes a good distractor.
  - ini/itu go after the noun.
- **2.3 Describers go after**
  - kopi panas, nasi goreng, air dingin, es teh manis.
  - Possession: motor saya, motor teman saya, namaku/namamu.

**Unit 3 · Waktu (kunyit)**
- **3.1 Time markers instead of tenses**
  - sudah / sedang / akan / belum + an unchanged verb.
  - kemarin, besok, nanti, tadi.
  - "Sudah makan?" works as a greeting.
- **3.2 belum** (the optimistic "not yet", e.g. "Sudah menikah?" → "Belum"), **pernah**, and **lagi** (again / more / currently: "Lagi apa?", "Satu lagi").

**Unit 4 · Tidak & Bukan (jambu)**
- tidak negates verbs and adjectives; bukan negates nouns ("Ini bukan kopi, ini teh").
- Casual forms: gak / nggak, "Gak apa-apa", "Gak usah".
- jangan: "Jangan pedas, ya", "Jangan lupa".

**Unit 5 · Bertanya (sawah)**
- **5.1 Questions**
  - Rising intonation; apakah is formal.
  - apa, siapa, di/ke/dari mana, kapan, berapa, kenapa, bagaimana.
  - The question word often comes last ("Kamu tinggal di mana?", "Ini berapa?").
  - "Ada wifi?"
- **5.2 Numbers & prices**
  - 1–10, belas, puluh, ratus, ribu, juta; se- = one.
  - "tiga puluh lima ribu", "Berapa harganya?", "Mahal sekali!"

**Unit 6 · Yang & Imbuhan (laut)**
- **6.1 yang = "the one that"**
  - orang yang tinggal di sini; yang merah, yang ini, yang mana?
- **6.2 Prefixes**
  - Casual roots vs formal me-: beli/membeli, baca/membaca.
  - ber- (bekerja, berenang).
  - di- passive: Dilarang parkir, Rumah ini disewakan.

**Unit 7 · Ngobrol (kopi)**
- **7.1 Helpers**
  - mau, bisa, boleh, harus, perlu ("Bisa pelan-pelan?", "Boleh saya duduk di sini?").
  - Register: saya/Anda vs aku/kamu.
  - Forms of address: Pak/Bu, Mas/Mbak, and in Bali Bli/Mbok; Kak is what drivers use.
- **7.2 Particles and short forms**
  - ya, dong, kok, sih, deh.
  - udah, gak, aja, banget, gimana ("Enak banget!", "Satu aja, ya").

**Talk scenarios** (each about 6 exchanges; wrong replies carry a teaching hint)
1. **Lunch at the warung (Ibu):**
   - "Mau makan apa?" → "Saya mau nasi campur, Bu."
   - Spicy level: "Sedikit pedas aja, ya."
   - Drink: "Es teh manis satu."
   - "Makan di sini atau dibungkus?"
   - "Semuanya tiga puluh lima ribu." Distractor: "Lima belas ribu?"
   - "Sama-sama! Selamat makan."
2. **Haggling at the pasar (sarong):**
   - "Lihat-lihat dulu, Bu" → "Yang biru itu. Berapa?"
   - 200rb → "Wah, mahal sekali! Bisa kurang?"
   - 180 → "Seratus ribu, ya?" Distractor: "Seribu" is too cheeky.
   - "Harga pas!" 150 → "Seratus dua puluh. Terakhir, Bu."
   - Deal: "Oke, saya ambil."
3. **Gojek ride:**
   - "Sesuai aplikasi, ke Canggu ya?"
   - Helmet: "Sudah siap?"
   - "Dari mana, Kak?" → "Saya dari Kanada, tapi tinggal di Bali."
   - "Bahasa Indonesianya bagus!" → "Terima kasih, saya masih belajar."
   - "Turun di mana?" → "Di depan kafe itu, ya."
   - "Makasih, Pak! Bintang lima."
4. **Renting a kos room:**
   - "Ada wifi juga?"
   - "Berapa per bulan?" Distractors: "Bulan berapa?", "Berapa orang?"
   - "Lima juta, sudah termasuk listrik."
   - "Kalau sewa enam bulan, bisa lebih murah?"
   - "Empat setengah juta."
   - "Kapan saya bisa pindah?" → "Besok juga boleh!"
5. **Ngopi with a new friend (Putu):**
   - "Boleh duduk di sini?" → "Boleh, silakan!"
   - "Kerja apa?" → "Saya bikin aplikasi iPhone."
   - "Sudah delapan bulan."
   - "Suka banget! Tapi macetnya parah."
   - Volleyball invite → "Kirim lokasinya, ya."

**Phrasebook categories:**
- **Basics:** Apa kabar?, Saya tidak mengerti, Bisa ulangi?, Pelan-pelan, ya, Apa artinya…?
- **Food:** Saya mau pesan, tidak pedas, Saya tidak makan daging, Minta bon, Bungkus, air putih, tanpa gula
- **Getting around:** Kiri, ya (stop here), lurus, belok kanan/kiri, Jauh?, macet, Pom bensin di mana?
- **Shopping:** Bisa kurang?, Harga pas?, Ada ukuran lain?, Bisa bayar pakai QRIS?
- **Home & living:** sewa kamar, Sudah termasuk listrik?, AC-nya rusak, Wifinya mati, air panas, laundry kiloan
- **Social:** Salam kenal, Asalnya dari mana?, Ayo ngopi!, Sampai jumpa, Hati-hati di jalan
- **Emergency:** Tolong!, Saya sakit, Di mana rumah sakit?, Apotek di mana?, Saya kecelakaan motor, Dompet saya hilang

## Conventions
- Indonesian content must be natural, everyday usage, with casual forms noted. Never invent unnatural sentences.
- Keep content in typed Swift (`Content/*.swift`), not JSON.
- Graded steps: shuffle option order once per step, in `@State` set in the initializer.
