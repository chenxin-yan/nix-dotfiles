{
  config,
  pkgs,
  lib,
  ...
}:

{
  options = {
    cli.jj.enable = lib.mkEnableOption "enables jj (jujutsu) version control system";
  };

  config = lib.mkIf config.cli.jj.enable {
    programs.jujutsu = {
      enable = true;
      settings = {
        user = {
          name = config.programs.git.settings.user.name;
          email = config.programs.git.settings.user.email;
        };

        # Catppuccin Mocha palette
        # https://catppuccin.com/palette/
        colors = {
          # core log labels
          "change_id" = {
            fg = "#cba6f7";
          }; # mauve
          "commit_id" = {
            fg = "#89b4fa";
          }; # blue
          "author" = {
            fg = "#f9e2af";
          }; # yellow
          "committer" = {
            fg = "#f9e2af";
          }; # yellow
          "timestamp" = {
            fg = "#94e2d5";
          }; # teal
          "bookmark" = {
            fg = "#a6e3a1";
            bold = true;
          }; # green
          "bookmarks" = {
            fg = "#a6e3a1";
            bold = true;
          };
          "local_bookmarks" = {
            fg = "#a6e3a1";
            bold = true;
          };
          "remote_bookmarks" = {
            fg = "#74c7ec";
          }; # sapphire
          "tags" = {
            fg = "#f5c2e7";
          }; # pink
          "working_copy" = {
            fg = "#cdd6f4";
            bold = true;
          }; # text
          "empty" = {
            fg = "#6c7086";
          }; # overlay0
          "description placeholder" = {
            fg = "#f38ba8";
            italic = true;
          }; # red
          "node" = {
            fg = "#f5c2e7";
            bold = true;
          }; # pink
          "elided" = {
            fg = "#6c7086";
          }; # overlay0
          "divergent" = {
            fg = "#f38ba8";
            bold = true;
          }; # red
          "conflict" = {
            fg = "#f38ba8";
            bold = true;
          }; # red
          "hidden" = {
            fg = "#6c7086";
          }; # overlay0

          # diff labels
          "diff added" = {
            fg = "#a6e3a1";
          }; # green
          "diff removed" = {
            fg = "#f38ba8";
          }; # red
          "diff modified" = {
            fg = "#f9e2af";
          }; # yellow
          "diff renamed" = {
            fg = "#74c7ec";
          }; # sapphire
          "diff copied" = {
            fg = "#94e2d5";
          }; # teal
          "diff token" = {
            underline = true;
          };
        };

        # lazyjj reads its theme from the jj config under `lazyjj.*`.
        # Only `highlight-color` is themable today; pick a catppuccin
        # surface color so the selected row is readable on mocha.
        lazyjj = {
          highlight-color = "#313244"; # surface0

          # Remap describe save from ctrl+s to ctrl+enter (more editor-like).
          keybinds.log_tab.save = "ctrl+enter";
        };

        # --- UI ---------------------------------------------------------
        # Bare `jj` shows the log instead of help.
        ui = {
          default-command = "log";
        };

        # --- Templates --------------------------------------------------
        # Show timestamps as "2 hours ago" in `jj log`.
        template-aliases = {
          "format_timestamp(timestamp)" = "timestamp.ago()";
        };

        # --- Workflow: `jj bookmark advance` defaults -------------------
        # `jj bookmark advance` (alias `jj b a`) moves the closest ancestor
        # bookmark forward. Target `@-` lands on the described commit, not
        # the empty working-copy commit.
        #
        # The `from` revset excludes `upstream`-remote bookmarks so the
        # fork+upstream workflow doesn't accidentally advance `main@upstream`
        # when you base work on multiple bookmarks (jj-vcs/jj#9079).
        revsets = {
          bookmark-advance-to = "@-";
          bookmark-advance-from = "heads(::to & bookmarks()) ~ remote_bookmarks(remote=exact:\"upstream\")";
        };

        # --- Remote bookmark tracking -----------------------------------
        # Auto-track every bookmark fetched from `origin` (your fork /
        # personal remote). For `upstream` (the repo you forked), only
        # auto-track `main` so contributors' WIP branches don't pollute
        # the local bookmark list. The `upstream` block is inert in repos
        # that don't have an `upstream` remote.
        remotes = {
          origin = {
            auto-track-bookmarks = "*";
          };
          upstream = {
            auto-track-bookmarks = "main";
          };
        };
      };
    };

    home.packages = with pkgs; [
      lazyjj
    ];

    programs.delta = {
      enable = true;
      enableJujutsuIntegration = true;
    };

    programs.zsh = {
      shellAliases = {
        j = "jj";
        lj = "lazyjj";
        jc = "jj commit -m";
        jn = "jj new";
        jr = "jj rebase";
        js = "jj squash";
        jR = "jj restore";
        ja = "jj abandon";
        jgP = "jj git push";
        jgp = "jj git fetch";
        jba = "jj bookmark advance";
        jbs = "jj bookmark set";
        jbl = "jj bookmark list";
        jbd = "jj bookmark delete";
        je = "jj edit";
      };
    };
  };
}
