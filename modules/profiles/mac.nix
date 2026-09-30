# Everything every registered Mac gets: the full development + desktop
# stack, the macOS window-management setup and shared system policy.
# Account facts, state versions and hostnames stay in modules/hosts/<name>.
{ config, inputs, ... }:
let
  inherit (config) hosts;
in
{
  features.mac = {
    includes = with config.features; [
      base
      development
      apps
      nix-gc
      nix-settings
      nh
      unfree
      tailscale
      ssh
      mosh
      _1password
      aerospace
      kanata
      sketchybar
      iina
    ];

    darwin =
      { pkgs, ... }:
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

        # Set Git commit hash for darwin-version.
        system.configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null;

        fonts.packages = [
          pkgs.nerd-fonts.jetbrains-mono
          pkgs.geist-font
        ];

        # Both Macs deliberately remove unlisted Homebrew packages and associated
        # cask data; include everything to retain in the effective Homebrew config.
        homebrew = {
          enable = true;
          brews = [
            "mole"
          ];
          onActivation = {
            cleanup = "zap";
          };
        };
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
        ];

        programs.ssh = {
          settings = {
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
      };
  };
}
