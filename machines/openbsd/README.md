# OpenBSD QEMU VM

Reproducible OpenBSD 7.8 (amd64) VM with explicit QEMU configuration for control and learning.

## Prerequisites

- QEMU (`qemu-system-x86_64`, `qemu-img`)
- signify (for ISO verification)
- Python 3 (for HTTP server during installation)
- SSH key at `~/.ssh/personal/qemu_openbsd{,.pub}`

Install on macOS:
```bash
brew install qemu signify-osx
ssh-keygen -t ed25519 -f ~/.ssh/personal/qemu_openbsd
```

## Quick Start

```bash
# 1. Setup (downloads ISO, creates disk, generates configs)
./setup.sh

# 2. Install OpenBSD (one-time, interactive)
~/Code/VMs/openbsd-qemu/run-install.sh
# Press 'I' then 'A' for autoinstall, or answer manually
# Press Ctrl-C when VM reboots after install

# 3. First boot and post-install
make start
make post-install  # Copies script to VM
make ssh
# Inside VM: doas sh /tmp/post-install-config.sh
# Inside VM: doas halt -p

# 4. Create base snapshot
cd ~/Code/VMs/openbsd-qemu
mv openbsd-7.8.qcow2 openbsd-7.8-base.qcow2
qemu-img create -f qcow2 -F qcow2 \
  -b openbsd-7.8-base.qcow2 \
  openbsd-7.8.qcow2

# 5. Daily use
make start   # Start VM
make ssh     # SSH into VM
make logs    # View console logs
make stop    # Stop VM
make reset   # Discard changes, reset to base
```

## Installation Details

### ISO Choice

**install78.iso** (~600MB) - Contains all file sets for offline installation
- No network required during install
- Alternative: cd78.iso only includes installer kernel, requires network for sets

Download URL: https://cdn.openbsd.org/pub/OpenBSD/7.8/amd64/install78.iso

### Autoinstall

