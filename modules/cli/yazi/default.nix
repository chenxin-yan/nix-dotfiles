{
  config,
  pkgs,
  lib,
  ...
}:
let
  yazi-plugins = pkgs.fetchFromGitHub {
    owner = "yazi-rs";
    repo = "plugins";
    rev = "main";
    hash = "sha256-52Zn6OSSsuNNAeqqZidjOvfCSB7qPqUeizYq/gO+UbE=";
  };
in
{
  options = {
    cli.yazi.enable = lib.mkEnableOption "enables yazi file manager";
  };

  config = lib.mkIf config.cli.yazi.enable {
    home.file = {
      ".config/yazi/yazi.toml".source = ./config/yazi.toml;
      ".config/yazi/keymap.toml".source = ./config/keymap.toml;
    };

    home.packages = with pkgs; [
      clipboard-jh # clipboard manager
    ];

    programs.yazi = {
      enable = true;
      enableZshIntegration = true;
      plugins = {
        full-border = "${yazi-plugins}/full-border.yazi";
        no-status = "${yazi-plugins}/no-status.yazi";
        vcs-files = "${yazi-plugins}/vcs-files.yazi";
        chmod = "${yazi-plugins}/chmod.yazi";
        git = "${yazi-plugins}/git.yazi";
        omp = pkgs.fetchFromGitHub {
          owner = "saumyajyoti";
          repo = "omp.yazi";
          rev = "main";
          hash = "sha256-MvItTUorB0rWg7L3KXUsF3+1KE+wm38C1yAGSfpQ5gg=";
        };
        system-clipboard = pkgs.fetchFromGitHub {
          owner = "orhnk";
          repo = "system-clipboard.yazi";
          rev = "master";
          hash = "sha256-M7zKUlLcQA3ihpCAZyOkAy/SzLu31eqHGLkCSQPX1dY=";
        };
      };

      initLua = ''
        require("git"):setup()
        require("full-border"):setup()
        require("no-status"):setup()
        require("omp"):setup({ config = "${config.xdg.configHome}/oh-my-posh/config.json" })
      '';
    };

    programs.zsh.initContent = ''
      yazi-widget() {
        yy
        for precmd_func in $precmd_functions; do
          $precmd_func
        done
        zle reset-prompt
      }
      zle -N yazi-widget
      bindkey '^e' yazi-widget
    '';
  };
}
