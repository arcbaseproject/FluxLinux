# FluxLinux

FluxLinux is an Arch-based, Hyprland-first Linux distribution project built around an opinionated system + installer + configs approach.

This repository produces a **bootable x86_64 UEFI ISO** with a custom curses TUI installer. The installer can wipe a selected disk, partition it, install an Arch base system, apply FluxLinux defaults, configure a user, install systemd-boot, and boot into a Hyprland desktop through SDDM.

> **Important:** This is a real disk installer. Test it in a virtual machine or on a spare disk first. Clean installs require typing `ERASE`; dual-boot installs require typing `INSTALL` after a preservation warning.

## Current feature set

- Archiso-based live ISO
- Custom FluxLinux curses TUI installer
- UEFI + GPT installation
- Btrfs (`@`, `@home`, `@var_log`) or ext4
- systemd-boot
- Intel/AMD microcode auto-detection
- NetworkManager + Bluetooth
- PipeWire audio
- Hyprland + Waybar + Mako + Fuzzel + Kitty
- Firefox + Thunar
- FluxLinux default configs and branding
- Switchable color themes (amber, black, mint)
- Clean install or dual boot into existing unallocated GPT space
- `flux`, `flux-update`, and `flux-doctor` commands
- QEMU/OVMF test helper

## Build on Arch

```bash
sudo pacman -S --needed archiso rsync python git
cd FluxLinux
sudo ./build.sh
```

The ISO will appear in `out/`.

## Test safely in a VM

```bash
sudo pacman -S --needed qemu-desktop edk2-ovmf
./test-vm.sh
```

The VM helper creates a 40 GiB qcow2 disk under `.build/`. Inside the live ISO, the FluxLinux installer opens automatically on tty1.

## Installer flow

1. Pick the target disk.
2. Choose a clean install or dual boot using existing unallocated space.
3. Set hostname, username, timezone, filesystem, encryption, and bootloader.
4. Select **Install FluxLinux**.
5. Confirm the mode-specific data warning.
6. Enter the user's password twice.
7. Let the installer partition, bootstrap, configure and install the boot loader.
8. Reboot and remove the ISO.

## Repository layout

```text
FluxLinux/
├── build.sh                 # creates the archiso profile and ISO
├── packages.target          # packages installed to the final OS
├── iso-overlay/             # files only used by the live ISO
│   ├── etc/systemd/system/flux-installer.service
│   └── usr/local/bin/
│       ├── flux-install     # curses TUI
│       └── flux-install-core# disk/system installer
├── system-overlay/          # files copied into the installed OS
│   ├── etc/os-release
│   ├── etc/skel/.config/...
│   └── usr/local/bin/...
├── themes/                  # amber, black, mint color themes
├── docs/
├── test-vm.sh
└── test-flux-*.sh           # component test scripts
```

## Deliberate v0.1 limitations

- x86_64 only
- UEFI only
- dual boot requires at least 17 GiB of existing unallocated GPT space; no partition resize UI yet
- no Secure Boot setup yet
- no NVIDIA-specific setup UI yet
- no custom package repository yet
- no graphical installer yet (the TUI is the intended installer)

Those limitations keep the first release understandable and testable.

## Development order

A sensible path toward a polished distribution is:

1. Make `./test-vm.sh` install and reboot successfully every time.
2. Add installer logging and recovery.
3. Add hardware detection (NVIDIA, laptops, VM guests).
4. Add theme/profile switching.
5. Add a signed FluxLinux package repository.
6. Add an updater that can migrate FluxLinux config versions.
7. Add CI that builds and boots the ISO automatically.
8. Only then add dual-boot/manual partitioning.

## License

MIT. See `LICENSE`.
