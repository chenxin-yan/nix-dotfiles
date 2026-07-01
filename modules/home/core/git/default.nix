{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

let
  identity = {
    name = "Chenxin Yan";
    email = "yanchenxin2004@gmail.com";
  };
in
{
  imports = [ inputs.hunk.homeManagerModules.default ];

  options = {
    core.git.enable = lib.mkEnableOption "enables git version control and related tools";
  };

  config = lib.mkIf config.core.git.enable {

    programs.git = {
      enable = true;

      settings = {
        user = identity;

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
        difftool.prompt = false;
      };
    };

    # jj is used in colocated mode (.jj + .git side by side); run
    # `jj git init --colocate` per repo. Git tooling above keeps working.
    programs.jujutsu = {
      enable = true;
      settings = {
        user = identity;
        ui.default-command = "log";
        git.push-new-bookmarks = true;
      };
    };

    programs.jjui.enable = true;

    programs.difftastic = {
      enable = true;
      jujutsu.enable = true;
      git = {
        enable = true;
        mode = "difftool";
      };
    };

    programs.hunk = {
      enable = true;
      enableGitIntegration = true;
      settings.theme = "catppuccin-mocha";
    };

    # Hunk's bundled review skill belongs with the Hunk/Git module so it is
    # installed only when the tool it documents is enabled.
    home.file.".agents/skills/hunk-review" = {
      source = "${inputs.hunk.packages.${pkgs.stdenv.hostPlatform.system}.default}/skills/hunk-review";
      recursive = true;
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
        git.pagers = [
          { externalDiffCommand = "difft --color=always"; }
          { colorArg = "always"; }
        ];
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
        j = "jj";

        di = "hunk diff";
        dib = "hunk diff origin/HEAD...HEAD";
        dil = "hunk show";
        diw = "hunk diff --watch";
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
