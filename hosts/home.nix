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
    devPath = lib.mkOption {
      type = lib.types.path;
      apply = toString;
      default = "${config.home.homeDirectory}/dev";
      description = "Location of development repositories";
    };
    projectsPath = lib.mkOption {
      type = lib.types.path;
      apply = toString;
      default = "${config.home.homeDirectory}/PARA/01 Projects";
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
      vhs
      cursor-cli

      wechat
      obsidian
    ];

    home.sessionVariables = {
      DOTFILES_PATH = config.dotfiles;
      DEV_PATH = config.devPath;
      PROJECTS_PATH = config.projectsPath;
      AREAS_PATH = "${config.home.homeDirectory}/PARA/02 Areas";
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
