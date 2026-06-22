{ config, pkgs, ... }:

{
  imports = [
    ../home.nix
    ../../modules/home
  ];

  home.packages = with pkgs; [
    wechat
    obsidian
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
        User = "cyan";
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
    clean.extraArgs = "--keep-since 4d --keep 3";
  };
  app.shared.zen-browser.enable = false;
}
