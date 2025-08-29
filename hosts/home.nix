{ config, pkgs, ... }:

{
  catppuccin = {
    enable = true;
    flavor = "mocha";
    accent = "lavender";
    zsh-syntax-highlighting.enable = false;
  };

  fonts.fontconfig.enable = true;
  home.stateVersion = "25.05";

  # Shared packages
  home.packages = with pkgs; [
    nerd-fonts.jetbrains-mono

    tlrc
    curlie
    rainfrog
    opencode
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  programs.btop = {
    enable = true;
    settings = {
      vim_keys = true;
    };
  };

  # SSH client configuration
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

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };
}
