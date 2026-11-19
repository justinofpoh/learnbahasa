#!/bin/sh
# Exports the app's lessons, phrasebook, lexicon and Scenes to site/data/content.json.
set -e
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
APP="$ROOT/Bahasa"
OUT_BIN="${TMPDIR:-/tmp}/bahasa-content-export"
xcrun -sdk macosx swiftc -O -o "$OUT_BIN" \
  "$ROOT/tools/content-export/Stub.swift" \
  "$APP/Core/Models.swift" "$APP/Core/SceneModels.swift" "$APP/Core/Matcher.swift" \
  "$APP/Content/Curriculum.swift" "$APP/Content/Phrasebook.swift" "$APP/Content/Lexicon.swift" \
  "$APP"/Content/Unit*.swift "$APP"/Content/Scenes/*.swift \
  "$ROOT/tools/content-export/main.swift"
mkdir -p "$ROOT/site/data"
"$OUT_BIN" "$ROOT/site/data/content.json"
