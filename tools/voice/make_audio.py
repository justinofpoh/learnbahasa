#!/usr/bin/env python3
"""Generates natural Indonesian audio for every line on the website. Run after
tools/content-export/export.sh.

Default engine: Supertonic-3 (open model, OpenRAIL-M: commercial use allowed, output is ours; the
site must say the voices are computer-generated). Runs on this Mac, no account or limits:

    <venv>/bin/python tools/voice/make_audio.py --engine supertonic [--force]

    (one-time setup: python3 -m venv <venv> && <venv>/bin/pip install supertonic)

Google engines (same voices as Google's products, but limited or paid):

    GEMINI_API_KEY=... python3 tools/voice/make_audio.py       # Gemini API free tier (no card): AI Studio key
    GOOGLE_TTS_API_KEY=... python3 tools/voice/make_audio.py   # Google Cloud Text-to-Speech (needs billing)
    python3 tools/voice/make_audio.py --dry-run                # list what would be made

The Gemini free tier allows few requests a day, so lines go in batches of about 25: one
recording per batch, cut at the pauses with ffmpeg. A batch whose pieces don't match its
lines is halved and tried again. When the day's quota runs out the script stops cleanly;
run it again later and it carries on.

Writes site/audio/<hash>.mp3 and site/audio/index.json ({"voice|text": "<hash>"}).
Existing files are kept, so re-runs only pay for new lines. The site falls back to the
browser's own voice for any line that has no file yet.
"""
import base64
import hashlib
import subprocess
import tempfile
import wave
import json
import os
import re
import sys
import time
import urllib.error
import urllib.request

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
CONTENT = os.path.join(ROOT, "site", "data", "content.json")
OUT = os.path.join(ROOT, "site", "audio")

# Who speaks with which voice. Names are Google Chirp 3 HD voices; change here and re-run.
VOICES = {
    "tutor": "id-ID-Chirp3-HD-Aoede",     # Kak Dewi: lessons, phrases, word lookups
    "learner": "id-ID-Chirp3-HD-Puck",    # your replies in chats
    "ibu-wayan": "id-ID-Chirp3-HD-Kore",
    "pak-agus": "id-ID-Chirp3-HD-Charon",
    "bu-ketut": "id-ID-Chirp3-HD-Leda",
    "bu-sari": "id-ID-Chirp3-HD-Despina",
    "putu": "id-ID-Chirp3-HD-Fenrir",
    "mbok-kadek": "id-ID-Chirp3-HD-Sulafat",
    "mbak-rina": "id-ID-Chirp3-HD-Zephyr",
    "bli-made": "id-ID-Chirp3-HD-Orus",
    "pak-nyoman": "id-ID-Chirp3-HD-Iapetus",
}

# Supertonic-3 preset voices (F1–F5, M1–M5) and speed per speaker.
ST_VOICES = {
    # Supertonic's natural pace is quick, so learners get it a little slower; the site's speed setting
    # and the 🐢 button slow it further on playback.
    "tutor": ("F2", 0.82), "learner": ("M1", 0.88),
    "ibu-wayan": ("F3", 0.88), "pak-agus": ("M3", 0.9), "bu-ketut": ("F4", 0.88), "bu-sari": ("F5", 0.88),
    "putu": ("M2", 0.92), "mbok-kadek": ("F1", 0.88), "mbak-rina": ("F4", 0.9), "bli-made": ("M4", 0.92),
    "pak-nyoman": ("M5", 0.85),
}

# Same list as COUNTRIES in site/learn/app.js (the Indonesian names).
COUNTRIES = ["Australia", "Kanada", "Amerika", "Inggris", "Jerman", "Belanda", "Prancis", "Selandia Baru",
             "Singapura", "Rusia", "Jepang", "India", "Italia", "Spanyol", "Brasil"]


def key(role, text):
    return f"{role}|{text}"


def file_id(role, text):
    return hashlib.sha1(key(role, text).encode("utf-8")).hexdigest()[:16]


