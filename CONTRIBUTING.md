# Contributing to FluxLinux

Keep installation changes testable in a disposable UEFI VM first. Disk-layout changes should retain the explicit `ERASE` confirmation and must never silently guess a target disk.

Before opening a change:

```bash
bash -n build.sh
bash -n iso-overlay/usr/local/bin/flux-install-core
bash -n test-vm.sh
python -m py_compile iso-overlay/usr/local/bin/flux-install
python -m py_compile system-overlay/usr/local/bin/flux
```
