#!/usr/bin/env bash
set -euo pipefail

# OpenBSD QEMU VM Setup Script
# Downloads installation ISO, creates disk, generates configuration files

# Configuration
OPENBSD_VERSION=7.8
OPENBSD_ARCH=amd64
VM_DIR="${HOME}/Code/VMs/openbsd-qemu"
VM_HOSTNAME="openbsd-qemu"
VM_USER="${USER}"
SSH_PORT=2223
TIMEZONE="America/Los_Angeles"

# VM Resources
VM_RAM=2048    # MB
VM_CPUS=2      # cores

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Validation
echo "==> Validating dependencies"
command -v qemu-system-x86_64 >/dev/null || { echo "Error: qemu-system-x86_64 not found"; exit 1; }
command -v qemu-img >/dev/null || { echo "Error: qemu-img not found"; exit 1; }
command -v curl >/dev/null || { echo "Error: curl not found"; exit 1; }

SSH_KEY_PATH="${HOME}/.ssh/personal/qemu_openbsd.pub"
if [ ! -f "$SSH_KEY_PATH" ]; then
    echo "Error: SSH public key not found at $SSH_KEY_PATH"
    echo "Generate with: ssh-keygen -t ed25519 -f ~/.ssh/personal/qemu_openbsd"
    exit 1
fi

# Setup directories
echo "==> Creating VM directory: $VM_DIR"
mkdir -p "$VM_DIR"
cd "$VM_DIR"

# Download installation ISO
ISO_VERSION="${OPENBSD_VERSION//./}"  # Remove dot: 7.8 -> 78
ISO_NAME="install${ISO_VERSION}.iso"
ISO_URL="https://cdn.openbsd.org/pub/OpenBSD/${OPENBSD_VERSION}/${OPENBSD_ARCH}/${ISO_NAME}"

if [ ! -f "$ISO_NAME" ]; then
    echo "==> Downloading OpenBSD ${OPENBSD_VERSION} installation ISO"
    echo "    URL: $ISO_URL"
    curl -L -o "$ISO_NAME" "$ISO_URL"
else
    echo "==> Using existing ISO: $ISO_NAME"
fi

# Create virtual disk
DISK_NAME="openbsd-${OPENBSD_VERSION}.qcow2"
if [ ! -f "$DISK_NAME" ]; then
    echo "==> Creating 20GB virtual disk"
    qemu-img create -f qcow2 "$DISK_NAME" 20G
else
    echo "==> Using existing disk: $DISK_NAME"
fi

# Read SSH public key
echo "==> Reading SSH public key from $SSH_KEY_PATH"
PUBKEY="$(cat "$SSH_KEY_PATH")"

# Generate password hashes
echo ""
echo "==> Password hash generation required"
echo "    Run: openssl passwd -6"
echo "    This generates bcrypt hashes for OpenBSD"
echo ""
read -rp "Enter root password hash: " ROOT_HASH
read -rp "Enter user password hash: " USER_HASH

# Generate install.conf
echo "==> Generating install.conf"
sed \
    -e "s|{{VM_HOSTNAME}}|${VM_HOSTNAME}|g" \
    -e "s|{{ROOT_PASSWORD_HASH}}|${ROOT_HASH}|g" \
    -e "s|{{USER_PASSWORD_HASH}}|${USER_HASH}|g" \
    -e "s|{{VM_USER}}|${VM_USER}|g" \
    -e "s|{{SSH_PUBLIC_KEY}}|${PUBKEY}|g" \
    -e "s|{{TIMEZONE}}|${TIMEZONE}|g" \
    "$SCRIPT_DIR/templates/install.conf" > install.conf

# Generate run-vm.sh
echo "==> Generating run-vm.sh (production runner)"
sed \
    -e "s|{{VM_DIR}}|${VM_DIR}|g" \
    -e "s|{{SSH_PORT}}|${SSH_PORT}|g" \
    -e "s|{{OPENBSD_VERSION}}|${OPENBSD_VERSION}|g" \
    -e "s|{{VM_RAM}}|${VM_RAM}|g" \
    -e "s|{{VM_CPUS}}|${VM_CPUS}|g" \
    "$SCRIPT_DIR/templates/run-vm.sh" > run-vm.sh
chmod +x run-vm.sh

# Generate run-install.sh
echo "==> Generating run-install.sh (installation runner)"
sed \
    -e "s|{{VM_DIR}}|${VM_DIR}|g" \
    -e "s|{{VM_RAM}}|${VM_RAM}|g" \
    -e "s|{{VM_CPUS}}|${VM_CPUS}|g" \
    -e "s|{{OPENBSD_VERSION}}|${OPENBSD_VERSION}|g" \
    -e "s|{{ISO_VERSION}}|${ISO_VERSION}|g" \
    "$SCRIPT_DIR/templates/run-install.sh" > run-install.sh
chmod +x run-install.sh

# Copy post-install script
echo "==> Copying post-install-config.sh"
cp "$SCRIPT_DIR/templates/post-install-config.sh" post-install-config.sh
chmod +x post-install-config.sh

echo ""
echo "==> Setup complete!"
echo ""
echo "Files created in $VM_DIR:"
echo "  - $ISO_NAME (installation ISO)"
echo "  - $DISK_NAME (20GB virtual disk)"
echo "  - install.conf (autoinstall answer file)"
echo "  - run-install.sh (installer runner)"
echo "  - run-vm.sh (production runner)"
echo "  - post-install-config.sh (post-install script)"
echo ""
echo "Next steps:"
echo "  1. Run the installer:"
echo "     ${VM_DIR}/run-install.sh"
echo ""
echo "  2. At the OpenBSD boot prompt, either:"
echo "     - Press 'I' and then 'A' to trigger autoinstall"
echo "     - Or answer installation questions manually"
echo ""
echo "  3. After installation completes and VM reboots, press Ctrl-C"
echo ""
echo "  4. See README.md for post-install configuration steps"
echo ""
