{ config, pkgs, ... }:
let
  yazi-plugins = pkgs.fetchFromGitHub {
    owner = "yazi-rs";
    repo = "plugins";
    rev = "main";
    hash = "sha256-9+58QhdM4HVOAfEC224TrPEx1N7F2VLGMxKVLAM4nJw=";
  };
in
{
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
      require("full-border"):setup()
      require("no-status"):setup()
      require("omp"):setup({ config = "${config.xdg.configHome}/oh-my-posh/config.json" })
    '';
  };

  programs.zsh.initContent = ''
    # Yazi file manager with directory change
    function e() {
      local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
      yazi "$@" --cwd-file="$tmp"
      if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
        builtin cd -- "$cwd"
      fi
      rm -f -- "$tmp"
    }
  '';
}
