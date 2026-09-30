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
      desktop
      nix-gc
      nix-settings
      nh
      unfree
      tailscale
      ssh
      sshd
      mosh
      homebrew
      locale
      fonts
      keymapp
      obsidian
      wechat
      aerospace
      kanata
      sketchybar
      iina
    ];

    darwin = {
      # Set Git commit hash for darwin-version.
      system.configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null;
    };

    homeManager =
      { config, ... }:
      {
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
