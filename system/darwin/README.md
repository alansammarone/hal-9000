# nix-darwin Quick Reference

Practical commands and locations for managing your Nix system configuration.

## File Locations

- **Config file:** `~/Code/ClaudeAutomation/Shell/Nix/flake.nix`
- **Symlinked to:** `~/.config/nix-darwin/flake.nix`
- **Lock file:** `~/.config/nix-darwin/flake.lock`
- **System packages:** `/run/current-system/sw/bin/`
- **Nix store:** `/nix/store/`




## Common Commands/Workflows

### Apply Configuration Changes
```bash
# Apply current configuration (uses existing lock file)
make apply

# Update nixpkgs to latest versions and apply
make update
```



### Search for Packages
```bash
# Search nixpkgs
nix search nixpkgs <search-term>

# Example: search for ripgrep
nix search nixpkgs ripgrep
```

### Explore a Flake
```bash
# See what outputs a flake provides
nix flake show <flake-url>

# Example
nix flake show github:Siriusmart/youtube-tui
```




### Temporary Package Testing
```bash
# Run a package without installing
nix run nixpkgs#<package>

# Example: try htop
nix run nixpkgs#htop

# Shell with multiple packages temporarily available
nix shell nixpkgs#ripgrep nixpkgs#fd nixpkgs#bat
```

### Package Addition Workflow

1. Search nixpkgs first: `nix search nixpkgs <package>`
2. If found: Use `pkgs.<package>` in flake.nix
3. If not: Check if external flake exists and is maintained
4. Apply: `darwin-rebuild switch --flake ~/.config/nix-darwin`
5. Restart shell: `exec zsh`

### System Information
```bash
# Check current system generation
darwin-rebuild --list-generations

# See what's in your current system
ls -la /run/current-system/sw/bin/
```

### Rollback
```bash
# Roll back to previous generation
sudo darwin-rebuild --rollback

# Or switch to specific generation
sudo darwin-rebuild switch --flake ~/Code/ClaudeAutomation/Shell/Nix --switch-generation <number>
```

## Adding a Package

1. **Edit the config:**
   ```bash
   vim ~/Code/ClaudeAutomation/Shell/Nix/flake.nix
   ```

2. **Add to `environment.systemPackages`:**
   ```nix
   environment.systemPackages = [
     pkgs.youtube-tui
     pkgs.vim
     pkgs.git
     pkgs.ripgrep  # <- Add new package here
   ];
   ```

3. **Apply changes:**
   ```bash
   make apply
   ```


## Useful Resources

- [Search nixpkgs packages](https://search.nixos.org/packages)
- [nix-darwin options](https://daiderd.com/nix-darwin/manual/index.html)
- [home-manager options](https://nix-community.github.io/home-manager/options.xhtml)
- [Nix reference manual](https://nixos.org/manual/nix/stable/)
