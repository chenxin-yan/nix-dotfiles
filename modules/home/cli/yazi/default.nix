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
    rev = "4dc7f1b6458c2578f4494f10d468c68c1082214f";
    hash = "sha256-BSAOkL4H4LVMbTRFv4kzGGRpLgtKkfNTEsDH2EQ219Q=";
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
          rev = "ed946c3932937cb58b1bcaaf0e45f8e26b14f151";
          hash = "sha256-1qbi/oOcnWTliP+FT4Yk4rwPCRu4KQh3EHJzLY+noUw=";
        };
        compress = pkgs.fetchFromGitHub {
          owner = "KKV9";
          repo = "compress.yazi";
          rev = "80e5268ec74c7ac17d4d739e13a9958cba4c70d3";
          hash = "sha256-9cdA8D/TtwHcLqrtoyIixA0YJmTs+c8FSNrjxp8CYI0=";
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
