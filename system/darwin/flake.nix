{
  description = "Alan's macOS system configuration";

  # Inputs: External dependencies this flake needs
  inputs = {
    # nixpkgs: The main package repository
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    # nix-darwin: macOS system configuration framework
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";  # Use our nixpkgs, not its own
    };
  };

  # Outputs: What this flake produces
  outputs = { self, nix-darwin, nixpkgs, ... }: {
    # darwinConfigurations: System configurations for macOS machines
    darwinConfigurations = {
      # Hostname matches: scutil --get LocalHostName
      "Alans-MacBook-Pro" = nix-darwin.lib.darwinSystem {
        system = "aarch64-darwin";  # Apple Silicon (M1/M2/M3)

        modules = [
          # Main configuration module
          ({ pkgs, ... }: {
            # Packages to install system-wide
            environment.systemPackages = [
              pkgs.vim
              pkgs.git
              pkgs.eza
              pkgs.fd
              pkgs.bat
              pkgs.broot
              pkgs.zoxide
              pkgs.ripgrep
              pkgs.nil
              pkgs.switchaudio-osx
              pkgs.shfmt
              pkgs.qemu
              pkgs.cdrtools
            ];

            # macOS system defaults
            system.defaults = {
              # Dock settings
              dock = {
                autohide = true;
                orientation = "bottom";
                show-recents = false;
              };

              # Finder settings
              finder = {
                AppleShowAllExtensions = true;
                ShowPathbar = true;
                FXEnableExtensionChangeWarning = false;
              };

              # NSGlobalDomain settings (system-wide preferences)
              NSGlobalDomain = {
                # Expand save panel by default
                NSNavPanelExpandedStateForSaveMode = true;
                # Disable automatic capitalization
                NSAutomaticCapitalizationEnabled = false;
                # Disable automatic period substitution
                NSAutomaticPeriodSubstitutionEnabled = false;
              };

              # Screenshot settings
              screencapture = {
                location = "~/Screenshots";
              };
            };

            # Keyboard remapping
            system.keyboard = {
              enableKeyMapping = true;
              # Remap Caps Lock to Control
              remapCapsLockToControl = true;
            };

            # Primary user for system defaults
            system.primaryUser = "alan";

            # Enable Touch ID for sudo
            security.pam.services.sudo_local.touchIdAuth = true;

            # Shell configuration
            programs.zsh.enable = true;

            # Nix settings
            nix.settings = {
              experimental-features = "nix-command flakes";
              # Trust your own user for binary cache
              trusted-users = [ "@admin" ];
            };

            # Used for backwards compatibility
            system.stateVersion = 5;
          })
        ];
      };
    };
  };
}
