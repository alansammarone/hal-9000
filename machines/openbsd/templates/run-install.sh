#!/usr/bin/env bash
set -euo pipefail

# OpenBSD QEMU VM - Installation Runner (Interactive Mode)
# This script runs the initial installation with serial console on stdio

VM_DIR="{{VM_DIR}}"

echo "==> Starting OpenBSD installation"
echo "==> Press 'I' at the welcome screen to trigger autoinstall"
echo "==> Or answer the installation questions manually (see install.conf for reference)"
echo "==> Press Ctrl-C when installation completes and VM reboots"
echo ""

exec qemu-system-x86_64 \
  -name "openbsd-install" \
  -machine q35,accel=tcg \
  -cpu max \
  -smp {{VM_CPUS}} \
  -m {{VM_RAM}} \
  -drive "if=virtio,file=${VM_DIR}/openbsd-{{OPENBSD_VERSION}}.qcow2,format=qcow2" \
  -drive "if=virtio,file=${VM_DIR}/install{{ISO_VERSION}}.iso,format=raw,media=cdrom,readonly=on" \
  -netdev user,id=net0 \
  -device virtio-net-pci,netdev=net0 \
  -display none \
  -serial stdio