The installer uses `install.conf` for automated setup:
- Serial console on com0 (115200 baud)
- Disk: sd0 with auto layout (OpenBSD's sensible defaults)
- Network: vio0 (virtio-net) with DHCP
- Sets: base, compiler, man pages (excludes games, X server)
- User with SSH key authentication
- **Security Note**: Passwords are stored in plaintext in `install.conf` and hashed during installation. Use temporary passwords and change them after first boot, or rely on SSH key authentication only.

The `install.conf` file is delivered via **HTTP** using Python's built-in HTTP server. The `run-install.sh` script automatically starts the HTTP server and uses QEMU's user-mode networking to make it accessible to the installer at `http://10.0.2.2:8888/install.conf`.

Press 'I' at installer welcome screen, then 'A' to trigger autoinstall. When prompted for the location, enter the HTTP URL shown by the script.

Or answer questions manually - see `install.conf` for reference values.

### Post-Install Configuration

The `post-install-config.sh` script:
- Configures `doas` (OpenBSD's sudo): `permit persist :wheel`
- Hardens SSH: disables password auth and root login
- Installs packages: curl, vim, git, tmux, rsync

## QEMU Configuration

Edit `~/Code/VMs/openbsd-qemu/run-vm.sh` to customize VM behavior.

All parameters are explicit and documented with alternatives:

### Machine Type
```bash
MACHINE_TYPE="q35"    # Modern PCIe chipset (recommended)
# Alternative: "pc"   # Legacy i440fx PCI chipset
```

### Accelerator
```bash
ACCELERATOR="tcg"     # Software emulation (portable, works on Apple Silicon)
# Alternative: "kvm"  # Linux only, requires KVM kernel module (much faster)
# Alternative: "hvf"  # macOS Hypervisor.framework (ARM64 guests only)
```

Note: `hvf` on Apple Silicon does NOT support x86_64 guests. Use `tcg` for amd64 OpenBSD on M-series Macs.

### Disk Interface
```bash
DISK_INTERFACE="virtio"  # Paravirtualized (best performance, appears as sd0)
# Alternative: "ide"     # Legacy emulation (slower, appears as wd0)
# Alternative: "scsi"    # With virtio-scsi-pci device (more flexible)
```

### Network Device
```bash
NETWORK_DEVICE="virtio-net-pci"  # Paravirtualized (fast, OpenBSD vio driver)
# Alternative: "e1000"             # Intel emulation (slower, more compatible)
# Alternative: "rtl8139"           # Realtek emulation (legacy)
```

### Console
```bash
SERIAL_MODE="file:vm-console.log"  # Log to file (daemon mode)
# Alternative: "stdio"              # Interactive console (for debugging)
```

For interactive console, also remove `-daemonize` flag.

### Display
```bash
DISPLAY_MODE="none"    # Headless (recommended for server VM)
# Alternative: "vnc=:0" # VNC server on port 5900
# Alternative: "gtk"    # Local graphical window (requires X11/Wayland)
```

## Architecture

### Two-Tier Disk System

```
openbsd-7.8-base.qcow2   # Pristine post-install snapshot (never modified)
           ↓
openbsd-7.8.qcow2        # COW overlay (VM writes here)
```

Benefits:
- **Fast reset**: Discard overlay, recreate from base (instant clean slate)
- **Preserve pristine state**: Base image never touched
- **Disk efficiency**: Overlay only stores deltas

### File Layout

```
~/Code/VMs/openbsd-qemu/
├── install78.iso                  # Downloaded installation media
├── install.conf                   # Autoinstall answer file (served via HTTP)
├── openbsd-7.8-base.qcow2         # Pristine base (created after setup)
├── openbsd-7.8.qcow2              # Working overlay
├── run-vm.sh                      # Production runner (daemon mode)
├── run-install.sh                 # Installation runner (starts HTTP server)
├── post-install-config.sh         # Post-install configuration
├── qemu.pid                       # Process ID when running
└── vm-console.log                 # Serial console output
```

## Makefile Targets

```bash
make start         # Start VM in daemon mode
make stop          # Stop VM gracefully
make ssh           # SSH into running VM
make logs          # Tail console logs
make status        # Check if VM is running
make reset         # Discard overlay, reset to base
make clean         # Delete ALL VM data (asks for confirmation)
make install-help  # Show installation instructions
make post-install  # Copy post-install script to VM
```

## SSH Access

**During installation**: Use the password you provided during `./setup.sh`

**After post-install**: Key-based authentication only
```bash
ssh -p 2223 -i ~/.ssh/personal/qemu_openbsd <user>@127.0.0.1
# Or: make ssh
```

## OpenBSD-Specific Patterns

This setup follows OpenBSD conventions:

- **doas**, not sudo - Simpler config, OpenBSD native
- **pkg_add** package management - Minimal output by default
- **ksh** default shell - Fast, POSIX-compliant
- **rc.d** init system - Simple shell scripts
- **Auto disk layout** - Trust OpenBSD's partitioning (/, swap, /tmp, /var, /usr, /home)
- **Security by default** - sshd already hardened, password auth disabled post-install

## Resource Usage

- **RAM**: 2GB (configurable in `setup.sh`)
- **CPUs**: 2 cores (configurable in `setup.sh`)
- **Disk**: 20GB qcow2 (sparse allocation, grows as needed)
- **SSH Port**: 2223 (avoids conflict with Fedora VM on 2222)

## Troubleshooting

**VM won't start**
```bash
make status
make logs
```

**Can't SSH**
- Ensure post-install config was run
- Check SSH key path: `~/.ssh/personal/qemu_openbsd`
- Verify VM is running: `make status`

**Slow performance**
- TCG is software emulation (expected on Apple Silicon for x86 guests)
- On Linux x86 hosts: change `ACCELERATOR="kvm"` in run-vm.sh for 10-100x speedup
- On macOS x86 hosts: TCG is your only option for stability

**Serial console not working**
- Check console speed matches: 115200 baud in both install.conf and QEMU `-serial`
- View logs: `make logs` or `tail -f ~/Code/VMs/openbsd-qemu/vm-console.log`

**Installation hangs or drops to shell**
- Press Ctrl-C and restart: `~/Code/VMs/openbsd-qemu/run-install.sh`
- If you see "password not set" errors, ensure you ran `./setup.sh` to create the autoinstall.img floppy
- Check that autoinstall.img exists in the VM directory
- Try manual installation instead of autoinstall
- Check console logs for errors

**Autoinstall not finding install.conf**
- Verify autoinstall.img exists: `ls ~/Code/VMs/openbsd-qemu/autoinstall.img`
- The floppy is automatically mounted during installation
- If it still fails, you can manually specify the location when prompted

## OpenBSD Resources

- [FAQ - Installation Guide](https://www.openbsd.org/faq/faq4.html)
- [autoinstall(8) manual](https://man.openbsd.org/autoinstall.8)
- [virtio(4) drivers](https://man.openbsd.org/virtio.4)
- [doas(1) manual](https://man.openbsd.org/doas.1)
- [OpenBSD 7.8 Release Notes](https://www.openbsd.org/78.html)

## Customization Examples

### Change disk size
Edit `setup.sh` before running:
```bash
qemu-img create -f qcow2 "$DISK_NAME" 50G  # Instead of 20G
```

### Add more port forwards
Edit `run-vm.sh`, add to `-netdev` line:
```bash
-netdev "user,id=net0,hostfwd=tcp:127.0.0.1:2223-:22,hostfwd=tcp:127.0.0.1:8080-:80"
```

### Use VNC for installation
Edit `run-install.sh`, replace `-display none` with:
```bash
-vnc :0
```
Then connect with VNC client to `localhost:5900`

### Increase RAM/CPUs
Edit `setup.sh` before running:
```bash
VM_RAM=4096   # 4GB
VM_CPUS=4     # 4 cores
```

### Use UEFI instead of BIOS
Requires OVMF firmware. Edit `run-vm.sh`:
```bash
-bios /usr/share/OVMF/OVMF_CODE.fd
```
Note: May require additional setup for OpenBSD UEFI boot.

## Comparison to Fedora Setup

| Aspect | OpenBSD | Fedora |
|--------|---------|--------|
| Provisioning | autoinstall (install.conf) | cloud-init (user-data.yaml) |
| Setup | One-time interactive | Fully automated |
| Privilege | doas | sudo |
| Packages | pkg_add | dnf |
| Init | rc.d | systemd |
| Resources | 2GB RAM, 2 CPUs | 8GB RAM, 4 CPUs |
| SSH Port | 2223 | 2222 |
| Philosophy | Minimal, secure by default | Comprehensive, flexible |

## License

OpenBSD is freely available under the BSD license.
