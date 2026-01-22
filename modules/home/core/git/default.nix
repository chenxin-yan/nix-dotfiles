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

    home.packages = with pkgs; [
      lazyworktree
    ];

    # lazyworktree configuration
    xdg.configFile."lazyworktree/config.yaml".text = ''
      worktree_dir: ${config.devPath}/worktrees
      theme: catppuccin-mocha
    '';

    programs.git = {
      enable = true;

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
        git_protocol = "https";
        aliases = {
          co = "pr checkout";
        };
      };

      hosts = {
        "github.com" = {
          git_protocol = "ssh";
          users = {
            "chenxin-yan" = {
              user = "chenxin-yan";
            };
          };
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
        lw = "lazyworktree";
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
