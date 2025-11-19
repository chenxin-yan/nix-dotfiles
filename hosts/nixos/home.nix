{
  config,
  pkgs,
  ...
}:

{

  home.username = "cyan";
  home.homeDirectory = "/home/cyan";

  imports = [ ../home.nix ];

  home.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    ghostty
  ];

  fonts.fontconfig.enable = true;

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
