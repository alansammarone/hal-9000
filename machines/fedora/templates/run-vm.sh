#!/usr/bin/env bash
set -euo pipefail

# QEMU x86_64 VM launcher. Edit machine/accel/cpu/smp/m for your needs.
# tcg = slow but portable (only option for x86_64 on Apple Silicon)
# hvf = ARM64 guests only (not x86_64)
# kvm = Linux x86 only (requires CPU support)

VM_DIR="{{VM_DIR}}"

qemu-system-x86_64 \
  -name podman-builder \
  -machine {{VM_MACHINE}},accel={{VM_ACCEL}} \
  -cpu max \
  -smp {{VM_CPUS}} \
  -m {{VM_RAM}} \
  -drive if=virtio,file="${VM_DIR}/fedora-cloud-{{FEDORA_VERSION}}.qcow2",format=qcow2 \
  -drive if=virtio,file="${VM_DIR}/seed.iso",format=raw,media=cdrom,readonly=on \
  -netdev user,id=net0,hostfwd=tcp:127.0.0.1:{{SSH_PORT}}-:22 \
  -device virtio-net-pci,netdev=net0 \
  -display none \
  -daemonize \
  -pidfile "${VM_DIR}/qemu.pid" \
  -serial file:"${VM_DIR}/vm-console.log"
