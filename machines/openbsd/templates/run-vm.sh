#!/usr/bin/env bash
set -euo pipefail

# OpenBSD QEMU VM - Production Runner (Daemon Mode)
# All parameters are explicit and documented for easy customization

VM_DIR="{{VM_DIR}}"
VM_NAME="openbsd-qemu"

# Machine type: q35 (modern PCIe chipset, recommended)
# Alternative: pc (legacy i440fx PCI chipset)
MACHINE_TYPE="q35"

# Accelerator: tcg (software emulation, portable, works on Apple Silicon)
# Alternative: kvm (Linux only, requires KVM kernel module, much faster)
# Alternative: hvf (macOS Hypervisor.framework, ARM64 guests only, NOT x86)
ACCELERATOR="tcg"

# CPU model: max (expose all features supported by accelerator)
# Alternative: host (KVM/HVF only, pass through host CPU)
# Alternative: qemu64, Broadwell, Haswell, etc. (specific CPU models)
CPU_MODEL="max"

# SMP: Number of CPU cores
SMP_CORES={{VM_CPUS}}

# Memory: RAM in MB
MEMORY_MB={{VM_RAM}}

# Disk interface: virtio (paravirtualized, best performance)
# Alternative: ide (legacy, slower, appears as wd0 in OpenBSD)
# Alternative: scsi with virtio-scsi-pci (more flexible than virtio-blk)
DISK_INTERFACE="virtio"
DISK_FILE="${VM_DIR}/openbsd-{{OPENBSD_VERSION}}.qcow2"
DISK_FORMAT="qcow2"

# Network device: virtio-net-pci (paravirtualized, fast, OpenBSD vio(4) driver)
# Alternative: e1000 (Intel emulation, slower but more compatible)
# Alternative: rtl8139 (Realtek emulation, legacy)
NETWORK_DEVICE="virtio-net-pci"
SSH_PORT={{SSH_PORT}}

# Serial console: log to file (for daemon mode)
# Alternative: stdio (for interactive console, combine with removing -daemonize)
SERIAL_MODE="file:${VM_DIR}/vm-console.log"

# Display: none (headless server VM)
# Alternative: vnc=:0 (VNC server on port 5900 for graphical console)
# Alternative: gtk or sdl (local graphical window, requires X11/Wayland)
DISPLAY_MODE="none"

# Execute QEMU with explicit parameters
exec qemu-system-x86_64 \
  -name "${VM_NAME}" \
  -machine "${MACHINE_TYPE},accel=${ACCELERATOR}" \
  -cpu "${CPU_MODEL}" \
  -smp "${SMP_CORES}" \
  -m "${MEMORY_MB}" \
  -drive "if=${DISK_INTERFACE},file=${DISK_FILE},format=${DISK_FORMAT}" \
  -netdev "user,id=net0,hostfwd=tcp:127.0.0.1:${SSH_PORT}-:22" \
  -device "${NETWORK_DEVICE},netdev=net0" \
  -display "${DISPLAY_MODE}" \
  -serial "${SERIAL_MODE}" \
  -daemonize \
  -pidfile "${VM_DIR}/qemu.pid"
