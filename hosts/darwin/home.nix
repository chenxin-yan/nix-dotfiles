{ config, pkgs, ... }:

{
  imports = [
    ../home.nix
    ../../modules
  ];

  home.packages = with pkgs; [
  ];

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks = {
      "github.com" = {
        addKeysToAgent = "yes";
        identityFile = "${config.home.homeDirectory}/.ssh/id_ed25519";
        extraOptions = {
          UseKeychain = "yes";
        };
      };

      "cyan-minipc" = {
        user = "cyan";
        identityFile = "${config.home.homeDirectory}/.ssh/id_ed25519";
      };

      "cyanpi" = {
        user = "yanchenxin";
        identityFile = "${config.home.homeDirectory}/.ssh/id_ed25519";
      };
    };
  };

  programs.nh = {
    enable = true;
    clean.enable = false;
    clean.extraArgs = "--keep-since 4d --keep 3";
  };
}
