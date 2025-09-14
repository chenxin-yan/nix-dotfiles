{
  config,
  pkgs,
  nixgl,
  ...
}:

{

  home.username = "chenxinyan";
  home.homeDirectory = "/home/chenxinyan";

  nix = {
    package = pkgs.nix;
    settings = {
      experimental-features = "nix-command flakes";
    };
  };

  nixGL = {
    packages = nixgl.packages;
    defaultWrapper = "mesa"; # choose from nixGL options depending on GPU
  };

  imports = [ ../home.nix ];

  home.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    ghostty
  ];

  home.file = {
  };

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
