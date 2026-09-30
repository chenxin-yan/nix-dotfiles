# Everything every registered Mac gets: the full development + desktop
# stack, the macOS window-management setup and shared system policy.
# Account facts, state versions and hostnames stay in modules/hosts/<name>.
{ config, ... }:
let
  inherit (config) hosts;
in
{
  features.mac = {
    includes = with config.features; [
      base
      development
      desktop
      nix-gc
      _1password
      aerospace
      kanata
      sketchybar
      iina
    ];

    darwin =
      {
        config,
        pkgs,
        ...
      }:
      {
        # Fix macOS locale issue (BCP 47 format incompatible with Unix tools)
        environment.variables = {
          LANG = "en_US.UTF-8";
          LC_ALL = "en_US.UTF-8";
        };

        # List packages installed in system profile. To search by name, run:
        # $ nix-env -qaP | grep wget
        environment.systemPackages = with pkgs; [
          keymapp
        ];

        nix.settings.experimental-features = [
          "nix-command"
          "flakes"
        ];

        # Set Git commit hash for darwin-version.
        system.configurationRevision = config.rev or config.dirtyRev or null;

        programs.zsh.enable = true;

        nixpkgs.config.allowUnfree = true;

        fonts.packages = [
          pkgs.nerd-fonts.jetbrains-mono
          pkgs.sketchybar-app-font
          pkgs.geist-font
        ];

        # Both Macs deliberately remove unlisted Homebrew packages and associated
        # cask data; include everything to retain in the effective Homebrew config.
        homebrew = {
          enable = true;
          brews = [
            "mole"
          ];
          casks = [
            "font-sf-pro"
            "todoist-app"
          ];
          onActivation = {
            cleanup = "zap";
          };
        };

        services.tailscale.enable = true;

        services.openssh.enable = true;
      };

    homeManager =
      {
        config,
        pkgs,
        ...
      }:
      {
        home.packages = with pkgs; [
          wechat
          obsidian
          mosh
        ];

        programs.ssh = {
          enable = true;
          enableDefaultConfig = false;
          settings = {
            "github.com" = {
              AddKeysToAgent = "yes";
              IdentityFile = "${config.home.homeDirectory}/.ssh/id_ed25519";
              UseKeychain = "yes";
            };

            "cyan-minipc" = {
              User = hosts.minipc.login;
              IdentityFile = "${config.home.homeDirectory}/.ssh/id_ed25519";
              ControlMaster = "auto";
              ControlPersist = "10m";
              ControlPath = "${config.home.homeDirectory}/.ssh/cm-%C";
            };

            "cyanpi" = {
              User = "yanchenxin";
              IdentityFile = "${config.home.homeDirectory}/.ssh/id_ed25519";
            };
          };
        };

        programs.nh.enable = true;
      };
  };
}
