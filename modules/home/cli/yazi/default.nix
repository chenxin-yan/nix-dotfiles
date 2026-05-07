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
    rev = "4ffa48f33465c22cce48c5d506295a3eb27c1979";
    hash = "sha256-wr5QL493A175dRjYSyYpMMJax1RKWaZ3jAdFdL3XXTw=";
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
      shellWrapperName = "y";
      plugins = {
        full-border = "${yazi-plugins}/full-border.yazi";
        no-status = "${yazi-plugins}/no-status.yazi";
        vcs-files = "${yazi-plugins}/vcs-files.yazi";
        chmod = "${yazi-plugins}/chmod.yazi";
        git = "${yazi-plugins}/git.yazi";
        omp = pkgs.fetchFromGitHub {
          owner = "saumyajyoti";
          repo = "omp.yazi";
          rev = "32ae96c8da930641ee81c32f76b2d7452ba6c8d9";
          hash = "sha256-jawTDIMHIu6YYWcKy9TOuk37yiRcHZ+IhZcdNLE/2VU=";
        };
        system-clipboard = pkgs.fetchFromGitHub {
          owner = "orhnk";
          repo = "system-clipboard.yazi";
          rev = "master";
          hash = "sha256-djvSPRHjP9bc4eXTiHwty4byVgVFRBDvfNYlX/nHVaw=";
        };
        compress = pkgs.fetchFromGitHub {
          owner = "KKV9";
          repo = "compress.yazi";
          rev = "46a6b9f02ff2f8aced466a1f01a3fe241f1cd45f";
          hash = "sha256-Mby185FCJY6nqHcHDQu+D5SLk+wGcyeUHK8yAvrd4TM=";
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
