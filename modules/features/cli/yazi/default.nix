{
  features.yazi.homeManager =
    {
      config,
      lib,
      osConfig,
      pkgs,
      ...
    }:
    {
      home.file = {
        ".config/yazi/yazi.toml".source = ./config/yazi.toml;
        ".config/yazi/keymap.toml".source = ./config/keymap.toml;
      };

      # cb backs the system-clipboard plugin (<C-y>), which copies files for
      # GUI apps to paste, so headless machines skip it; there the plugin just
      # reports the failure. Every Mac has a desktop.
      home.packages = lib.optional (
        pkgs.stdenv.hostPlatform.isDarwin || osConfig.services.graphical-desktop.enable
      ) pkgs.clipboard-jh;

      programs.yazi = {
        enable = true;
        shellWrapperName = "y";
        plugins = {
          inherit (pkgs.yaziPlugins)
            full-border
            no-status
            vcs-files
            chmod
            git
            ;
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
          # nixpkgs' yaziPlugins.compress (tag 0.6) calls fs.unique_name, which
          # yazi 26.x removed. Switch to it once nixpkgs packages a newer rev:
          # https://github.com/KKV9/compress.yazi/issues/39
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
