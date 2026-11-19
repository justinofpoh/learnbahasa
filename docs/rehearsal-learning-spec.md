# Rehearsal Learning — Format Spec

Version 0.1 · 2026-11-17 · Status: draft. Indonesian (Bahasa) is the first language. The format is meant to work for any language.

---

## 1. One-line definition

**Rehearsal Learning: you practise the real conversations of your life before you live them.**

The unit of learning is a **Scene**, not a word or a grammar rule. A Scene is a real situation with a real goal: ordering lunch, haggling for a sarong, telling the driver where to stop. Grammar, vocabulary and listening are all taught *in service of* Scenes.

## 2. Who it's for

**Primary learner:** an adult who **lives in** (or stays long-term in) the country, such as an expat, digital nomad or long-stay visitor. They meet the same situations every week, so practice can immediately become real life.

**Secondary:** someone about to move or travel there.

**Not for:** exam prep, children, or learners after literary fluency.

Design consequence: Scenes are taken from the learner's actual week (food, transport, housing, shopping, small talk, admin, emergencies), and success is measured outside the app.

## 3. Principles

1. **Scene first.** Everything in the app either *is* a Scene or *prepares for / recalls* a Scene.
2. **Goal over correctness.** You succeed by reaching the Scene's goal. There can be several valid paths.
3. **Produce, don't just recognise.** Support fades from choosing → building → typing → speaking.
4. **Ear before eye.** The other person's lines are heard first. Text is support you can turn on, not the default.
5. **Real speech.** Characters use everyday register, casual forms and natural speed. Textbook-only lines are a bug.
6. **The world reacts first.** A wrong reply gets an in-world reaction (confusion, a clarifying question, a raised eyebrow) before any coach note.
7. **Variation beats memorisation.** Replays change the character's mood, branch and wording.
8. **It's about you.** The learner's own name, origin, home, job and situation fill the lines they say.
9. **Grammar on demand.** Any line can explain itself. Formal lessons are short warm-ups linked from Scenes.
10. **Progress = lines you own.** The learner's record is the set of lines they can actually say, not their XP.

## 4. Vocabulary (terms used across the product)

| Term | Meaning |
|---|---|
| **Scene** | One situation: place + character + goal + conversation graph. |
| **Place** | A group of Scenes in one setting (Warung, Pasar, Jalan, Kos, Teman…). The equivalent of a chapter. |
| **Character** | A recurring person with a name, role, default register and moods. |
| **Goal** | What the learner must achieve, expressed as flags the conversation can set. |
| **Rehearsal** | One play-through of a Scene at a given stage. |
| **Stage** | Watch · Rehearse · Perform · Live · Recall (§5). |
| **Line** | One utterance. Their line = the character's; your line = the learner's. |
| **Your Lines** | The learner's personal collection of lines they have successfully said. |
| **Warm-up** | A ≤2-minute micro-lesson on one pattern, linked from Scenes. |
| **Callback** | A Recall item that appears inside a later Scene or the daily session. |
| **Language Pack** | Everything that varies per language (§10). |

## 5. The Rehearsal Loop

Every Scene goes through five stages. Stages unlock in order per Scene, but every Scene is open from the start.

### 5.1 Watch — "see it happen"
- The Scene plays out automatically. A model learner (named "You") talks with the character.
- Their lines are **audio-first**: the bubble shows a waveform, and text is revealed by tapping or via the global "Show text" toggle.
- After it plays: a 3-item listening check ("What did she ask?", "How much was it?"). Multiple choice, in English.
- Purpose: understand the shape of the conversation and train the ear. Not graded for stars, but completing it unlocks Rehearse.

### 5.2 Rehearse — "guided"
- The learner plays "You". At each turn they get reply support that fades within the Scene:
  - **Choose:** 3–4 options in the target language. English on toggle.
  - **Build:** the reply as shuffled tiles plus 1–2 extra tiles (reuses the lesson tile bank).
- Early turns use Choose and later turns use Build. Turns marked `pattern` focus (§7) always use Build.
- Help is always available: **?** shows the line's role chips and links to its Warm-up; **slow** replays audio at slow speed.
- Wrong replies: in-world reaction first, then a coach note, then retry.

### 5.3 Perform — "your words"
- No options shown. The learner **types or speaks** the reply.
- Speaking is the preferred input and typing is always allowed.
- The character's **mood is randomised** (§8.3) and branches vary.
- **Assists** are available but counted: "show first word", "show options" (drops to Choose for that turn).
- Their lines are audio-only by default. Text costs an assist.
- The input is matched against the accepted replies for that node (§9).

