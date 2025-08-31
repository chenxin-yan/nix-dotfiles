{
  config,
  pkgs,
  lib,
  ...
}:

{
  options = {
    dotfiles = lib.mkOption {
      type = lib.types.path;
      apply = toString;
      default = "${config.home.homeDirectory}/dotfiles";
      example = "${config.home.homeDirectory}/dotfiles";
      description = "Location of the dotfiles working copy";
    };
  };

  config = {
    catppuccin = {
      enable = true;
      flavor = "mocha";
      accent = "lavender";
      zsh-syntax-highlighting.enable = false;
    };

    fonts.fontconfig.enable = true;
    home.stateVersion = "25.05";

    home.packages = with pkgs; [
      nerd-fonts.jetbrains-mono

      tlrc
      curlie
      rainfrog
    ];

    home.sessionVariables = {
      EDITOR = "nvim";
      DOTFILES_PATH = config.dotfiles;
    };

    # Let Home Manager install and manage itself.
    programs.home-manager.enable = true;

    nix.gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };

    programs.btop = {
      enable = true;
      settings = {
        vim_keys = true;
      };
    };
  };
}
