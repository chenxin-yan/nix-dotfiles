{ config, pkgs, ... }:

{
  home.username = "yanchenxin";
  home.homeDirectory = "/Users/yanchenxin";

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
    };
  };
}