### 5.4 Live — "opening night"
- After a Perform pass, the Scene gets a **Live card**: "Next time you're at a warung, try it."
- The card lists 2–3 key lines from Your Lines for this Scene, as a pocket cheat-card (works offline, big text, tap to play).
- Check-in later (prompted on next app open, or by notification if the learner opts in): *"Did you try it?"* → `Yes, it worked` / `Yes, it was hard` / `Not yet`.
  - "It was hard" asks one follow-up: "What tripped you up?" `Understanding them` / `Remembering what to say` / `They used words I didn't know` / `Nerves`. The answer adjusts Recall and suggests a Scene variant.
- Live is self-reported and never gated or required. It earns the **Lived** mark on the Scene.

### 5.5 Recall — "keep it"
- Lines the learner missed or needed assists on, plus a sample of Your Lines, enter a spaced queue.
- Schedule: 1 → 3 → 7 → 21 → 60 days. A miss resets one step back, not to the start.
- Items come back as **Callbacks**, not flashcards:
  - inside a later Scene (a character asks something from an earlier Scene, e.g. the Gojek driver asks "Sudah makan?")
  - in the **Daily Scene**: a 3-minute mixed mini-Scene stitched from due items.

## 6. Scoring and progress

Per Scene:

| Mark | Earned by |
|---|---|
| ○ Watched | Finished Watch |
| ★ | Reached the goal in Rehearse |
| ★★ | Reached the goal in Perform with ≤2 assists |
| ★★★ | Reached the goal in Perform, no assists, every reply graded Natural |
| ◆ Lived | Live check-in "Yes" |

App-level progress shows, in this order: **Lived Scenes**, then **Your Lines count**, then stars, then streak. XP may stay as a tally but is never the headline.

Daily goal: one Rehearsal (any stage) **or** the Daily Scene.

## 7. Grading replies

Each reply option (and each accepted Perform answer) carries a grade:

| Grade | Meaning | Goal progresses? | Response |
|---|---|---|---|
| **Natural** | What a local would say here. | Yes | Character continues normally. |
| **Understood** | Gets the job done but stiff, too formal, too blunt, or slightly off. | Yes | Character continues, maybe with a tiny in-world cue (a smile, a correction in their own reply). Coach note afterwards: "Locals would say…" |
| **Missed** | Not understood, or means something else. | No | In-world confusion ("Maaf? Nasi apa?"), coach note, retry. |
| **Off** | Rude or culturally inappropriate. | No | In-world reaction (awkward pause, cool reply), coach note about why, retry. |

Rules:
- Every node must have **≥2 Natural** options in the data (Choose shows one of them; Perform accepts all).
- Wrong options must be **plausible learner errors** (English word order, wrong register, false friends, a missing particle), never nonsense.
- Every non-Natural option has both an in-world reaction and a coach note.

## 8. Scene data model (language-agnostic)

Pseudocode; field names are normative and types are illustrative.

```
Scene
  id            "id.warung.lunch"           // <lang>.<place>.<slug>
  language      "id"
  place         PlaceID
  title         { target: "Makan siang di warung", en: "Lunch at the warung" }
  level         survive | getBy | connect   // §11
  character     CharacterID
  goal          { summary: "Order lunch, set the spice, get a drink, pay.",
                  required: [flag], optional: [flag] }
  patterns      [PatternID]                 // Warm-ups this Scene relies on
  culture       [Note]                      // shown in Watch and in the end review
  slots         [SlotID]                    // personal fields used in your lines
  entry         NodeID
  nodes         [Node]

Node
  id            NodeID
  them          Utterance                   // what the character says
  variants      { mood: Utterance }         // optional mood rewrites of `them`
  focus         PatternID?                  // forces Build in Rehearse
  replies       [ReplyOption]               // empty = end node
  timeout       NodeID?                     // Perform only: character fills silence

Utterance
  text          "Mau makan apa?"
  casual        "Makan apa?"                // real-speed / casual form, used in Perform
  gloss         "What would you like to eat?"
  chips         "Mau/H makan/V apa/Q"       // role-tagged, for the ? view
  audio         AudioRef?                   // recorded > TTS when present

ReplyOption
  text          "Nasi campur satu, Bu."     // may contain {slots}
  accept        ["nasi campur satu", ...]   // extra Perform matches
  gloss         "One nasi campur, please."
  grade         natural | understood | missed | off
  sets          [flag]                      // goal flags set
  next          NodeID                      // natural/understood → next node
  reaction      Utterance?                  // in-world response for non-natural
  coach         String?                     // short teaching note
  pattern       PatternID?

Character
  id, name, role
  register      formal | neutral | casual   // how they speak by default
  addressAs     ["Bu", "Ibu"]               // what the learner should call them
  moods         [warm, busy, chatty, tired]
  voice         VoiceRef
```

