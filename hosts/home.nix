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
    ];

    home.sessionVariables = {
      EDITOR = "nvim";
      DOTFILES_PATH = config.dotfiles;
      DEV_PATH = "${config.home.homeDirectory}/dev";
      OBSIDIAN_VAULT_PATH = "${config.home.homeDirectory}/Ideaverse";
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
