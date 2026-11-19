/* Learn Bahasa on the web. Content comes from /data/content.json, exported from the app's Swift files. */
(function () {
  "use strict";

  const view = document.getElementById("view");
  let C = null; // content

  // ---------- small helpers ----------
  const esc = (s) => String(s ?? "").replace(/[&<>"']/g, (c) => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;" }[c]));
  const shuffle = (a) => { a = a.slice(); for (let i = a.length - 1; i > 0; i--) { const j = Math.floor(Math.random() * (i + 1)); [a[i], a[j]] = [a[j], a[i]]; } return a; };
  const sleep = (ms) => new Promise((r) => setTimeout(r, ms));
  const accent = (name) => `var(--${name})`;
  const roleColor = (role) => `var(--r-${role || "other"})`;
  const ROLE_LABEL = { subject: "subject", verb: "verb", object: "object", time: "time", helper: "helper", negation: "negation", describe: "describer", question: "question", link: "linker", other: "word" };
  const PLACE_ART = { warung: "warung", jalan: "jalan", pasar: "pasar", kos: "kos", teman: "ngopi", laundry: "laundry", apotek: "apotek", bengkel: "bengkel", tetangga: "tetangga" };
  const artFor = (scene) => `/assets/place-${PLACE_ART[scene.id.split(".")[1]] || "warung"}.png`;
  const faceFor = (id) => `/assets/face-${id}.png`;
  const normal = (s) => String(s).toLowerCase().replace(/[.,!?;:"'()…]/g, "").replace(/\s+/g, " ").trim();

  // ---------- storage (per browser, best effort) ----------
  const store = {
    get(key, fallback) { try { const v = localStorage.getItem("lb." + key); return v ? JSON.parse(v) : fallback; } catch { return fallback; } },
    set(key, value) {
      try { localStorage.setItem("lb." + key, JSON.stringify(value)); } catch { /* private mode */ }
      if ((key === "progress" || key === "profile") && window.LBAccount) window.LBAccount.schedule();
    },
  };
  const progress = () => store.get("progress", { done: [], xp: 0, chats: [] });
  const profile = () => store.get("profile", { name: "", country: "", city: "" });
  const pace = () => store.get("pace", "normal");
  const PACE = { relaxed: { pause: 1.7, rate: 0.85 }, normal: { pause: 1, rate: 1 }, local: { pause: 0.7, rate: 1.1 } };

  // ---------- speech ----------
  // 1. Recorded neural voices (site/audio, made by tools/voice/make_audio.py), one per speaker.
  // 2. Otherwise the best Indonesian voice the browser has.
  let audioIndex = {};
  let current = null;
  const speechKey = (text) => String(text).replace(/…/g, "").replace(/\s+/g, " ").trim();

  let voice = null;
  function pickVoice() {
    if (!("speechSynthesis" in window)) return;
    const ids = speechSynthesis.getVoices().filter((v) => /^id([-_]|$)/i.test(v.lang));
    const score = (v) => (/natural|neural|online|premium|enhanced/i.test(v.name) ? 4 : 0) + (/google/i.test(v.name) ? 3 : 0)
      + (/damayanti|gadis|ardi/i.test(v.name) ? 2 : 0) + (v.localService ? 0 : 1);
    voice = ids.sort((a, b) => score(b) - score(a))[0] || null;
  }
  if ("speechSynthesis" in window) { pickVoice(); speechSynthesis.onvoiceschanged = pickVoice; }

  function stopSpeech() {
    if (current) { current.pause(); current = null; }
    if ("speechSynthesis" in window) speechSynthesis.cancel();
  }

  function speak(text, slow = false, role = "tutor") {
    const line = speechKey(text);
    const file = audioIndex[`${role}|${line}`] || audioIndex[`tutor|${line}`];
    stopSpeech();
    const rate = slow ? 0.72 : PACE[pace()].rate;
    if (file) {
      return new Promise((resolve) => {
        const a = new Audio(`/audio/${file}.mp3`);
        a.playbackRate = rate;
        a.preservesPitch = true;
        current = a;
        let done = false;
        const finish = () => { if (!done) { done = true; if (current === a) current = null; resolve(); } };
        a.onended = finish; a.onerror = () => { finish(); };
        a.play().catch(() => finish());
        setTimeout(finish, 1500 + line.length * 160 / rate);
      });
    }
    return new Promise((resolve) => {
      if (!("speechSynthesis" in window)) return resolve();
      const u = new SpeechSynthesisUtterance(line);
      u.lang = "id-ID";
      if (voice) u.voice = voice;
      u.rate = slow ? 0.65 : 0.92 * rate;
      let done = false;
      const finish = () => { if (!done) { done = true; resolve(); } };
      u.onend = finish; u.onerror = finish;
      setTimeout(finish, 800 + line.length * 130);
      speechSynthesis.speak(u);
    });
  }
  const sayButton = (text, slow, role = "tutor") => `<button class="say${slow ? " slow" : ""}" data-say="${esc(text)}" data-role="${esc(role)}"${slow ? ' data-slow="1"' : ""} aria-label="${slow ? "Play slowly" : "Play"}">${slow ? "🐢" : "🔊"}</button>`;

  // ---------- dictionary (mirrors Lexicon.lookup in the app) ----------
  function lookup(raw) {
    const w = String(raw).toLowerCase().replace(/[^a-z\-]/g, "");
    if (!w) return null;
    const L = C.lexicon;
    if (L[w]) return { shown: w, ...L[w] };
    if (C.places[w]) return { shown: w, meaning: C.places[w], role: "object", note: "A place name. Names stay the same in Indonesian." };
    const endings = [["-nya", "-nya points at something you both know: “the”, “its” or “your”."], ["-mu", "-mu means “your” (casual)."],
      ["nya", "-nya points at something you both know: “the”, “its” or “your”."], ["mu", "-mu means “your” (casual)."], ["ku", "-ku means “my” (casual)."]];
    for (const [end, note] of endings) {
      if (w.endsWith(end) && w.length > end.length + 1) {
        const base = w.slice(0, -end.length);
        if (L[base]) return { shown: w, ...L[base], extra: note };
      }
    }
    const parts = w.split("-");
    if (parts.length === 2 && parts[0] === parts[1] && L[parts[0]]) return { shown: w, ...L[parts[0]], extra: "Doubled words soften or spread the meaning." };
    return null;
  }
  // Wraps every word we can explain in a tappable span.
  function words(text) {
    return esc(text).split(/(\s+)/).map((tok) => {
      if (/^\s+$/.test(tok)) return tok;
      const bare = tok.replace(/&[a-z#0-9]+;/g, "").replace(/[^A-Za-z\-]/g, "");
      return bare && lookup(bare) ? `<span class="w" data-word="${esc(bare)}">${tok}</span>` : tok;
    }).join("");
  }
  function showWord(word) {
    const r = lookup(word);
    if (!r) return;
    closePop();
    const pop = document.createElement("div");
    pop.className = "pop";
    pop.setAttribute("role", "dialog");
    pop.innerHTML = `<img src="${faceFor("kak-dewi")}" alt="">
      <div><b>${esc(r.shown)}</b><span class="role" style="background:${roleColor(r.role)}">${ROLE_LABEL[r.role] || "word"}</span>
      <p><strong style="color:var(--ink)">${esc(r.meaning)}</strong></p>${r.note ? `<p>${esc(r.note)}</p>` : ""}${r.extra ? `<p>${esc(r.extra)}</p>` : ""}</div>
      <button class="close" aria-label="Close">×</button>`;
    document.body.appendChild(pop);
    speak(r.shown);
  }
  const closePop = () => document.querySelectorAll(".pop").forEach((p) => p.remove());

  // Global taps: speaker buttons, words, popup close.
  document.addEventListener("click", (e) => {
    const say = e.target.closest("[data-say]");
    if (say) { say.classList.add("speaking"); speak(say.dataset.say, !!say.dataset.slow, say.dataset.role || "tutor").then(() => say.classList.remove("speaking")); return; }
    const w = e.target.closest(".w");
    if (w) { showWord(w.dataset.word); return; }
    if (e.target.closest(".pop .close") || !e.target.closest(".pop")) closePop();
  });
  document.addEventListener("keydown", (e) => { if (e.key === "Escape") closePop(); });

  // ---------- slots ----------
  function fill(text) {
    const p = profile();
    return String(text)
      .replaceAll("{name}", p.name || C.fallbacks.name || "Alex")
      .replaceAll("{country}", p.country || C.fallbacks.country || "Australia")
      .replaceAll("{city}", p.city || C.fallbacks.city || "Canggu")
      .replaceAll("{job}", "");
  }

  // ---------- routing ----------
  let cleanup = null;
  function route() {
    if (cleanup) { cleanup(); cleanup = null; }
    closePop();
    stopSpeech();
    const h = location.hash.replace(/^#\/?/, "");
    const [page, arg] = h.split("/");
    document.querySelectorAll("[data-nav]").forEach((a) => a.classList.toggle("on", a.dataset.nav === (page || "home")));
    window.scrollTo(0, 0);
    if (page === "lesson") return lessonPage(arg);
    if (page === "chat") return chatPage(arg);
    if (page === "phrases") return phrasesPage();
    if (page === "patterns") return patternsPage();
    return homePage();
  }

  // ---------- home ----------
  function greeting() {
    const h = new Date().getHours();
    if (h < 11) return ["Selamat pagi", "Good morning"];
    if (h < 15) return ["Selamat siang", "Good day"];
    if (h < 18) return ["Selamat sore", "Good afternoon"];
    return ["Selamat malam", "Good evening"];
  }
  const allLessons = () => C.units.flatMap((u) => u.lessons.map((l) => ({ ...l, unit: u })));

  // ---------- progression: stages open one after another ----------
  // Each unit is a stage. A stage opens when the one before it is finished (or the learner skips ahead).
  // Chats open with the stage whose words they need.
  const STAGE_CHATS = { 1: ["id.warung.lunch"], 2: ["id.jalan.ojek"], 3: ["id.laundry.kiloan"], 5: ["id.pasar.sarong", "id.kos.kamar"],
    6: ["id.apotek.obat"], 7: ["id.teman.ngopi", "id.bengkel.ban"], 9: ["id.tetangga.mampir"] };
  const stageOfChat = (id) => +(Object.keys(STAGE_CHATS).find((k) => STAGE_CHATS[k].includes(id)) || 1);
  const stageDone = (u, done) => u.lessons.every((l) => done.has(l.id));
  function stageOpen(n, done) {
    if (n <= 1 || n <= (store.get("skipTo", 1))) return true;
    const prev = C.units.find((u) => u.number === n - 1);
    return !prev || stageDone(prev, done);
  }
  function currentStage(done) {
    let n = 1;
    for (const u of C.units) if (stageOpen(u.number, done)) n = u.number;
    return C.units.find((u) => u.number === n) || C.units[0];
  }
  function nextLesson() {
    const done = new Set(progress().done);
    return allLessons().find((l) => stageOpen(l.unit.number, done) && !done.has(l.id));
  }

  function homePage() {
    document.title = "Learn · Learn Bahasa";
    const [indo, en] = greeting();
    const p = progress();
    const done = new Set(p.done);
    const next = nextLesson();
    const me = profile();
    const stage = currentStage(done);
    const stageCount = stage.lessons.filter((l) => done.has(l.id)).length;
    const total = allLessons().length;
    const reviewable = allLessons().filter((l) => done.has(l.id)).length;
    view.innerHTML = `
      <div class="hello"><img src="${faceFor("ibu-wayan")}" alt=""><div><h1>${indo}</h1><p>${en}</p></div></div>
      <div class="stack">
        <section class="card level">
          <div class="level-top"><span class="unit-badge" style="background:${accent(stage.accent)}">${stage.number}</span>
            <div><small>Stage ${stage.number} of ${C.units.length}</small><b>${esc(stage.indoTitle)} · ${esc(stage.title)}</b></div>
            <span class="xp">${p.xp} XP</span></div>
          <div class="track big"><i style="width:${Math.round((stageCount / stage.lessons.length) * 100)}%;background:${accent(stage.accent)}"></i></div>
          <p class="note">${stageCount === stage.lessons.length && stage.number < C.units.length ? "Stage finished. The next one is open!" : `${stageCount} of ${stage.lessons.length} lessons in this stage`} · ${p.done.length}/${total} lessons · ${p.chats.length}/${C.scenes.length} chats</p>
        </section>

        ${next ? `<a class="card app-cta kawung" style="background-color:${accent(next.unit.accent)};text-decoration:none" href="#/lesson/${next.id}">
            <div><p>Up next · Stage ${next.unit.number}</p><b style="font-size:24px">${esc(next.title)}</b><p>${esc(next.subtitle)}</p></div>
            <span class="btn small" style="margin-left:auto">Start ▶</span></a>` : ""}
        ${reviewable >= 2 ? `<a class="card review" href="#/lesson/review"><span>🔁</span><div><b>Quick review</b><small>8 questions from lessons you've done</small></div><span class="tail">▶</span></a>` : ""}

        <section class="path">${C.units.map((u) => stageBlock(u, done, next, p)).join("")}</section>

        <section class="sect" id="account-card" hidden></section>

        <section class="sect">
          <h2>About you</h2>
          <p class="note">Your details fill the lines you say, like “Saya dari ${esc(me.country || "Australia")}”. Saved in this browser only.</p>
          <form class="card you" id="you" onsubmit="return false">
            <label for="you-name">Your name<input id="you-name" autocomplete="given-name" value="${esc(me.name)}" placeholder="Alex"></label>
            <label for="you-country">From<select id="you-country">${COUNTRIES.map(([en, local]) => `<option value="${esc(local)}"${local === me.country ? " selected" : ""}>${esc(en)}</option>`).join("")}</select></label>
          </form>
        </section>
      </div>`;
    if (window.LBAccount) window.LBAccount.render();
    document.getElementById("you").addEventListener("input", () => {
      store.set("profile", { ...profile(), name: document.getElementById("you-name").value.trim(), country: document.getElementById("you-country").value });
    });
    view.querySelectorAll("[data-skip]").forEach((b) => b.onclick = () => {
      const n = +b.dataset.skip;
      const msg = b.parentElement.querySelector(".skip-confirm");
      if (!msg.hidden) { store.set("skipTo", n); homePage(); return; }
      msg.hidden = false; b.textContent = "Yes, open it";
    });
  }

  function stageBlock(u, done, next, p) {
    const open = stageOpen(u.number, done);
    const finished = stageDone(u, done);
    const count = u.lessons.filter((l) => done.has(l.id)).length;
    const chats = (STAGE_CHATS[u.number] || []).map((id) => C.scenes.find((s) => s.id === id)).filter(Boolean);
    const tint = accent(u.accent);
    return `<section class="stage-block${open ? "" : " shut"}${finished ? " finished" : ""}">
      <div class="unit-head"><span class="unit-badge" style="background:${open ? tint : "#B9AE9C"}">${finished ? "✓" : u.number}</span>
        <div><small style="color:${tint};font-weight:800">STAGE ${u.number}</small><b>${esc(u.indoTitle)}</b><span>${esc(u.title)}</span></div>
        <span class="count" style="color:${open ? tint : "var(--ink-soft)"}">${open ? `${count}/${u.lessons.length}` : "🔒"}</span></div>
      ${open ? "" : `<div class="card shut-note"><span>Finish Stage ${u.number - 1} to open this one.</span>
        <button class="btn ghost small" data-skip="${u.number}">Skip ahead</button><span class="skip-confirm" hidden>Already know the earlier stages? Tap again to open Stage ${u.number}.</span></div>`}
      <div class="card rows">${u.lessons.map((l) => {
        const isDone = done.has(l.id), isNext = next && next.id === l.id;
        const dot = `<span class="dot${isDone ? " done" : ""}" style="${isDone ? `background:${tint}` : isNext ? `background:${tint}22;color:${tint}` : ""}">${isDone ? "✓" : isNext ? "▶" : open ? "•" : "🔒"}</span>`;
        return open
          ? `<a class="row" href="#/lesson/${l.id}">${dot}<span><b>${esc(l.title)}</b><small>${esc(l.subtitle)}</small></span>${isNext ? `<span class="tail" style="color:${tint}">next</span>` : ""}</a>`
          : `<div class="row" aria-disabled="true">${dot}<span><b>${esc(l.title)}</b><small>${esc(l.subtitle)}</small></span></div>`;
      }).join("")}</div>
      ${chats.length ? `<div class="chats stage-chats">${chats.map((s) => chatCard(s, open, p)).join("")}</div>` : ""}
    </section>`;
  }

  function chatCard(s, open, p) {
    const inner = `<img class="art" src="${artFor(s)}" alt="" loading="lazy" onerror="this.style.visibility='hidden'">
      ${open ? (p.chats.includes(s.id) ? '<span class="lock" style="color:var(--benar)">✓ Done</span>' : '<span class="lock" style="color:var(--laut)">Chat</span>') : '<span class="lock">🔒 Opens with this stage</span>'}
      <div class="meta"><img src="${faceFor(s.character)}" alt="" onerror="this.style.visibility='hidden'">
        <div><b>${esc(s.title)}</b><span>${esc(s.characterName)} · ${esc(s.titleEn)}</span></div></div>`;
    return open ? `<a class="card chat-card" href="#/chat/${s.id}">${inner}</a>` : `<div class="card chat-card locked" aria-disabled="true">${inner}</div>`;
  }

  // A review built from graded steps of lessons the learner has finished.
  function reviewLesson() {
    const done = new Set(progress().done);
    const pool = allLessons().filter((l) => done.has(l.id)).flatMap((l) => l.steps.filter((s) => s.kind !== "learn").map((s) => ({ ...s, from: l })));
    const picks = shuffle(pool).slice(0, 8);
    const unit = currentStage(done);
    return { id: "review", title: "Quick review", subtitle: "From lessons you've done", steps: picks, unit, review: true };
  }

  const COUNTRIES = [["Australia", "Australia"], ["Canada", "Kanada"], ["United States", "Amerika"], ["United Kingdom", "Inggris"],
    ["Germany", "Jerman"], ["Netherlands", "Belanda"], ["France", "Prancis"], ["New Zealand", "Selandia Baru"], ["Singapore", "Singapura"],
    ["Russia", "Rusia"], ["Japan", "Jepang"], ["India", "India"], ["Italy", "Italia"], ["Spain", "Spanyol"], ["Brazil", "Brasil"]];

  // ---------- lesson player ----------
  function lessonPage(id) {
    const lesson = id === "review" ? reviewLesson() : allLessons().find((l) => l.id === id);
    if (!lesson || !lesson.steps.length || (!lesson.review && !stageOpen(lesson.unit.number, new Set(progress().done)))) { location.hash = "#/"; return; }
    document.title = `${lesson.title} · Learn Bahasa`;
    const unit = lesson.unit;
    const tint = accent(unit.accent);
    const queue = lesson.steps.map((s, i) => ({ ...s, key: i }));
    const graded = queue.filter((s) => s.kind !== "learn").length;
    const requeued = new Set();
    let index = 0, right = 0, firstTry = 0;

    view.innerHTML = `<div class="player">
      <div class="bar"><a class="x" href="#/" aria-label="Close">✕</a><div class="track"><i id="fill" style="background:${tint}"></i></div><span class="num" id="num" style="color:${tint}"></span></div>
      <div id="stage"></div>
      <div class="foot" id="foot"></div></div>`;
    const stage = document.getElementById("stage");
    const foot = document.getElementById("foot");

    function progressBar() {
      document.getElementById("fill").style.width = `${Math.round((index / queue.length) * 100)}%`;
      document.getElementById("num").textContent = `${Math.min(index + 1, queue.length)}/${queue.length}`;
    }

    function tutor(text) { return `<div class="tutor"><img src="${faceFor("kak-dewi")}" alt=""><span>${esc(text)}</span></div>`; }

    function render() {
      progressBar();
      if (index >= queue.length) return finish();
      const s = queue[index];
      const again = requeued.has(s.key) && s.again ? "One more go. " : "";
      if (s.kind === "learn") {
        stage.innerHTML = `<div class="stage">${tutor("Here's the trick ✨")}
          <h2>${esc(s.title)}</h2><p class="body">${esc(s.body)}</p>
          ${s.pattern ? `<div class="card chipline">${s.pattern.map((c) => `<span class="chip"><b style="color:${roleColor(c.role)};border-color:${roleColor(c.role)}33;background:${roleColor(c.role)}12">${esc(c.text)}</b><small style="color:${roleColor(c.role)}">${ROLE_LABEL[c.role]}</small></span>`).join("")}</div>` : ""}
          ${s.examples && s.examples.length ? `<div class="card examples">${s.examples.map((e) => `<div class="ex"><div><b>${words(e.indo)}</b><span>${esc(e.en)}</span>${e.note ? `<em>${esc(e.note)}</em>` : ""}</div>${sayButton(e.indo.replace(/ · .*/, ""))}</div>`).join("")}</div>` : ""}
        </div>`;
        foot.innerHTML = `<button class="btn block" id="go" style="background:${tint}">Lanjut</button>`;
        document.getElementById("go").onclick = () => { index++; render(); };
        return;
      }
      if (s.kind === "pick" || s.kind === "hear") return choice(s, again);
      if (s.kind === "arrange") return arrange(s, again);
    }

    function choice(s, again) {
      if (!s.shuffled) s.shuffled = shuffle(s.options);
      const isHear = s.kind === "hear";
      stage.innerHTML = `<div class="stage">${tutor(again + (isHear ? "Listen closely 👂" : "Which one sounds right?"))}
        ${isHear ? `<div class="hear-center"><button class="say big" data-say="${esc(s.say)}" aria-label="Play">🔊</button><button class="say bigslow" data-say="${esc(s.say)}" data-slow="1" aria-label="Play slowly">🐢</button></div><div class="reveal" id="reveal"></div><h2 style="font-size:20px">What did you hear?</h2>`
          : `<h2>${esc(s.prompt)}</h2>${s.say ? `<div class="card examples"><div class="ex"><div><b>${words(s.say)}</b></div>${sayButton(s.say)}</div></div>` : ""}`}
        <div class="opts">${s.shuffled.map((o, i) => `<button class="opt" data-i="${i}">${esc(o)}</button>`).join("")}</div></div>`;
      let picked = null;
      const check = document.createElement("button");
      foot.innerHTML = "";
      check.className = "btn block"; check.textContent = "Periksa"; check.disabled = true;
      foot.appendChild(check);
      stage.querySelectorAll(".opt").forEach((b) => b.onclick = () => {
        stage.querySelectorAll(".opt").forEach((x) => x.classList.remove("sel"));
        b.classList.add("sel"); picked = s.shuffled[+b.dataset.i]; check.disabled = false;
      });
      if (isHear) setTimeout(() => speak(s.say), 350);
      check.onclick = () => {
        const ok = picked === s.answer;
        stage.querySelectorAll(".opt").forEach((b) => {
          b.disabled = true;
          const v = s.shuffled[+b.dataset.i];
          if (v === s.answer) b.classList.add("right"); else if (v === picked) b.classList.add("wrong");
        });
        if (isHear) document.getElementById("reveal").innerHTML = words(s.say);
        feedback(s, ok, s.answer);
      };
    }

    function arrange(s, again) {
      const tiles = shuffle([...s.answer.split(" "), ...(s.extras || [])]).map((t, i) => ({ t, i, used: false }));
      const line = [];
      stage.innerHTML = `<div class="stage">${tutor(again + "Build it, tile by tile 🧩")}
        <h2>${esc(s.prompt)}</h2>
        <div class="answer-line" id="line"></div><div class="bank" id="bank"></div></div>`;
      foot.innerHTML = `<button class="btn block" id="check" disabled>Periksa</button>`;
      const lineEl = document.getElementById("line"), bankEl = document.getElementById("bank"), check = document.getElementById("check");
      function draw() {
        lineEl.innerHTML = line.map((tile) => `<button class="tile" data-line="${tile.i}">${esc(tile.t)}</button>`).join("");
        bankEl.innerHTML = tiles.map((tile) => `<button class="tile${tile.used ? " ghost" : ""}" data-bank="${tile.i}"${tile.used ? ' tabindex="-1" aria-hidden="true"' : ""}>${esc(tile.t)}</button>`).join("");
        check.disabled = line.length === 0;
      }
      stage.addEventListener("click", (e) => {
        if (check.dataset.locked) return;
        const b = e.target.closest("[data-bank]"), l = e.target.closest("[data-line]");
        if (b) { const tile = tiles.find((x) => x.i === +b.dataset.bank); if (!tile.used) { tile.used = true; line.push(tile); speak(tile.t); } draw(); }
        if (l) { const k = line.findIndex((x) => x.i === +l.dataset.line); if (k >= 0) { line[k].used = false; line.splice(k, 1); } draw(); }
      });
      draw();
      check.onclick = () => {
        check.dataset.locked = "1";
        const given = line.map((x) => x.t).join(" ");
        const ok = [s.answer, ...(s.alt || [])].some((a) => normal(a) === normal(given));
        feedback(s, ok, s.answer);
      };
    }

    function feedback(s, ok, answer) {
      if (ok) { right++; if (!requeued.has(s.key)) firstTry++; } else if (!requeued.has(s.key)) { requeued.add(s.key); queue.push({ ...s, again: true }); }
      foot.innerHTML = `<div class="feedback ${ok ? "ok" : "no"}"><b>${ok ? "Benar! ✓" : "Belum tepat"}</b>
        ${ok ? "" : `<p><strong>${esc(answer)}</strong></p>`}<p>${esc(s.why)}</p></div>
        <button class="btn block ${ok ? "green" : "red"}" id="next">Lanjut</button>`;
      if (s.kind === "arrange" && ok) speak(answer);
      const n = document.getElementById("next"); n.focus();
      n.onclick = () => { index++; render(); };
    }

    function finish() {
      const accuracy = graded ? firstTry / graded : 1;
      const xp = 10 + Math.round(accuracy * 10);
      const p = progress();
      const before = new Set(p.done);
      if (!lesson.review && !before.has(lesson.id)) p.done.push(lesson.id);
      p.xp += xp;
      store.set("progress", p);
      const after = new Set(p.done);
      const finishedStage = !lesson.review && !stageDone(unit, before) && stageDone(unit, after);
      const opened = finishedStage ? C.units.find((u) => u.number === unit.number + 1) : null;
      const next = nextLesson();
      stage.innerHTML = `<div class="stage done"><img src="${faceFor("kak-dewi")}" alt="" style="width:110px;height:110px">
        <h2>${finishedStage ? `Stage ${unit.number} done!` : "Bagus sekali!"}</h2>
        <p class="body">${finishedStage ? (opened ? `Stage ${opened.number}, ${esc(opened.indoTitle)}, is open now.` : "You've finished every stage. Luar biasa!") : `${esc(lesson.title)} done.`}</p>
        <div class="stats"><div><b>+${xp}</b><span>XP</span></div><div><b>${Math.round(accuracy * 100)}%</b><span>first try</span></div></div></div>`;
      foot.innerHTML = next ? `<a class="btn block" href="#/lesson/${next.id}">Next: ${esc(next.title)}</a><a class="btn ghost block" href="#/">Back to Learn</a>`
        : `<a class="btn block" href="#/">Back to Learn</a>`;
      confetti();
      speak("Bagus sekali!");
    }

    render();
  }

  function confetti() {
    if (matchMedia("(prefers-reduced-motion: reduce)").matches) return;
    const box = document.createElement("div");
    box.className = "confetti";
    const colors = ["#D4512A", "#E3A126", "#2E7D5B", "#1F7A8C", "#B7385E", "#2F3E6B"];
    for (let i = 0; i < 60; i++) {
      const p = document.createElement("i");
      p.style.left = Math.random() * 100 + "%";
      p.style.background = colors[i % colors.length];
      p.style.animationDelay = Math.random() * 0.5 + "s";
      p.style.animationDuration = 1.4 + Math.random() + "s";
      box.appendChild(p);
    }
    document.body.appendChild(box);
    setTimeout(() => box.remove(), 3200);
  }

  // ---------- chat player (choose your reply) ----------
  function chatPage(id) {
    const scene = C.scenes.find((s) => s.id === id);
    if (!scene || !scene.nodes.length || !stageOpen(stageOfChat(scene.id), new Set(progress().done))) { location.hash = "#/"; return; }
    document.title = `${scene.title} · Learn Bahasa`;
    const tint = accent(scene.accent);
    const nodes = Object.fromEntries(scene.nodes.map((n) => [n.id, n]));
    const flags = new Set();
    let alive = true;
    cleanup = () => { alive = false; };
    const wait = (s) => sleep(s * 1000 * PACE[pace()].pause);

    view.innerHTML = `<div class="player chat">
      <div class="bar"><a class="x" href="#/" aria-label="Close">✕</a><div style="flex:1"></div>
        <label class="pace" for="pace">Speed <select id="pace"><option value="relaxed">🐢 Relaxed</option><option value="normal">Normal</option><option value="local">🐇 Like a local</option></select></label></div>
      <div class="chat-top"><img class="art" src="${artFor(scene)}" alt="">
        <div class="nameplate"><img src="${faceFor(scene.character)}" alt=""><span>${esc(scene.characterName)}<small id="status">${esc(scene.characterRole)}</small></span></div></div>
      <div class="goals" id="goals"></div>
      <div class="log" id="log"></div>
      <div class="foot" id="foot"></div></div>`;
    const sel = document.getElementById("pace");
    sel.value = pace();
    sel.onchange = () => store.set("pace", sel.value);
    const log = document.getElementById("log"), foot = document.getElementById("foot"), status = document.getElementById("status");
    const drawGoals = () => {
      document.getElementById("goals").innerHTML = scene.goals.map((g) => `<span class="${flags.has(g.id) ? "on" : ""}">${flags.has(g.id) ? "✓ " : ""}${esc(g.label)}</span>`).join("");
    };
    drawGoals();

    const add = (html, cls) => { const d = document.createElement("div"); d.className = cls; d.innerHTML = html; log.appendChild(d); d.scrollIntoView({ behavior: "smooth", block: "end" }); return d; };
    async function them(u) {
      const t = add("<i></i><i></i><i></i>", "typing"); status.textContent = "typing…";
      await wait(0.9);
      t.remove();
      if (!alive) return;
      const text = fill(u.text);
      const m = add(`${words(text)}<span class="gloss" hidden>${esc(fill(u.gloss))}</span>
        <span class="tools"><button data-en>Show English</button>${sayButton(text, true, scene.character).replace('class="say slow"', 'class="say slow" style="width:30px;height:30px;font-size:13px"')}</span>`, "msg them");
      m.querySelector("[data-en]").onclick = (e) => { const g = m.querySelector(".gloss"); g.hidden = !g.hidden; e.target.textContent = g.hidden ? "Show English" : "Hide English"; };
      status.textContent = "speaking";
      await speak(text, false, scene.character);
      status.textContent = scene.characterRole;
    }

    async function present(nodeId) {
      const node = nodes[nodeId];
      if (!node || !alive) return;
      if (node.narration) { add(esc(node.narration), "narr"); await wait(0.6); }
      await them(node.them);
      if (!alive) return;
      if (!node.replies.length) return end();
      const naturals = node.replies.filter((r) => r.grade === "natural");
      const wrong = shuffle(node.replies.filter((r) => r.grade === "missed" || r.grade === "off")).slice(0, 2);
      const understood = node.replies.filter((r) => r.grade === "understood");
      const picks = [naturals[Math.floor(Math.random() * naturals.length)], ...wrong];
      if (picks.length < 3 && understood.length) picks.push(understood[0]);
      const options = shuffle(picks.filter(Boolean));
      const ruled = new Set();
      foot.innerHTML = `<p style="font-weight:800;margin-bottom:8px">Your reply</p><div class="opts">${options.map((o, i) => `<button class="opt" data-i="${i}"><span>${esc(fill(o.text))}</span><small style="color:var(--ink-soft);font-weight:600" hidden>${esc(fill(o.gloss))}</small></button>`).join("")}</div>
        <button class="btn ghost small" id="hint" style="margin-top:6px">Show English hints</button>`;
      foot.scrollIntoView({ behavior: "smooth", block: "end" });
      document.getElementById("hint").onclick = (e) => { foot.querySelectorAll(".opt small").forEach((s) => s.hidden = !s.hidden); e.target.textContent = e.target.textContent.startsWith("Show") ? "Hide English hints" : "Show English hints"; };
      foot.querySelectorAll(".opt").forEach((b) => b.onclick = async () => {
        const o = options[+b.dataset.i];
        if (ruled.has(o)) return;
        const said = fill(o.text);
        const passes = o.grade === "natural" || o.grade === "understood";
        if (passes) {
          foot.innerHTML = "";
          add(`${esc(said)}<span class="gloss">${esc(fill(o.gloss))}</span>`, "msg me");
          (o.sets || []).forEach((f) => flags.add(f)); drawGoals();
          await speak(said, false, "learner");
          if (o.grade === "understood" && o.coach) { add(esc(fill(o.coach)), "coach understood"); await wait(1.4); }
          await wait(0.3);
          if (o.next) present(o.next); else end();
        } else {
          ruled.add(o);
          b.disabled = true; b.classList.add("wrong", "shake");
          add(esc(said), "msg me missed");
          await wait(0.5);
          if (o.reaction) await them(o.reaction);
          if (o.coach) add(esc(fill(o.coach)), "coach");
        }
      });
    }

    function end() {
      const reached = scene.goals.filter((g) => !g.optional).every((g) => flags.has(g.id));
      const p = progress();
      if (!p.chats.includes(scene.id)) { p.chats.push(scene.id); p.xp += 20; store.set("progress", p); }
      foot.innerHTML = `<div class="card" style="padding:18px;text-align:center;display:flex;flex-direction:column;gap:10px;align-items:center">
        <img src="${faceFor(scene.character)}" alt="" style="width:80px;height:80px"><b style="font-size:22px">${reached ? "Berhasil! You did it." : "Nice chat!"}</b>
        <p style="color:var(--ink-soft)">${esc(scene.goalSummary)}</p>
        ${scene.culture && scene.culture[0] ? `<p class="voice-note">💡 ${esc(scene.culture[0])}</p>` : ""}
        <div style="display:flex;gap:10px;flex-wrap:wrap;justify-content:center"><a class="btn small" href="#/chat/${scene.id}" onclick="setTimeout(()=>location.reload(),0)">Play again</a><a class="btn small" href="#/" style="background:var(--ink);box-shadow:0 3px 0 #000">Back to Learn</a></div></div>`;
      if (reached) confetti();
    }

    (async () => {
      add(esc(scene.setting), "narr");
      if (!Object.keys(audioIndex).length && !voice && "speechSynthesis" in window) add("No Indonesian voice in this browser, so lines may sound English-accented. Safari and Chrome usually have one.", "voice-note");
      await wait(0.5);
      present(scene.entry);
    })();
  }

  // ---------- phrasebook ----------
  function phrasesPage() {
    document.title = "Phrases · Learn Bahasa";
    let cat = store.get("phraseCat", C.phrasebook[0].id);
    view.innerHTML = `<div class="hello"><img src="${faceFor("bu-ketut")}" alt=""><div><h1>Frasa</h1><p>Tap a line to hear it. Tap a word to look it up.</p></div></div>
      <input class="search" id="q" type="search" placeholder="Search phrases in English or Indonesian" aria-label="Search phrases">
      <div class="tabs" id="tabs" role="tablist"></div><div class="card rows" id="list"></div>`;
    const q = document.getElementById("q");
    function draw() {
      const term = normal(q.value);
      document.getElementById("tabs").hidden = !!term;
      document.getElementById("tabs").innerHTML = C.phrasebook.map((c) => `<button role="tab" aria-selected="${c.id === cat}" class="${c.id === cat ? "on" : ""}" data-cat="${c.id}">${esc(c.title)}</button>`).join("");
      const list = term ? C.phrasebook.flatMap((c) => c.phrases).filter((p) => normal(p.indo + " " + p.en).includes(term))
        : (C.phrasebook.find((c) => c.id === cat) || C.phrasebook[0]).phrases;
      document.getElementById("list").innerHTML = list.length ? list.map((p) => `<div class="phrase"><div><b>${words(p.indo)}</b><span>${esc(p.en)}</span>${p.note ? `<em>${esc(p.note)}</em>` : ""}</div>${sayButton(p.indo.replace(/…/g, ""))}${sayButton(p.indo.replace(/…/g, ""), true)}</div>`).join("")
        : `<p style="padding:16px 0;color:var(--ink-soft)">Nothing found. Try another word.</p>`;
    }
    document.getElementById("tabs").addEventListener("click", (e) => { const b = e.target.closest("[data-cat]"); if (b) { cat = b.dataset.cat; store.set("phraseCat", cat); draw(); } });
    q.addEventListener("input", draw);
    draw();
  }

  // ---------- patterns ----------
  function patternsPage() {
    document.title = "Patterns · Learn Bahasa";
    const entries = C.units.flatMap((u) => u.lessons.flatMap((l) => l.steps.filter((s) => s.kind === "learn").map((s) => ({ u, l, s }))));
    view.innerHTML = `<div class="hello"><img src="${faceFor("kak-dewi")}" alt=""><div><h1>Pola</h1><p>How Indonesian sentences fit together.</p></div></div>
      <div class="card chipline" style="margin-bottom:22px">${Object.keys(ROLE_LABEL).filter((r) => r !== "other").map((r) => `<span class="chip"><b style="color:${roleColor(r)};border-color:${roleColor(r)}33;background:${roleColor(r)}12;font-size:15px">${ROLE_LABEL[r]}</b></span>`).join("")}</div>
      <div class="stack">${entries.map(({ u, l, s }) => `<section class="sect"><p style="color:${accent(u.accent)};font-weight:800;font-size:13px">UNIT ${u.number} · ${esc(l.title).toUpperCase()}</p>
        <h2 style="margin-top:4px">${esc(s.title)}</h2><p style="color:var(--ink-soft);margin-bottom:10px">${esc(s.body)}</p>
        ${s.pattern ? `<div class="card chipline">${s.pattern.map((c) => `<span class="chip"><b style="color:${roleColor(c.role)};border-color:${roleColor(c.role)}33;background:${roleColor(c.role)}12">${esc(c.text)}</b><small style="color:${roleColor(c.role)}">${ROLE_LABEL[c.role]}</small></span>`).join("")}</div>` : ""}
        ${s.examples && s.examples.length ? `<div class="card examples" style="margin-top:10px">${s.examples.map((e) => `<div class="ex"><div><b>${words(e.indo)}</b><span>${esc(e.en)}</span></div>${sayButton(e.indo.replace(/ · .*/, ""))}</div>`).join("")}</div>` : ""}</section>`).join("")}
</div>`;
  }

  // ---------- boot ----------
  fetch("/data/content.json", { cache: "no-cache" })
    .then((r) => { if (!r.ok) throw new Error(r.status); return r.json(); })
    .then(async (data) => {
      C = data;
      try { const r = await fetch("/audio/index.json", { cache: "no-cache" }); if (r.ok) audioIndex = await r.json(); } catch { /* no recordings yet */ }
      window.addEventListener("hashchange", route); route();
      // After a sync brings in progress from the app, redraw the home page.
      window.addEventListener("lb:synced", () => { if (!location.hash || location.hash === "#/" ) homePage(); });
    })
    .catch(() => { view.innerHTML = `<p style="padding:40px 0">Couldn't load the lessons. Check your connection and refresh.</p>`; });
})();
