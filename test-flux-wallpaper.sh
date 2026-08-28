#!/usr/bin/env bash
set -euo pipefail

tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT

popup=system-overlay/usr/local/bin/flux-background-menu
PYTHONPYCACHEPREFIX="$tmp_dir/pycache" python3 -m py_compile "$popup"
python3 "$popup" --self-check
grep -Fq '"hyprctl", "hyprpaper", "wallpaper"' "$popup"

bash -n system-overlay/usr/local/bin/flux-theme-set
grep -Fq 'hyprctl hyprpaper wallpaper ",$RENDER_DIR/wallpaper.png,cover"' system-overlay/usr/local/bin/flux-theme-set
! rg -q 'hyprctl hyprpaper reload' system-overlay/usr/local/bin test-flux-wallpaper.sh

echo "flux-wallpaper checks passed"
