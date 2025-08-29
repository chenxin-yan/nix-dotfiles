{ config, pkgs, ... }:

{

  home.username = "chenxinyan";
  home.homeDirectory = "/home/chenxinyan";

  imports = [ ../home.nix ];

  home.packages = with pkgs; [
  ];

  home.file = {
  };

  # Keychain service for SSH key management (Linux-specific)
  programs.keychain = {
    enable = true;
    enableZshIntegration = true;
    keys = [ "id_ed25519" ];
  };

  # SSH agent service (Linux-specific)
  services.ssh-agent.enable = true;
}
