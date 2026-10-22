#!/usr/bin/env bash
# Export one game to HTML5 and publish it to its own GitHub repo + Pages.
# Usage: bash tools/deploy_web.sh "<export preset>" <game folder> <GitHub repo name> "<description>"
# e.g.   bash tools/deploy_web.sh "Web - Juara Kuiz Sekolah" juara_kuiz Juara-Kuiz-Sekolah "KSSR quiz game"
set -euo pipefail
PRESET="$1"; GAME="$2"; REPO="$3"; DESC="$4"
OWNER="Altrabird"
G="${GODOT:-/c/Users/HARSIDI BIN JUNICK/Desktop/Godot_v4.7.2-stable_win64.exe/Godot_v4.7.2-stable_win64_console.exe}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT="$ROOT/build/web/$GAME"
DEPLOY="$ROOT/build/deploy/$REPO"

rm -rf "$OUT" && mkdir -p "$OUT"
"$G" --headless --path "$ROOT" --export-release "$PRESET" "$OUT/index.html" > "$ROOT/build/export_$GAME.log" 2>&1
python "$ROOT/tools/web_smoke.py" "$OUT" "$ROOT/build/smoke_$GAME.png" 12 | grep -v "GET /"

mkdir -p "$DEPLOY"
cd "$DEPLOY"
[ -d .git ] || { git init -q -b main; git config core.autocrlf false; }
find . -mindepth 1 -maxdepth 1 ! -name .git -exec rm -rf {} +
cp -r "$OUT"/. .
cp "$ROOT/games/$GAME/README.md" README.md
touch .nojekyll
git add -A
git commit -qm "Web build $(date +%Y-%m-%d)

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>" || echo "no changes"
if ! gh repo view "$OWNER/$REPO" >/dev/null 2>&1; then
  gh repo create "$OWNER/$REPO" --public --description "$DESC" --homepage "https://${OWNER,,}.github.io/$REPO/" --source . --push
  gh api -X POST "repos/$OWNER/$REPO/pages" -f "source[branch]=main" -f "source[path]=/" >/dev/null
else
  git remote get-url origin >/dev/null 2>&1 || git remote add origin "https://github.com/$OWNER/$REPO.git"
  git push -q -u origin main
fi
echo "repo:  https://github.com/$OWNER/$REPO"
echo "play:  https://${OWNER,,}.github.io/$REPO/"
