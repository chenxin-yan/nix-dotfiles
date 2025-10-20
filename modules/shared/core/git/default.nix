{ config, pkgs, ... }:

{
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

  programs.lazygit.enable = true;

  programs.zsh = {
    shellAliases = {
      g = "git";
      G = "lazygit";
    };
  };

}