### 8.1 Branching
- Different Natural/Understood replies can point to different `next` nodes (e.g. asking for "tidak pedas" leads to "Sama sekali tidak?").
- Graph limits: main path ≤8 nodes, ≥1 real branch per Scene, all paths reach an end node, and every `required` goal flag is reachable on every path.

### 8.2 Slots (personalisation)
- Onboarding collects: `{name}`, `{country}`, `{city}`, `{job}`, `{duration}` (how long they've been here).
- The Language Pack supplies target-language forms (`Kanada`, `Australia`, `Inggris`…) and a fallback list.
- Slot values count as correct in Perform matching.

### 8.3 Moods
- Mood changes the character's wording (`variants`), speed, and sometimes which branch they take (a busy owner skips the small talk).
- Rehearse uses the default mood. Perform picks a random mood the learner hasn't cleared yet.

## 9. Matching (Perform)

1. Normalise the input with the Language Pack normaliser (case, punctuation, whitespace, script and romanisation rules).
2. Fill slot values.
3. Compare against every `natural` and `understood` reply's `text` + `accept`, using token-level fuzzy matching: up to 1 typo per 5 characters, plus a per-language list of interchangeable casual forms (`tidak ≈ gak ≈ nggak`, `sudah ≈ udah`, `saja ≈ aja`).
4. Best match wins → apply its grade.
5. If nothing matches, the input counts as Missed. The character reacts with confusion and offers "show first word" as an assist.
6. Speech input: on-device speech recognition → the same pipeline. A low confidence score triggers "Say it again?" (in-world) rather than a fail.

No free-text AI grading in v1 (§13).

## 10. Language Pack

Everything that changes per language lives here, so new languages need content plus a pack, and no format changes.

| Field | Indonesian example | Why it varies |
|---|---|---|
| `roles` | S V O T H N D Q L X (current `Role` enum) | Grammar colour roles differ (Japanese needs particles, Thai needs classifiers). |
| `registers` | formal (saya/Anda) · casual (aku/kamu, gak) | Politeness systems differ widely. |
| `addressTerms` | Pak, Bu, Mas, Mbak, Kak, Bli, Mbok | Who you call what. |
| `speakerForms` | — | Some languages change your words by speaker gender (e.g. Thai polite particles). |
| `script` | Latin | Non-Latin scripts need a romanisation toggle and tile rendering. |
| `romanisation` | — | Thai, Japanese and others. |
| `normaliser` | lowercase, strip punctuation | Tones, diacritics, kana/kanji equivalence. |
| `casualEquivalents` | tidak≈gak≈nggak, sudah≈udah | Used by the matcher. |
| `voice` | id-ID TTS + recorded lines | Voice availability and quality. |
| `slotForms` | country names in Indonesian | Personalisation. |

**Schema test before the second language:** write one Thai or Vietnamese Scene on paper against this schema before any code for language #2.

## 11. Progression

- **Places**, ordered by how soon a newcomer meets them. Indonesian v1: Warung → Jalan (Gojek, directions) → Pasar → Kos → Teman → Kantor/Admin → Darurat.
- **Levels inside each Place:**
  - **Survive:** 2–4 turns, transactional, one goal ("buy water").
  - **Get by:** 5–8 turns, branching, small surprises ("they're out of nasi campur").
  - **Connect:** open small talk with personal slots ("where are you from, why Bali, married yet?").
- The home screen recommends the **next Scene** (the first unwatched Survive Scene in the next Place, or an unfinished Perform). Everything else stays open.
- **Warm-ups:** if a Scene's `patterns` include one the learner hasn't seen, Rehearse offers it first ("Prep · 2 min · No 'to be'") and lets them skip.

## 12. Authoring rules

1. Every line must be checked by a native speaker for naturalness and register before it ships.
2. Each their-line has a `casual` form if locals would say it differently at speed.
3. ≥2 Natural replies per node; wrong options are realistic learner errors with a reaction and a coach note.
4. Culture notes are short (≤2 sentences) and practical ("Don't haggle at a warung; prices are fixed.").
5. Recurring characters keep a consistent personality and register across Scenes.
6. No Scene goal may need vocabulary that isn't in its Warm-ups or in an earlier Scene's lines, except deliberate "surprise" words in Get by and Connect, which must have a gloss.
7. Content stays in typed source files (Swift today), one file per Place.

## 13. Out of scope for v1

- AI-generated conversation or free-text AI grading (candidate for v2 as an optional "Improvise" stage on supported devices, with scripted Scenes as the fallback).
- Pronunciation scoring beyond "was it recognised".
- Accounts, sync, social features.
- Languages other than Indonesian (except the paper schema test in §10).

## 14. How the Bahasa app maps to this

| Today | Becomes |
|---|---|
| Talk tab, `ChatView`, 5 linear scenarios | **Ngobrol** home tab: Places → Scenes, with the Rehearsal Loop in the Scene player |
| `Scenario` / `Turn` / `Reply` | `Scene` / `Node` / `ReplyOption` (§8) |
| Learn tab, 7 units / 15 lessons | **Warm-ups**, opened from Scenes and also browsable in **Belajar** |
| Patterns tab | A section of Belajar; also the **?** view on any line |
| Phrases tab | **Frasa**: Your Lines (top) + reference phrasebook |
| XP, streak, daily ring | Kept, but below Lived count and Your Lines |
| `ProgressStore` | Adds per-Scene stage/stars/Lived, the Recall queue, slots |

Reusable as-is: tile bank (`StepViews`), role chips, `Speaker`, `FlowLayout`, theme and kawung, chat bubbles and typing indicator.

## 15. Success metrics

- **Live rate:** share of Perform-passed Scenes with a "Yes" Live check-in. *The north-star metric.*
- **Perform pass rate** within 3 attempts.
- **Recall accuracy** at the 7-day and 21-day steps.
- **D7 / D30 retention.**
- **Hard-because breakdown:** which reason learners pick most (guides content).

## 16. Decisions taken in this draft (change if you disagree)

1. Primary learner is someone **living there**.
2. Perform accepts **typing or speech**. Speech is encouraged, not required.
3. Variation is **written by hand** (moods + branches). AI is v2 and optional.

## 17. Open questions

1. **Audio:** TTS `id-ID` sounds robotic and can't do casual speed. Record native speakers for their lines (cost, consistency), or use TTS for v1 and record the Survive Scenes first?
2. **Live check-in:** a notification, or only a prompt in the app? Self-report honesty is acceptable, since it isn't gated.
3. **Watch stage:** keep it skippable for confident learners?
4. **Second language:** which one tests the schema best and fits the same audience (Thai, Vietnamese, Japanese)?
5. **Business model:** free with all Places open (as today), or some Places paid?

## Appendix A — Example Scene (abridged)

**id.warung.lunch** · Place: Warung · Level: Get by · Character: Ibu Wayan (warung owner, neutral register, addressed "Bu")
Goal: `ordered_food`, `set_spice`, `paid` (required); `ordered_drink` (optional).

**n1** — *Ibu Wayan:* "Mau makan apa?" (casual: "Makan apa?")
- Natural: "Nasi campur satu, Bu." → sets `ordered_food` → n2
- Natural: "Saya mau nasi campur, Bu." → `ordered_food` → n2
- Understood: "Saya ingin memesan nasi campur." → `ordered_food` → n2 · coach: "Correct but very formal for a warung. 'Nasi campur satu, Bu' is what locals say."
- Missed: "Saya makan nasi campur." · reaction: "Oh, sudah makan?" · coach: "*makan* alone says you're eating. Use *mau* for what you'd like."
- Off: "Nasi campur!" · reaction: a short pause, then "…Iya." · coach: "Too abrupt. Add *Bu* or *satu, ya* to soften it."

**n2** — "Pedas?"
- Natural: "Sedikit aja, Bu." → `set_spice` → n3
- Natural: "Gak pedas, ya." → `set_spice` → n2b
- Missed: "Pedas tidak." · reaction: "Pedas… atau tidak?" · coach: "*tidak* goes before the word it cancels: *tidak pedas*."

**n2b** (branch) — "Sama sekali gak pedas?"
- Natural: "Iya, gak pedas sama sekali." → n3

**n3** — "Minumnya?"
- Natural: "Es teh manis satu." → `ordered_drink` → n4
- Natural: "Gak usah, Bu. Makasih." → n4

**n4** — "Makan sini atau bungkus?"
- Natural: "Makan sini, Bu." → n5
- Natural: "Bungkus aja." → n5

**n5** — "Semuanya tiga puluh lima ribu."
- Natural: "Ini, Bu. Makasih." → `paid` → end
- Missed: "Lima belas ribu?" · reaction: "Tiga puluh lima, Mas/Mbak." · coach: "*belas* = teens, *puluh* = tens."
- Off: "Mahal! Bisa kurang?" · reaction: "Harga pas, ya." · coach: "Warung prices are fixed. Haggle at the pasar, not over lunch."

**end** — "Sama-sama! Selamat makan."

Culture notes: "Call a woman running a warung *Bu*. Prices are fixed and you usually pay after eating."

*(All Indonesian in this appendix still needs the native-speaker check required by §12.)*
