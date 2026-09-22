# Shared preferences, paths and core tools for every managed home.
# Hosts opt into ./development.nix, ./desktop.nix and cli.syncthing themselves.
{
  config,
  pkgs,
  lib,
  ...
}:

{
  imports = [
    ../../modules/home
  ];

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
    agents.enable = lib.mkDefault true;
    core.git.enable = lib.mkDefault true;
    core.nvim.enable = lib.mkDefault true;
    core.zsh.enable = lib.mkDefault true;
    core.nushell.enable = lib.mkDefault true;

    catppuccin = {
      autoEnable = true;
      enable = true;
      flavor = "mocha";
      accent = "lavender";
      zsh-syntax-highlighting.enable = false;
    };

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

      opencode
    ];

    home.sessionVariables = {
      XDG_CONFIG_HOME = "${config.home.homeDirectory}/.config";
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
