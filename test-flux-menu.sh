#!/usr/bin/env bash
set -euo pipefail

tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT
log="$tmp_dir/log"
mkdir -p "$tmp_dir/bin"

cat > "$tmp_dir/bin/fuzzel" <<'SCRIPT'
#!/usr/bin/env bash
printf 'fuzzel:%s\n' "$*" >> "$TEST_LOG"
if [[ -n "${TEST_CHOICE:-}" ]]; then
  printf '%s\n' "$TEST_CHOICE"
  exit
fi
case "$*" in
  *Go…*) printf ' Style\n' ;;
  *Style…*) printf '󰸌 Theme\n' ;;
  *System…*) printf ' Lock\n' ;;
esac
SCRIPT

for command in flux-theme-menu hyprlock gtk-launch; do
  cat > "$tmp_dir/bin/$command" <<SCRIPT
#!/usr/bin/env bash
printf '$command:%s\n' "\$*" >> "\$TEST_LOG"
SCRIPT
done
chmod +x "$tmp_dir/bin/"*

export TEST_LOG="$log"
export PATH="$tmp_dir/bin:$PATH"
export HOME="$tmp_dir/home"
mkdir -p "$HOME/.local/share/applications"
cat > "$HOME/.local/share/applications/test-app.desktop" <<'DESKTOP'
[Desktop Entry]
Type=Application
Name=Test App
Exec=true
DESKTOP
menu="$(dirname "$0")/system-overlay/usr/local/bin/flux-menu"

"$menu"
grep -Fxq 'flux-theme-menu:' "$log"

: > "$log"
"$menu" apps
grep -Fxq 'fuzzel:--prompt  --placeholder Apps…' "$log"

: > "$log"
TEST_CHOICE="Test App" "$menu"
grep -Fxq 'gtk-launch:test-app' "$log"

: > "$log"
"$menu" system
grep -Fxq 'hyprlock:' "$log"

if "$menu" missing 2>/dev/null; then
  echo "unknown route unexpectedly succeeded" >&2
  exit 1
fi

echo "flux-menu checks passed"
