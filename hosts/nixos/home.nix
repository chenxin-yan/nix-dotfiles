{
  config,
  pkgs,
  ...
}:

{
  home.username = "cyan";
  home.homeDirectory = "/home/cyan";

  imports = [
    ../home.nix
    ../../modules/home
  ];

  home.packages = with pkgs; [
    chromium
  ];

  catppuccin.cursors.enable = true;

  services.ssh-agent.enable = true;

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
}
