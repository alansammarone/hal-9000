![HAL 9000](hal-9000.png)

# Shell Config

My terminal setup. Dotfiles for zsh, kitty, tmux, and whatever else ends up here.

Everything lives in `config/` and symlinks to `~/`. The actual config files are version-controlled here; your home directory just points to them. Edit either place, same result.

Currently running on macOS with some consideration for Linux compatibility when SSHing around.

## What's Here

- **zsh/** - aliases, functions, env vars, and terminal-specific rc files
- **kitty/** - terminal emulator config
- **tmux/** - mostly just for bottom padding honestly
- **nix/** - nix-darwin flake because we're slowly going down that rabbit hole

I'm sorry Dave, I'm afraid I can't use bash.
