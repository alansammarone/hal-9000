# Fedora Cloud QEMU Builder

x86_64 Fedora Cloud VM with podman service socket exposed via SSH.

## Prerequisites

- `qemu`, `mkisofs` in PATH (via nix flake: `pkgs.qemu`, `pkgs.cdrtools`)
- SSH key at `~/.ssh/personal/qemu_fedora_builder{,.pub}`

## Setup

```bash
./setup.sh
```

Creates `~/Code/VMs/podman-builder/` with cloud-init seed.iso and run-vm.sh.

## Usage

```bash
make start   # Start VM in daemon mode
make ssh     # SSH into VM
make logs    # Tail console logs
make stop    # Stop VM
make status  # Check if running
```

## Connect podman

```bash
podman system connection add qemu-builder \
  ssh://root@127.0.0.1:2222/run/podman/podman.sock

podman --connection qemu-builder build -t image:tag .
```

## Configuration

Edit `setup.sh` variables: `VM_RAM`, `VM_CPUS`, `VM_ACCEL`, `VM_MACHINE`, `FEDORA_VERSION`.
