{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:

{
  imports = [ inputs.hunk.homeManagerModules.default ];

  options = {
    core.git.enable = lib.mkEnableOption "enables git version control and related tools";
  };

  config = lib.mkIf config.core.git.enable {

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

    programs.hunk = {
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
