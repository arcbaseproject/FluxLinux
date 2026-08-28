#!/usr/bin/env bash
set -euo pipefail

tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT

PYTHONPYCACHEPREFIX="$tmp_dir/pycache" python3 -m py_compile "$(dirname "$0")/system-overlay/usr/local/bin/flux-calendar-popup"
jq -e '.clock["on-click"] == "flux-calendar-popup"' \
  "$(dirname "$0")/system-overlay/etc/skel/.config/waybar/config.jsonc" >/dev/null

echo "flux-calendar checks passed"
