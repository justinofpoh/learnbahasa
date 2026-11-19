/* Optional sign-in (Apple or Google) and progress sync for the web app.
   Same Supabase table and document as the iPhone app (see supabase/schema.sql and SyncDocument.swift). */
(function () {
  "use strict";
  const cfg = window.LB_CONFIG || {};
  const enabled = !!(cfg.supabaseUrl && cfg.supabaseAnonKey && window.supabase);
  const read = (k, d) => { try { const v = localStorage.getItem("lb." + k); return v ? JSON.parse(v) : d; } catch { return d; } };
  const write = (k, v) => { try { localStorage.setItem("lb." + k, JSON.stringify(v)); } catch { /* private mode */ } };
  const esc = (s) => String(s ?? "").replace(/[&<>"']/g, (c) => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;" }[c]));

  let client = null, user = null, state = "idle", lastSync = null, timer = null, applying = false;

  function local() {
    return { progress: read("progress", { done: [], xp: 0, chats: [] }), profile: read("profile", { name: "", country: "", city: "" }) };
  }

  // Remote document + this browser -> merged (nothing is ever dropped).
  function merge(remote) {
    const { progress: p, profile: me } = local();
    const doc = Object.assign({ v: 1, lessons: [], xp: 0, chats: {} }, remote || {});
    const lessons = new Set([...(doc.lessons || []), ...p.done]);
    const chats = Object.assign({}, doc.chats || {});
    for (const id of p.chats) chats[id] = { stars: Math.max(1, (chats[id] && chats[id].stars) || 0), lived: !!(chats[id] && chats[id].lived) };
    const xp = Math.max(doc.xp || 0, p.xp || 0);
    const prof = Object.assign({}, doc.profile || {});
    if (me.name) prof.name = me.name; else if (prof.name) me.name = prof.name;
    if (me.country) prof.country = me.country; else if (prof.country) me.country = prof.country;
    const merged = Object.assign({}, doc, { v: 1, lessons: [...lessons].sort(), xp, chats, profile: prof });
    const newLocal = {
      progress: { ...p, done: [...lessons], xp, chats: Object.keys(chats).filter((id) => (chats[id].stars || 0) > 0 || chats[id].lived) },
      profile: me,
    };
    return { merged, newLocal };
  }

  async function sync() {
    if (!client || !user || state === "syncing") return;
    state = "syncing"; render();
    try {
      const { data: rows, error } = await client.from("progress").select("data").eq("user_id", user.id);
      if (error) throw error;
      const { merged, newLocal } = merge(rows && rows[0] && rows[0].data);
      applying = true;
      write("progress", newLocal.progress);
      write("profile", newLocal.profile);
      applying = false;
      const { error: upErr } = await client.from("progress").upsert({ user_id: user.id, data: merged, updated_at: new Date().toISOString() });
      if (upErr) throw upErr;
      state = "synced"; lastSync = new Date();
      window.dispatchEvent(new Event("lb:synced"));
    } catch (e) {
      applying = false;
      state = "failed";
      console.warn("Sync failed", e);
    }
    render();
  }

  function schedule() {
    if (!user || applying) return;
    clearTimeout(timer);
    timer = setTimeout(sync, 2500);
  }

  // Google's own "Sign in with Google" button: signs in on learnbahasa.app and hands the ID token to Supabase.
  let gisLoading = null, gisNonce = null;
  function loadGis() {
    if (window.google && window.google.accounts && window.google.accounts.id) return Promise.resolve();
    if (!gisLoading) {
      gisLoading = new Promise((resolve, reject) => {
        const s = document.createElement("script");
        s.src = "https://accounts.google.com/gsi/client";
        s.async = true; s.onload = resolve; s.onerror = reject;
        document.head.appendChild(s);
        setTimeout(() => reject(new Error("timeout")), 6000);
      });
    }
    return gisLoading;
  }
  async function sha256Hex(text) {
    const buf = await crypto.subtle.digest("SHA-256", new TextEncoder().encode(text));
    return [...new Uint8Array(buf)].map((b) => b.toString(16).padStart(2, "0")).join("");
  }
  async function mountGoogleButton(container, fallback) {
    if (!cfg.googleClientId) return;
    try {
      await loadGis();
      gisNonce = [...crypto.getRandomValues(new Uint8Array(24))].map((b) => b.toString(16).padStart(2, "0")).join("");
      const hashed = await sha256Hex(gisNonce);
      window.google.accounts.id.initialize({
        client_id: cfg.googleClientId,
        nonce: hashed,
        ux_mode: "popup",
        use_fedcm_for_button: true,
        callback: async (resp) => {
          const { error } = await client.auth.signInWithIdToken({ provider: "google", token: resp.credential, nonce: gisNonce });
          if (error) toast("Couldn't sign in with Google: " + error.message);
          else { menuOpen = false; render(); }
        },
      });
      if (!document.body.contains(container)) return;
      container.innerHTML = "";
      window.google.accounts.id.renderButton(container, {
        type: "standard", theme: "outline", size: "large", text: "continue_with", shape: "rectangular",
        logo_alignment: "center", width: Math.min(272, container.clientWidth || 272), locale: "en",
      });
      if (fallback) fallback.hidden = true;
    } catch {
      // Google's script blocked or offline: keep the plain button, which uses the Supabase redirect.
    }
  }

  async function signIn(provider) {
    if (!client) return;
    const { error } = await client.auth.signInWithOAuth({ provider, options: { redirectTo: location.origin + "/learn/" } });
    if (error) alertBox("Couldn't start sign-in: " + error.message);
  }

  async function signOut() {
    if (!client) return;
    await client.auth.signOut();
    user = null; state = "idle"; render();
  }

  async function deleteAccount(btn) {
    if (!btn.dataset.sure) { btn.dataset.sure = "1"; btn.textContent = "Tap again to delete for good"; return; }
    const { error } = await client.rpc("delete_my_account");
    if (error) { alertBox("Couldn't delete the account: " + error.message); return; }
    await signOut();
    toast("Your account and its saved progress are deleted. This browser keeps its own copy.");
  }

  let menuOpen = false;
  function toast(msg) {
    const t = document.createElement("div");
    t.className = "acct-toast"; t.setAttribute("role", "status"); t.textContent = msg;
    document.body.appendChild(t);
    setTimeout(() => t.remove(), 5000);
  }
  const alertBox = toast;

  function initial() {
    const meta = (user && user.user_metadata) || {};
    const name = meta.full_name || meta.name || (user && user.email) || "?";
    return name.trim().charAt(0).toUpperCase();
  }

  // Top-right of the header: "Sign in" (opens Apple / Google), or your initial with an account menu.
  function render() {
    const slot = document.getElementById("account-slot");
    if (!slot) return;
    if (!enabled) { slot.hidden = true; return; }
    slot.hidden = false;
    const provider = user ? ((user.app_metadata && user.app_metadata.provider) || "") : "";
    const note = state === "syncing" ? "Syncing…" : state === "failed" ? "Couldn't sync. Check your connection." : lastSync ? `Synced ${lastSync.toLocaleTimeString([], { hour: "numeric", minute: "2-digit" })}` : "Progress syncs automatically";
    slot.innerHTML = user
      ? `<button class="acct-btn me" aria-haspopup="true" aria-expanded="${menuOpen}" data-toggle>${esc(initial())}</button>`
      : `<button class="acct-btn" aria-haspopup="true" aria-expanded="${menuOpen}" data-toggle>Sign in</button>`;
    if (menuOpen) {
      slot.insertAdjacentHTML("beforeend", user
        ? `<div class="acct-menu" role="menu">
             <b>Signed in${provider ? " with " + (provider === "google" ? "Google" : provider === "apple" ? "Apple" : provider) : ""}</b>
             <small>${esc(user.email || "")}</small>
             <small class="acct-sync">${esc(note)}</small>
             <button role="menuitem" data-act="sync">Sync now</button>
             <button role="menuitem" data-act="out">Sign out</button>
             <button role="menuitem" class="danger" data-act="delete">Delete account</button>
           </div>`
        : `<div class="acct-menu" role="menu">
             <b>Save your progress</b>
             <small>Optional. Sync your lessons and chats with the iPhone app and any browser.</small>
             <button role="menuitem" class="auth apple" data-auth="apple"><span aria-hidden="true"></span> Continue with Apple</button>
             <div class="gis" id="gis-button"></div>
             <button role="menuitem" class="auth google" data-auth="google" id="google-fallback"><b aria-hidden="true">G</b> Continue with Google</button>
           </div>`);
    }
    slot.querySelector("[data-toggle]").onclick = (e) => { e.stopPropagation(); menuOpen = !menuOpen; render(); };
    slot.querySelectorAll("[data-auth]").forEach((b) => b.onclick = () => signIn(b.dataset.auth));
    slot.querySelectorAll("[data-act]").forEach((b) => b.onclick = (e) => {
      e.stopPropagation();
      if (b.dataset.act === "sync") sync();
      if (b.dataset.act === "out") { menuOpen = false; signOut(); }
      if (b.dataset.act === "delete") deleteAccount(b);
    });
    const menu = slot.querySelector(".acct-menu");
    if (menu) menu.onclick = (e) => e.stopPropagation();
    const gis = slot.querySelector("#gis-button");
    if (gis) mountGoogleButton(gis, slot.querySelector("#google-fallback"));
  }
  document.addEventListener("click", () => { if (menuOpen) { menuOpen = false; render(); } });
  document.addEventListener("keydown", (e) => { if (e.key === "Escape" && menuOpen) { menuOpen = false; render(); } });

  async function init() {
    if (!enabled) return;
    client = window.supabase.createClient(cfg.supabaseUrl, cfg.supabaseAnonKey, { auth: { flowType: "pkce", detectSessionInUrl: true, persistSession: true } });
    client.auth.onAuthStateChange((event, session) => {
      const was = user && user.id;
      user = session ? session.user : null;
      render();
      if (user && user.id !== was) sync();
    });
    const { data } = await client.auth.getSession();
    user = data.session ? data.session.user : null;
    render();
    if (user) sync();
  }

  window.LBAccount = { schedule, render, sync, get enabled() { return enabled; } };
  init();
})();
