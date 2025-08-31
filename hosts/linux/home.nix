{ config, pkgs, ... }:

{

  home.username = "chenxinyan";
  home.homeDirectory = "/home/chenxinyan";

  imports = [ ../home.nix ];

  home.packages = with pkgs; [
  ];

  home.file = {
  };

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks = {
      "github.com" = {
        addKeysToAgent = "yes";
        identityFile = "${config.home.homeDirectory}/.ssh/id_ed25519";
      };
    };
  };

  services.ssh-agent.enable = true;
}