def expand(text, fallbacks):
    """Lines with {country} are made for every country the site offers; other slots use fallbacks."""
    out = [text]
    if "{country}" in text:
        out = [t.replace("{country}", c) for t in out for c in COUNTRIES]
    for slot, value in fallbacks.items():
        out = [t.replace("{" + slot + "}", value) for t in out]
    out = [t.replace("{job}", "").strip() for t in out]
    return [t for t in out if t and "{" not in t]


def collect(content):
    lines = set()
    fb = content.get("fallbacks", {})

    def add(role, text):
        text = re.sub(r"\s+", " ", text.replace("…", "")).strip()
        if text:
            for t in expand(text, fb):
                lines.add((role, t))

    for unit in content["units"]:
        for lesson in unit["lessons"]:
            for s in lesson["steps"]:
                for e in s.get("examples") or []:
                    add("tutor", re.sub(r" · .*", "", e["indo"]))
                if s.get("say"):
                    add("tutor", s["say"])
                if s["kind"] == "arrange":
                    add("tutor", s["answer"])
                    for w in (s["answer"] + " " + " ".join(s.get("extras") or [])).split():
                        add("tutor", w.strip(",.?!"))
    for cat in content["phrasebook"]:
        for p in cat["phrases"]:
            add("tutor", p["indo"])
    for word in content["lexicon"]:
        add("tutor", word)
    add("tutor", "Bagus sekali!")
    for scene in content["scenes"]:
        who = scene["character"]
        for n in scene["nodes"]:
            add(who, n["them"]["text"])
            for r in n["replies"]:
                add("learner", r["text"])
                if r.get("reaction"):
                    add(who, r["reaction"]["text"])
    return sorted(lines)


def synthesize(api_key, role, text):
    voice = VOICES.get(role, VOICES["tutor"])
    body = json.dumps({
        "input": {"text": text},
        "voice": {"languageCode": "id-ID", "name": voice},
        "audioConfig": {"audioEncoding": "MP3"},
    }).encode()
    req = urllib.request.Request(
        "https://texttospeech.googleapis.com/v1/text:synthesize",
        data=body, headers={"Content-Type": "application/json", "X-Goog-Api-Key": api_key})
    with urllib.request.urlopen(req, timeout=60) as r:
        return base64.b64decode(json.load(r)["audioContent"])


# ---------- Gemini (AI Studio free tier) ----------

GEMINI_MODEL = os.environ.get("GEMINI_TTS_MODEL", "gemini-3.8-flash-tts")
# The free tier counts requests per model per day (10 each), so each speaker keeps to one model
# and the speakers are spread across the TTS models the key can use. Same voices on every model.
# Tried in this order; when one model's daily requests run out, the next one takes over.
MODEL_ORDER = ["gemini-2.5-flash-preview-tts", "gemini-2.5-pro-preview-tts", "gemini-3.8-flash-tts",
               "gemini-3.1-flash-tts-preview", "gemini-3.8-flash-lite-tts"]
CHECK_MODEL = os.environ.get("GEMINI_CHECK_MODEL", "gemini-flash-lite-latest")
BATCH = int(os.environ.get("TTS_BATCH", "50"))


class QuotaDone(Exception):
    pass


def gemini_request(api_key, model, voice, prompt):
    body = json.dumps({
        "contents": [{"parts": [{"text": prompt}]}],
        "generationConfig": {
            "responseModalities": ["AUDIO"],
            "speechConfig": {"voiceConfig": {"prebuiltVoiceConfig": {"voiceName": voice}}},
        },
    }).encode()
    req = urllib.request.Request(
        f"https://generativelanguage.googleapis.com/v1beta/models/{model}:generateContent",
        data=body, headers={"Content-Type": "application/json", "x-goog-api-key": api_key})
    with urllib.request.urlopen(req, timeout=300) as r:
        data = json.load(r)
    part = data["candidates"][0]["content"]["parts"][0]["inlineData"]
    return base64.b64decode(part["data"])  # 16-bit mono PCM, 24 kHz


