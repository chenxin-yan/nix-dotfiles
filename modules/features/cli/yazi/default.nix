{ inputs, ... }:
{
  # TODO: remove, with the nixpkgs-clipboard-jh input, once clipboard-jh
  # builds on NixOS again. 0.10.0 fails with GCC 16 (SSIZE_MAX undeclared in
  # src/cbwayland/src/fd.cpp, a missing <climits>), and neither nixpkgs nor
  # upstream has a fix yet. Until then NixOS uses the last working build, from
  # the nixpkgs locked before 301655f. The Macs build with clang and are
  # unaffected. Try it with:
  #   nix build .#nixosConfigurations.framework.pkgs.clipboard-jh --override-input nixpkgs-clipboard-jh nixpkgs
  features.yazi-clipboard.nixos.nixpkgs.overlays = [
    (final: _: {
      inherit (inputs.nixpkgs-clipboard-jh.legacyPackages.${final.stdenv.hostPlatform.system})
        clipboard-jh
        ;
    })
  ];

  # cb backs the system-clipboard plugin (<C-y>), which copies files for GUI
  # apps to paste, so only the desktop role selects it. Without cb the plugin
  # just reports the failure.
  features.yazi-clipboard.homeManager =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.clipboard-jh ];
    };

  features.yazi.homeManager =
    { config, pkgs, ... }:
    let
      yazi-plugins = pkgs.fetchFromGitHub {
        owner = "yazi-rs";
        repo = "plugins";
        rev = "33dde2872cee694543fe37619628a9005921c52c";
        hash = "sha256-r6a/6yNTrLcHlpPrIjNDGOf0u+ZXUUIX4QbV35Ib+jw=";
      };
    in
    {
      home.file = {
        ".config/yazi/yazi.toml".source = ./config/yazi.toml;
        ".config/yazi/keymap.toml".source = ./config/keymap.toml;
      };

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
