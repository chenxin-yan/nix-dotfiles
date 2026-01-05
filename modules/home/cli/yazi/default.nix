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
    hash = "sha256-5dMAJ6W/L66XuH4CCwRRFpKSLy0ZDFIABAYleFX0AsQ=";
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
          hash = "sha256-gvXC+akaV+WLQyL5cpDJXc59GtkeRxyd0gIThoq0eoU=";
        };
        system-clipboard = pkgs.fetchFromGitHub {
          owner = "orhnk";
          repo = "system-clipboard.yazi";
          rev = "master";
          hash = "sha256-8YtYYxNDfQBTyMxn6Q7/BCiTiscpiZFXRuX0riMlRWQ=";
        };
        compress = pkgs.fetchFromGitHub {
          owner = "KKV9";
          repo = "compress.yazi";
          rev = "main";
          hash = "sha256-teyZP1ij/T92fJx8gf9Z8/ddzcNknNC6KijaYeAzPz8=";
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
        local tmp="$(mktemp -t "yazi-cwd.XXXXX")"
        zle -I  # Prepare the terminal for external command
        yazi --cwd-file="$tmp" < $TTY
        if cwd="$(<"$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
          builtin cd -- "$cwd"
        fi
        rm -f -- "$tmp"
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