def pick_gemini_model(api_key):
    """Uses GEMINI_TTS_MODEL if it exists, otherwise the newest model with "tts" in its name."""
    req = urllib.request.Request("https://generativelanguage.googleapis.com/v1beta/models?pageSize=200",
                                 headers={"x-goog-api-key": api_key})
    with urllib.request.urlopen(req, timeout=60) as r:
        names = [m["name"].split("/")[-1] for m in json.load(r).get("models", [])]
    if GEMINI_MODEL in names:
        return GEMINI_MODEL
    tts = sorted([n for n in names if "tts" in n and "pro" not in n], reverse=True)
    if not tts:
        sys.exit("No text-to-speech model is available to this Gemini API key.")
    return tts[0]


def prompt_for(lines):
    # The TTS models read instructions aloud, so the prompt is only the lines, joined by a pause tag:
    # it gives 3–4 s of silence between lines, while pauses inside a line stay under half a second.
    return " [long pause] ".join(lines)


def norm(text):
    text = text.lower().replace("-", " ")
    return re.sub(r"\s+", " ", re.sub(r"[^a-z0-9 ]", "", text)).strip()


def check_pieces(api_key, paths, expected):
    """Transcribes the pieces and returns the indexes that don't match their line (None if the check failed)."""
    import difflib
    parts = [{"text": "For each numbered audio clip, write exactly what is spoken, word for word, keeping casual forms "
                      "(aja stays aja, saja stays saja). Write numbers as words. Reply as a JSON object mapping the "
                      "clip number to its transcript, with one entry for every clip."}]
    for i, path in enumerate(paths, 1):
        parts += [{"text": f"Clip {i}:"},
                  {"inlineData": {"mimeType": "audio/mpeg", "data": base64.b64encode(open(path, "rb").read()).decode()}}]
    body = json.dumps({"contents": [{"parts": parts}], "generationConfig": {"responseMimeType": "application/json"}}).encode()
    req = urllib.request.Request(f"https://generativelanguage.googleapis.com/v1beta/models/{CHECK_MODEL}:generateContent",
                                 data=body, headers={"Content-Type": "application/json", "x-goog-api-key": api_key})
    try:
        with urllib.request.urlopen(req, timeout=300) as r:
            heard = json.loads(json.load(r)["candidates"][0]["content"]["parts"][0]["text"])
    except Exception as e:  # the check is a safety net; a failed check doesn't block the audio
        print(f"    (check skipped: {str(e)[:80]})")
        return None
    bad = []
    for i, line in enumerate(expected, 1):
        got = norm(str(heard.get(str(i), "")))
        if difflib.SequenceMatcher(None, norm(line), got).ratio() < 0.8:
            bad.append(i - 1)
            print(f"    expected: {line!r}\n    heard:    {heard.get(str(i), '')!r}")
    return bad


def segments(pcm, rate=24000):
    """Splits a recording at silences of 1.5 s or more. Returns (start, end) times in seconds."""
    with tempfile.NamedTemporaryFile(suffix=".wav", delete=False) as f:
        path = f.name
    with wave.open(path, "wb") as w:
        w.setnchannels(1); w.setsampwidth(2); w.setframerate(rate); w.writeframes(pcm)
    duration = len(pcm) / 2 / rate
    log = subprocess.run(["ffmpeg", "-hide_banner", "-i", path, "-af", "silencedetect=noise=-40dB:d=1.5", "-f", "null", "-"],
                         capture_output=True, text=True).stderr
    starts = [float(x) for x in re.findall(r"silence_start: ([\d.]+)", log)]
    ends = [float(x) for x in re.findall(r"silence_end: ([\d.]+)", log)]
    cuts, t = [], 0.0
    for s_, e_ in zip(starts, ends + [duration] * (len(starts) - len(ends))):
        if s_ - t > 0.18:
            cuts.append((t, s_))
        t = e_
    if duration - t > 0.18:
        cuts.append((t, duration))
    return path, cuts


