#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="$ROOT/.build"
WORK="$BUILD_DIR/archiso"
PROFILE="$BUILD_DIR/profile"
OUT="$ROOT/out"
RELENG="/usr/share/archiso/configs/releng"

umask 022

if [[ ${EUID:-$(id -u)} -ne 0 ]]; then
  echo "Run this as root: sudo ./build.sh" >&2
  exit 1
fi

for cmd in mkarchiso rsync python3; do
  command -v "$cmd" >/dev/null 2>&1 || {
    echo "Missing $cmd. On Arch: sudo pacman -S --needed archiso rsync python" >&2
    exit 1
  }
done

[[ -d "$RELENG" ]] || { echo "Missing Archiso releng profile: $RELENG" >&2; exit 1; }
for path in iso-overlay system-overlay themes packages.target; do
  [[ -e "$ROOT/$path" ]] || { echo "Missing build input: $ROOT/$path" >&2; exit 1; }
done

# Keep the VM disk in .build/ across rebuilds; only Archiso's disposable
# profile and work tree are replaced.
rm -rf "$PROFILE" "$WORK"
mkdir -p "$WORK" "$OUT"
cp -a "$RELENG" "$PROFILE"

# FluxLinux packages required in the live installer environment.
cat >> "$PROFILE/packages.x86_64" <<'PKGS'
python
python-setuptools
btrfs-progs
dosfstools
gptfdisk
networkmanager
PKGS
sort -u -o "$PROFILE/packages.x86_64" "$PROFILE/packages.x86_64"

# Overlay our live ISO files and target-system payload.
rsync -a "$ROOT/iso-overlay/" "$PROFILE/airootfs/"
mkdir -p "$PROFILE/airootfs/usr/share/fluxlinux/system-overlay"
rsync -a "$ROOT/system-overlay/" "$PROFILE/airootfs/usr/share/fluxlinux/system-overlay/"
mkdir -p "$PROFILE/airootfs/usr/share/fluxlinux/themes"
rsync -a "$ROOT/themes/" "$PROFILE/airootfs/usr/share/fluxlinux/themes/"
cp "$ROOT/packages.target" "$PROFILE/airootfs/usr/share/fluxlinux/packages.target"

chmod 0755 "$PROFILE/airootfs/usr/local/bin/flux-install"
chmod 0755 "$PROFILE/airootfs/usr/local/bin/flux-install-core"
chmod 0755 "$PROFILE/airootfs/usr/share/fluxlinux/system-overlay/usr/local/bin/"*

# Ensure executable permissions survive archiso's airootfs build. Every
# script here ends up shipped both on the live ISO and (via flux-install-core's
# `cp -a`) on the installed system, so anything missing from this whitelist
# installs non-executable permanently.
python3 - "$PROFILE/profiledef.sh" "$ROOT/system-overlay/usr/local/bin" <<'PY'
from pathlib import Path
import sys
p = Path(sys.argv[1])
bin_dir = Path(sys.argv[2])
s = p.read_text()
needle = 'file_permissions=('
if needle not in s:
    raise SystemExit('Could not find file_permissions in profiledef.sh')
paths = ["/usr/local/bin/flux-install", "/usr/local/bin/flux-install-core"]
paths += sorted(f"/usr/local/bin/{f.name}" for f in bin_dir.iterdir() if f.is_file())
entries = "".join(f'  ["{path}"]="0:0:755"\n' for path in paths)
insert = f'file_permissions=(\n{entries}'
start = s.index(needle)
endline = s.index('\n', start)
# Replace only the opening line, preserving existing permissions underneath.
s = s[:start] + insert + s[endline+1:]
p.write_text(s)
PY

# Enable the TUI installer on tty1 in the live environment.
ln -sf /etc/systemd/system/flux-installer.service \
  "$PROFILE/airootfs/etc/systemd/system/multi-user.target.wants/flux-installer.service"

# Brand the live ISO label/name where the releng profile exposes them.
sed -i \
  -e 's/^iso_name=.*/iso_name="fluxlinux"/' \
  -e 's/^iso_label=.*/iso_label="FLUXLINUX_$(date +%Y%m)"/' \
  -e 's/^iso_publisher=.*/iso_publisher="FluxLinux <https:\/\/fluxlinux.xyz>"/' \
  -e 's/^iso_application=.*/iso_application="FluxLinux Live\/Install Media"/' \
  "$PROFILE/profiledef.sh"

# The releng profile's boot menus and greeting still say "Arch Linux" verbatim;
# rebrand every user-visible occurrence (BIOS/UEFI boot entries for both the
# plain ISO and the loopback/USB path, plus the netboot menu).
sed -i 's/Arch Linux/FluxLinux/g' \
  "$PROFILE/efiboot/loader/entries/01-archiso-linux.conf" \
  "$PROFILE/efiboot/loader/entries/02-archiso-speech-linux.conf" \
  "$PROFILE/grub/grub.cfg" \
  "$PROFILE/grub/loopback.cfg" \
  "$PROFILE/syslinux/archiso_head.cfg" \
  "$PROFILE/syslinux/archiso_sys-linux.cfg" \
  "$PROFILE/syslinux/archiso_pxe-linux.cfg"

# Replace the stock Arch wiki greeting with one that matches what actually
# happens on this ISO: flux-install already auto-launches on tty1.
cat > "$PROFILE/airootfs/etc/motd" <<'MOTD'
To install FluxLinux, run: sudo flux-install
https://fluxlinux.xyz/fluxlinux/docs

For Wi-Fi, authenticate to the wireless network using the iwctl utility.
For mobile broadband (WWAN) modems, connect with the mmcli utility.
Ethernet, WLAN and WWAN interfaces using DHCP should work automatically.
MOTD

mkarchiso -v -r -w "$WORK/work" -o "$OUT" "$PROFILE"

echo
echo "FluxLinux ISO built in: $OUT"
ls -lh "$OUT"/*.iso
