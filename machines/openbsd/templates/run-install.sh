#!/usr/bin/env bash
set -euo pipefail

# OpenBSD QEMU VM - Installation Runner (Interactive Mode)
# Serves install.conf via HTTP using Python, accessed via QEMU port forwarding

VM_DIR="{{VM_DIR}}"

# Start HTTP server in background
echo "==> Starting HTTP server for install.conf"
cd "${VM_DIR}"
python3 -m http.server 8888 >/dev/null 2>&1 &
HTTP_PID=$!
trap "kill ${HTTP_PID} 2>/dev/null" EXIT

echo "==> Starting OpenBSD installation"
echo "==> At the installer prompt:"
echo "    - Press 'I' to start installer"
echo "    - Press 'A' for autoinstall"
echo "    - When asked for location, enter: http://10.0.2.2:8888/install.conf"
echo "==> Press Ctrl-C when installation completes and VM reboots"
echo ""

exec qemu-system-x86_64 \
  -name "openbsd-install" \
  -machine q35,accel=tcg \
  -cpu max \
  -smp {{VM_CPUS}} \
  -m {{VM_RAM}} \
  -drive "if=virtio,file=${VM_DIR}/openbsd-{{OPENBSD_VERSION}}.qcow2,format=qcow2" \
  -cdrom "${VM_DIR}/install{{ISO_VERSION}}.iso" \
  -boot d \
  -netdev user,id=net0 \
  -device virtio-net-pci,netdev=net0 \
  -display cocoa
