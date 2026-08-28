#!/usr/bin/env bash
set -euo pipefail

tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT
mkdir -p "$tmp_dir/bin"
cat > "$tmp_dir/bin/hyprctl" <<'SCRIPT'
#!/usr/bin/env bash
printf '%s\n' '[{"modmask":64,"key":"RETURN","mouse":false,"description":"Open terminal"}]'
SCRIPT
cat > "$tmp_dir/bin/fuzzel" <<'SCRIPT'
#!/usr/bin/env bash
printf '%s\n' "$*" > "$TEST_ARGS"
cat > "$TEST_INPUT"
SCRIPT
chmod +x "$tmp_dir/bin/"*

export TEST_ARGS="$tmp_dir/args"
export TEST_INPUT="$tmp_dir/input"
PATH="$tmp_dir/bin:$PATH" "$(dirname "$0")/system-overlay/usr/local/bin/flux-keybindings"
grep -q -- '--placeholder Keybindings… --width 70 --lines 9 --line-height 40' "$TEST_ARGS"
grep -q 'SUPER + RETURN.*→ Open terminal' "$TEST_INPUT"

echo "flux-keybindings checks passed"