def save_piece(wav, start, end, dest):
    subprocess.run(["ffmpeg", "-hide_banner", "-loglevel", "error", "-y", "-ss", f"{max(0, start - 0.06):.3f}",
                    "-to", f"{end + 0.12:.3f}", "-i", wav, "-ac", "1", "-codec:a", "libmp3lame", "-q:a", "4", dest],
                   check=True)


def available_models(api_key):
    req = urllib.request.Request("https://generativelanguage.googleapis.com/v1beta/models?pageSize=200",
                                 headers={"x-goog-api-key": api_key})
    with urllib.request.urlopen(req, timeout=60) as r:
        return {m["name"].split("/")[-1] for m in json.load(r).get("models", [])}


def next_model(models, spent):
    for m in MODEL_ORDER + sorted(n for n in models if "tts" in n):
        if m in models and m not in spent:
            return m
    return None


def pick_from(models):
    if GEMINI_MODEL in models:
        return GEMINI_MODEL
    tts = sorted([n for n in models if "tts" in n], reverse=True)
    if not tts:
        sys.exit("No text-to-speech model is available to this Gemini API key.")
    return tts[0]


def run_gemini(api_key, todo):
    models = available_models(api_key)
    by_role = {}
    for role, text in todo:
        by_role.setdefault(role, []).append(text)
    queue = []
    for role, texts in by_role.items():
        for i in range(0, len(texts), BATCH):
            queue.append((role, texts[i:i + BATCH]))
    spent = set()  # models whose free requests for today are used up
    made = requests = 0
    while queue:
        role, batch = queue.pop(0)
        model = next_model(models, spent)
        if model is None:
            break
        voice = VOICES.get(role, VOICES["tutor"]).split("-")[-1]
        try:
            pcm = gemini_request(api_key, model, voice, prompt_for(batch))
            requests += 1
        except urllib.error.HTTPError as e:
            msg = e.read().decode(errors="replace")
            if e.code == 429:
                if "PerDay" in msg or "per day" in msg.lower():
                    spent.add(model)
                    print(f"  {model}: today's free requests are used up, moving on")
                    queue.insert(0, (role, batch))
                    continue
                wait = int((re.search(r'"retryDelay":\s*"(\d+)s"', msg) or [None, "30"])[1]) + 2
                print(f"  rate limited, waiting {wait}s")
                time.sleep(min(wait, 120))
                queue.insert(0, (role, batch))
                continue
            if e.code in (500, 503):
                time.sleep(10); queue.insert(0, (role, batch)); continue
            sys.exit(f"Gemini error {e.code}: {msg[:400]}")
        wav, cuts = segments(pcm)
        if len(cuts) == len(batch):
            paths = [os.path.join(OUT, file_id(role, text) + ".mp3") for text in batch]
            for path, (a, b) in zip(paths, cuts):
                save_piece(wav, a, b, path)
            bad = check_pieces(api_key, paths, batch) if len(batch) > 1 else []
            if bad:
                for i in bad:
                    os.unlink(paths[i])
                queue.append((role, [batch[i] for i in bad]))
                print(f"  {role:11} {len(bad)} line(s) didn't match, re-recording them together later")
            made += len(batch) - len(bad or [])
            print(f"  {role:11} +{len(batch) - len(bad or [])} lines via {model} (total {made}, {len(queue)} batches left)")
        elif len(batch) > 1:
            half = len(batch) // 2
            print(f"  {role:11} got {len(cuts)} pieces for {len(batch)} lines, splitting the batch")
            queue[:0] = [(role, batch[:half]), (role, batch[half:])]
        else:
            # One line: keep the whole recording, trimmed to its sound.
            a, b = (cuts[0][0], cuts[-1][1]) if cuts else (0, len(pcm) / 48000)
            save_piece(wav, a, b, os.path.join(OUT, file_id(role, batch[0]) + ".mp3"))
            made += 1
        os.unlink(wav)
        time.sleep(float(os.environ.get("TTS_SPACING", "6")))
    left = len(todo) - made
    print(f"Done for now: {made} lines in {requests} requests." + (f" {left} lines left: run again after the daily reset (midnight Pacific)." if left > 0 else " All lines have audio."))


