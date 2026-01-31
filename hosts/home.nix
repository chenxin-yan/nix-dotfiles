{
  config,
  pkgs,
  lib,
  inputs,
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
    dotfiles-private = lib.mkOption {
      type = lib.types.path;
      apply = toString;
      default = "${config.home.homeDirectory}/dotfiles-private";
      example = "${config.home.homeDirectory}/dotfiles-private";
      description = "Location of the private dotfiles working copy";
    };
    devPath = lib.mkOption {
      type = lib.types.path;
      apply = toString;
      default = "${config.home.homeDirectory}/dev";
      description = "Location of development repositories";
    };
    projectsPath = lib.mkOption {
      type = lib.types.path;
      apply = toString;
      default = "${config.home.homeDirectory}/Projects";
      description = "Location of project directories";
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
      tlrc
      tokei
      hyperfine
      devenv
      croc
      just

      bootdev-cli
      cloudflared

      wechat
      obsidian
      neomutt

      lazyssh
    ];

    home.sessionVariables = {
      DOTFILES_PATH = config.dotfiles;
      DOTFILES_PRIVATE_PATH = config.dotfiles-private;
      DEV_PATH = config.devPath;
      PROJECTS_PATH = config.projectsPath;
      AREAS_PATH = "${config.home.homeDirectory}/Areas";
      NOTES_PATH = "${config.home.homeDirectory}/notes";
    };

    # Let Home Manager install and manage itself.
    programs.home-manager.enable = true;

    programs.btop = {
      enable = true;
      settings = {
        vim_keys = true;
      };
    };
  };
}
