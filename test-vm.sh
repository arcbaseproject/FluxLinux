#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ISO="${1:-$(find "$ROOT/out" -maxdepth 1 -name '*.iso' -print -quit 2>/dev/null || true)}"
[[ -n "$ISO" && -f "$ISO" ]] || { echo "Build the ISO first with sudo ./build.sh" >&2; exit 1; }
command -v qemu-system-x86_64 >/dev/null || { echo "Install QEMU: sudo pacman -S qemu-desktop edk2-ovmf" >&2; exit 1; }
DISK="$ROOT/.build/flux-test.qcow2"
mkdir -p "$ROOT/.build"
[[ -f "$DISK" ]] || qemu-img create -f qcow2 "$DISK" 40G

OVMF_CODE=""
for p in /usr/share/edk2/x64/OVMF_CODE.4m.fd /usr/share/edk2-ovmf/x64/OVMF_CODE.fd /usr/share/ovmf/x64/OVMF_CODE.fd; do
  [[ -f "$p" ]] && OVMF_CODE="$p" && break
done
[[ -n "$OVMF_CODE" ]] || { echo "OVMF firmware not found; install edk2-ovmf." >&2; exit 1; }

qemu-system-x86_64 \
  -enable-kvm \
  -machine q35 \
  -cpu host \
  -m 4096 \
  -smp 4 \
  -drive if=pflash,format=raw,readonly=on,file="$OVMF_CODE" \
  -drive file="$DISK",if=virtio,format=qcow2 \
  -cdrom "$ISO" \
  -boot d \
  -device virtio-vga-gl \
  -display gtk,gl=on