def run_supertonic(todo):
    from supertonic import TTS
    tts = TTS(auto_download=True)
    styles = {}
    for i, (role, text) in enumerate(todo, 1):
        name, speed = ST_VOICES.get(role, ST_VOICES["tutor"])
        if name not in styles:
            styles[name] = tts.get_voice_style(voice_name=name)
        wav, _ = tts.synthesize(text, voice_style=styles[name], lang="id", speed=speed, total_steps=10)
        with tempfile.NamedTemporaryFile(suffix=".wav", delete=False) as f:
            tmp = f.name
        tts.save_audio(wav, tmp)
        # Trim the synthesiser's lead-in and tail silence, then encode.
        subprocess.run(["ffmpeg", "-hide_banner", "-loglevel", "error", "-y", "-i", tmp, "-af",
                        "silenceremove=start_periods=1:start_threshold=-45dB,areverse,silenceremove=start_periods=1:start_threshold=-45dB,areverse,apad=pad_dur=0.08",
                        "-ac", "1", "-codec:a", "libmp3lame", "-q:a", "4",
                        os.path.join(OUT, file_id(role, text) + ".mp3")], check=True)
        os.unlink(tmp)
        if i % 50 == 0 or i == len(todo):
            print(f"  {i}/{len(todo)}", flush=True)


def main():
    dry = "--dry-run" in sys.argv
    force = "--force" in sys.argv
    engine = sys.argv[sys.argv.index("--engine") + 1] if "--engine" in sys.argv else None
    content = json.load(open(CONTENT))
    lines = collect(content)
    os.makedirs(OUT, exist_ok=True)
    todo = [(r, t) for r, t in lines if force or not os.path.exists(os.path.join(OUT, file_id(r, t) + ".mp3"))]
    chars = sum(len(t) for _, t in todo)
    print(f"{len(lines)} lines, {len(todo)} missing ({chars} characters)")
    if dry:
        for r, t in todo[:20]:
            print(f"  {r:11} {t}")
        return write_index(lines)
    if engine == "supertonic" or (engine is None and not os.environ.get("GEMINI_API_KEY") and not os.environ.get("GOOGLE_TTS_API_KEY")):
        run_supertonic(todo)
        return write_index(lines)
    gemini_key = os.environ.get("GEMINI_API_KEY")
    if gemini_key:
        try:
            run_gemini(gemini_key, todo)
        except KeyboardInterrupt:
            print("Stopped.")
        return write_index(lines)
    api_key = os.environ.get("GOOGLE_TTS_API_KEY")
    if not api_key:
        sys.exit("Set GEMINI_API_KEY (free, from aistudio.google.com/apikey) or GOOGLE_TTS_API_KEY (Google Cloud).")
    for i, (role, text) in enumerate(todo, 1):
        for attempt in range(3):
            try:
                audio = synthesize(api_key, role, text)
                open(os.path.join(OUT, file_id(role, text) + ".mp3"), "wb").write(audio)
                break
            except urllib.error.HTTPError as e:
                msg = e.read().decode(errors="replace")[:300]
                if e.code in (429, 500, 503) and attempt < 2:
                    time.sleep(2 + attempt * 3)
                    continue
                sys.exit(f"Google TTS error {e.code} on {text!r}: {msg}")
        if i % 25 == 0 or i == len(todo):
            print(f"  {i}/{len(todo)}")
    write_index(lines)


def write_index(lines):
    index = {key(r, t): file_id(r, t) for r, t in lines if os.path.exists(os.path.join(OUT, file_id(r, t) + ".mp3"))}
    json.dump(index, open(os.path.join(OUT, "index.json"), "w"), ensure_ascii=False, sort_keys=True)
    print(f"index.json: {len(index)} lines with audio")


if __name__ == "__main__":
    main()
