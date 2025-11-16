![HAL 9000](hal-9000.png)

# Shell Config

My terminal setup. Dotfiles, system configs, and development infrastructure.

Organized by what it does, not where it goes. Everything's version-controlled and symlinked into place.

Currently running on macOS with Linux compatibility for remote boxes and cross-architecture builds.

## What's Here

- **home/** - User-level configs (zsh, kitty, tmux, broot)
- **system/darwin/** - macOS system configuration via nix-darwin
- **machines/fedora/** - QEMU Fedora VM for cross-architecture podman builds
- **deploy/** - Scripts for deploying configs to remote systems
