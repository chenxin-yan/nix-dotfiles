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
      rainfrog
      tokei
      hyperfine
      devenv
      croc

      bootdev-cli
      cloudflared

      wechat
      logseq
      neomutt
    ];

    home.sessionVariables = {
      DOTFILES_PATH = config.dotfiles;
      DOTFILES_PRIVATE_PATH = config.dotfiles-private;
      DEV_PATH = "${config.home.homeDirectory}/dev";
      PROJECTS_PATH = "${config.home.homeDirectory}/Projects";
      AREAS_PATH = "${config.home.homeDirectory}/Areas";
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
