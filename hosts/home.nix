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

    home.stateVersion = "25.05";

    home.packages = with pkgs; [
      bash
      tlrc
      rainfrog
      tokei

      bootdev-cli
    ];

    home.sessionVariables = {
      EDITOR = "nvim";
      DOTFILES_PATH = config.dotfiles;
      DEV_PATH = "${config.home.homeDirectory}/dev";
      OBSIDIAN_VAULT_PATH = "${config.home.homeDirectory}/Ideaverse";
      PROJECTS_PATH = "${config.home.homeDirectory}/Projects";
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
