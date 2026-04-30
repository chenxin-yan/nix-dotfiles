{
  config,
  pkgs,
  lib,
  ...
}:

{
  options = {
    core.git.enable = lib.mkEnableOption "enables git version control and related tools";
  };

  config = lib.mkIf config.core.git.enable {

    programs.git = {
      enable = true;

      # Global gitignore (written to ~/.config/git/ignore;
      # core.excludesFile is set automatically by home-manager).
      #
      # `.pi-lens/` — belt-and-suspenders for the pi-lens cwd-pollution
      # problem. The real fix is `PILENS_DATA_DIR`, set in
      # modules/home/cli/pi/default.nix; this entry just keeps any stray
      # `.pi-lens/` directory out of `git status` for cases where the env
      # var didn't apply (pi-lens releases predating v3.8.34, GUI launches
      # on macOS that bypass home.sessionVariables, the rule-cache.ts gap
      # that still hardcodes `<cwd>/.pi-lens/cache/` on master, etc.).
      # Safe to keep indefinitely.
      ignores = [
        ".pi-lens/"
      ];

      settings = {
        user = {
          name = "Chenxin Yan";
          email = "yanchenxin2004@gmail.com";
        };

        alias = {
          co = "checkout";
          br = "branch";
          st = "status -sb";
          lg = "log --oneline --graph --decorate";
          amend = "commit --amend --no-edit";
        };

        init.defaultBranch = "main";
        pull.rebase = true;
        rebase.autosquash = true;
        push.default = "current";
        fetch.prune = true;
        color.ui = true;
        core.editor = "nvim";
      };
    };

    programs.delta = {
      enable = true;
      enableGitIntegration = true;
    };

    programs.gh = {
      enable = true;

      settings = {
        git_protocol = "ssh";
        aliases = {
          co = "pr checkout";
        };
      };
    };

    programs.gh-dash.enable = true;

    programs.lazygit = {
      enable = true;
      enableZshIntegration = true;
      settings = {
        keybinding = {
          universal = {
            quit = "Q";
            quitWithoutChangingDirectory = "q";
          };
        };
      };
    };

    programs.zsh = {
      shellAliases = {
        g = "git";
      };
    };

    programs.zsh.initContent = ''
      lazygit-widget() {
        lg
        for precmd_func in $precmd_functions; do
          $precmd_func
        done
        zle reset-prompt
      }
      zle -N lazygit-widget
      bindkey '^g' lazygit-widget
    '';
  };
}
