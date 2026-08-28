#!/usr/bin/env bash
set -euo pipefail

root="$(dirname "$0")"
ui="$root/iso-overlay/usr/local/bin/flux-install"
core="$root/iso-overlay/usr/local/bin/flux-install-core"

bash -n "$core"
python3 - "$ui" <<'PY'
import ast
import pathlib
import sys

source = pathlib.Path(sys.argv[1]).read_text()
ast.parse(source)
assert 'install_mode: str = "erase"' in source
assert '"--mode", s.install_mode' in source
assert 'Use unallocated space (dual boot)' in source
assert 'Does this look right?' in source
assert 'Remove the USB installer before rebooting.' in source
assert 'WORDMARK = [' in source
assert 'show_logo_image' not in source
PY

alongside=$(sed -n '/^else$/,/^fi$/p' "$core")
grep -q 'sgdisk -F' <<< "$alongside"
grep -q 'FLUX_EFI' <<< "$alongside"
grep -q 'FLUX_ROOT' <<< "$alongside"
! grep -q 'zap-all\|wipefs -af "$DISK"' <<< "$alongside"

echo "flux-installer checks passed"
