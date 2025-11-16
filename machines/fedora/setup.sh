#!/usr/bin/env bash
set -euox pipefail

# Config
FEDORA_VERSION=42
VM_DIR="${HOME}/Code/VMs/podman-builder"
SSH_PORT=2222

# VM resources
VM_RAM=8192        # MB
VM_CPUS=4          # cores
VM_MACHINE=q35     # chipset (q35 = PCIe, i440fx = legacy ISA)
VM_ACCEL=tcg       # tcg = slow/portable, hvf = macOS, kvm = Linux x86

# Get script directory before changing working directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Validation
[ -x "$(command -v qemu-system-x86_64)" ] || { echo "Error: qemu not found in PATH"; exit 1; }

SSH_KEY_PATH="${HOME}/.ssh/personal/qemu_fedora_builder.pub"
[ -f "$SSH_KEY_PATH" ] || { echo "Error: SSH key not found at $SSH_KEY_PATH"; exit 1; }

# Setup directories
mkdir -p "$VM_DIR/cidata"
cd "$VM_DIR"

# Print config summary
echo "==> Spinning up Fedora v${FEDORA_VERSION} (ram=${VM_RAM}MB, cpus=${VM_CPUS}, machine=${VM_MACHINE}, accel=${VM_ACCEL})"
echo

# Download Fedora Cloud image
FEDORA_QCOW_URL="https://download.fedoraproject.org/pub/fedora/linux/releases/${FEDORA_VERSION}/Cloud/x86_64/images/Fedora-Cloud-Base-Generic-${FEDORA_VERSION}-1.1.x86_64.qcow2"
FEDORA_QCOW_NAME="fedora-cloud-${FEDORA_VERSION}.qcow2"

if [ ! -f "$FEDORA_QCOW_NAME" ]; then
	echo "==> Downloading Fedora Cloud qcow2"
	curl -L "$FEDORA_QCOW_URL" -o "$FEDORA_QCOW_NAME"
else
	echo "==> Using existing qcow2"
fi

# Read SSH key
PUBKEY="$(cat "$SSH_KEY_PATH")"

echo "==> Generating user-data"
sed -e "s|{{SSH_KEY}}|${PUBKEY}|g" \
    "$SCRIPT_DIR/templates/user-data.yaml" > cidata/user-data

echo "==> Generating meta-data"
cp "$SCRIPT_DIR/templates/meta-data.yaml" cidata/meta-data

# Build seed ISO
echo "==> Building seed.iso"
mkisofs -output seed.iso \
  -volid cidata \
  -joliet -rock \
  cidata 2>/dev/null

# Generate run script from template
echo "==> Generating run-vm.sh"
sed -e "s|{{VM_DIR}}|${VM_DIR}|g" \
    -e "s|{{SSH_PORT}}|${SSH_PORT}|g" \
    -e "s|{{FEDORA_VERSION}}|${FEDORA_VERSION}|g" \
    -e "s|{{VM_RAM}}|${VM_RAM}|g" \
    -e "s|{{VM_CPUS}}|${VM_CPUS}|g" \
    -e "s|{{VM_MACHINE}}|${VM_MACHINE}|g" \
    -e "s|{{VM_ACCEL}}|${VM_ACCEL}|g" \
    "$SCRIPT_DIR/templates/run-vm.sh" > run-vm.sh

chmod +x run-vm.sh

echo
echo "==> Setup complete. Use 'make start' to run the VM."
