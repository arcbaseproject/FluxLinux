#!/usr/bin/env bash
# Self-check for flux-update's clone-vs-pull branch. Stubs sudo/git/rsync/
# pacman/systemctl on PATH and asserts the right git subcommand runs
# depending on whether REPO_DIR/.git already exists.
set -euo pipefail
HERE="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

STUBS="$WORK/stubs"
mkdir -p "$STUBS" "$WORK/repo"
LOG="$WORK/log"

cat > "$STUBS/sudo" <<'EOF'
#!/usr/bin/env bash
exec "$@"
EOF
cat > "$STUBS/pacman" <<'EOF'
#!/usr/bin/env bash
exit 0
EOF
cat > "$STUBS/systemctl" <<'EOF'
#!/usr/bin/env bash
exit 0
EOF
cat > "$STUBS/rsync" <<'EOF'
#!/usr/bin/env bash
exit 0
EOF
cat > "$STUBS/git" <<EOF
#!/usr/bin/env bash
echo "git \$*" >> "$LOG"
if [[ "\$1" == "clone" ]]; then mkdir -p "\${@: -1}/.git"; fi
exit 0
EOF
chmod +x "$STUBS"/*

assert_branch() {
  local desc="$1" want="$2"
  : > "$LOG"
  PATH="$STUBS:$PATH" REPO_DIR="$WORK/repo" REPO_URL="https://example.invalid/x.git" \
    bash "$HERE/flux-update" >/dev/null
  grep -q "$want" "$LOG" || { echo "FAIL: $desc (log: $(cat "$LOG"))"; exit 1; }
  echo "OK: $desc"
}

assert_branch "clones when no .git dir present" "git clone"
assert_branch "pulls when .git dir already present" "git -C $WORK/repo pull"
