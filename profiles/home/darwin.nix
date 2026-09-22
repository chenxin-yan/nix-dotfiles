# Home policy shared by every registered Mac: full development + desktop
# selection plus the macOS-specific packages, SSH client peers and NH setup.
# Host files own the home state version and the Syncthing enrollment.
{
  config,
  pkgs,
  hosts,
  ...
}:

{
  imports = [
    ./base.nix
    ./development.nix
    ./desktop.nix
  ];

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

  programs.nh = {
    enable = true;
    clean.enable = false;
    clean.extraArgs = "--keep-since 3d --keep 2";
  };
  app.shared.zen-browser.enable = false;
}
