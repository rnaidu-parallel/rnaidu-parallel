#!/bin/sh
# Refresh the profile heatmap from the merged multi-machine tokscale snapshots in the
# private usage-telemetry repo (this machine's snapshot is refreshed + peers pulled first),
# then push only if it changed. Scheduled daily via launchd (see the ai-usage-heatmap README
# for a cron equivalent).
set -e
cd "$(dirname "$0")/.."

tmp=$(mktemp)
trap 'rm -f "$tmp"' EXIT

TELEMETRY="${USAGE_TELEMETRY:-$HOME/usage-telemetry}"
"$TELEMETRY/push.sh"
node "$TELEMETRY/merge.mjs" > "$tmp"
npx --yes ai-usage-heatmap@latest render --input "$tmp" --out-dir assets

if git diff --quiet -- assets; then
  echo "heatmap unchanged; nothing to push"
  exit 0
fi

git add assets
git commit -m "Refresh AI usage heatmap"
git push
echo "heatmap refreshed and pushed"
