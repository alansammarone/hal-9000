#!/bin/sh
# OpenBSD Post-Install Configuration
# Run this script inside the VM after installation completes
#
# Usage: doas sh post-install-config.sh

set -eu

echo "==> Configuring doas (OpenBSD's sudo)"
echo 'permit persist :wheel' > /etc/doas.conf

echo "==> Hardening SSH configuration"
cat >> /etc/ssh/sshd_config <<'EOF'

# QEMU VM hardening
PermitRootLogin no
PasswordAuthentication no
ChallengeResponseAuthentication no
EOF

echo "==> Installing common packages"
pkg_add curl vim git tmux rsync

echo "==> Restarting sshd"
rcctl restart sshd

echo ""
echo "==> Post-install configuration complete!"
echo "==> Shut down the VM with: doas halt -p"
echo "==> Then snapshot the base image (see README.md)"
