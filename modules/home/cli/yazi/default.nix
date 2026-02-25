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
    rev = "b224ddfb4bb6a9b438ac00ccb607b0eb517207d2";
    hash = "sha256-hn6oEFCLhACPh8T/qoPVHbX8Npsjd1EDXsZlm9SzIII=";
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
          rev = "cb6e8ec0141915dc319ccd6b904dcd2f03502576";
          hash = "sha256-D/EpcRDIc3toeyjHqi+vGw0v9B22HVvKJua5EVEAc0U=";
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
