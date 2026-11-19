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
    alertBox("Your account and its saved progress are deleted. This browser keeps its own copy.");
  }

  function alertBox(msg) {
    const el = document.getElementById("account-card");
    if (el) el.insertAdjacentHTML("beforeend", `<p class="note" style="color:var(--sambal);margin-top:8px">${esc(msg)}</p>`);
  }

  function render() {
    const el = document.getElementById("account-card");
    if (!el || !enabled) { if (el) el.hidden = true; return; }
    el.hidden = false;
    if (!user) {
      el.innerHTML = `<h2>Save your progress</h2>
        <p class="note">Optional. Sign in to keep your lessons and chats in sync with the iPhone app and any browser.</p>
        <div class="card account">
          <button class="auth apple" data-auth="apple"><span aria-hidden="true"></span> Continue with Apple</button>
          <button class="auth google" data-auth="google"><b aria-hidden="true">G</b> Continue with Google</button>
        </div>`;
    } else {
      const note = state === "syncing" ? "Syncing…" : state === "failed" ? "Couldn't sync. Check your connection." : lastSync ? `Synced ${lastSync.toLocaleTimeString([], { hour: "numeric", minute: "2-digit" })}` : "Progress syncs automatically";
      const provider = (user.app_metadata && user.app_metadata.provider) || "";
      el.innerHTML = `<h2>Your account</h2>
        <div class="card account signed">
          <div><b>Signed in${provider ? " with " + (provider === "google" ? "Google" : provider === "apple" ? "Apple" : provider) : ""}</b><small>${esc(user.email || "")} · ${esc(note)}</small></div>
          <div class="account-actions"><button class="btn ghost small" data-act="sync">Sync now</button><button class="btn ghost small" data-act="out">Sign out</button><button class="btn ghost small" data-act="delete">Delete account</button></div>
        </div>`;
    }
    el.querySelectorAll("[data-auth]").forEach((b) => b.onclick = () => signIn(b.dataset.auth));
    el.querySelectorAll("[data-act]").forEach((b) => b.onclick = () => {
      if (b.dataset.act === "sync") sync();
      if (b.dataset.act === "out") signOut();
      if (b.dataset.act === "delete") deleteAccount(b);
    });
  }

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
