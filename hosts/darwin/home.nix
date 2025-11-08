{ config, pkgs, ... }:

{

  imports = [ ../home.nix ];

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
