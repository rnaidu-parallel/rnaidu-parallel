#!/bin/sh
# Refresh the profile heatmap from a fresh tokscale export, then push only if it changed.
# Scheduled daily via launchd (see the ai-usage-heatmap README for a cron equivalent).
set -e
cd "$(dirname "$0")/.."

tmp=$(mktemp)
trap 'rm -f "$tmp"' EXIT

npx --yes tokscale@latest graph > "$tmp"
npx --yes ai-usage-heatmap@latest render --input "$tmp" --out-dir assets

if git diff --quiet -- assets; then
  echo "heatmap unchanged; nothing to push"
  exit 0
fi

git add assets
git commit -m "Refresh AI usage heatmap"
git push
echo "heatmap refreshed and pushed"
