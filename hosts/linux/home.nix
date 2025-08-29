{ config, pkgs, ... }:

{

  home.username = "chenxinyan";
  home.homeDirectory = "/home/chenxinyan";

  imports = [ ../home.nix ];

  home.packages = with pkgs; [
  ];

  home.file = {
  };

  services.ssh-agent.enable = true;
}
