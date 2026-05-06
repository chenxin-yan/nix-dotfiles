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
          "change_id" = { fg = "#cba6f7"; }; # mauve
          "commit_id" = { fg = "#89b4fa"; }; # blue
          "author" = { fg = "#f9e2af"; }; # yellow
          "committer" = { fg = "#f9e2af"; }; # yellow
          "timestamp" = { fg = "#94e2d5"; }; # teal
          "bookmark" = { fg = "#a6e3a1"; bold = true; }; # green
          "bookmarks" = { fg = "#a6e3a1"; bold = true; };
          "local_bookmarks" = { fg = "#a6e3a1"; bold = true; };
          "remote_bookmarks" = { fg = "#74c7ec"; }; # sapphire
          "tags" = { fg = "#f5c2e7"; }; # pink
          "working_copy" = { fg = "#cdd6f4"; bold = true; }; # text
          "empty" = { fg = "#6c7086"; }; # overlay0
          "description placeholder" = { fg = "#f38ba8"; italic = true; }; # red
          "description" = { fg = "#cdd6f4"; }; # text
          "node" = { fg = "#f5c2e7"; bold = true; }; # pink
          "elided" = { fg = "#6c7086"; }; # overlay0
          "divergent" = { fg = "#f38ba8"; bold = true; }; # red
          "conflict" = { fg = "#f38ba8"; bold = true; }; # red
          "hidden" = { fg = "#6c7086"; }; # overlay0

          # diff labels
          "diff added" = { fg = "#a6e3a1"; }; # green
          "diff removed" = { fg = "#f38ba8"; }; # red
          "diff modified" = { fg = "#f9e2af"; }; # yellow
          "diff renamed" = { fg = "#74c7ec"; }; # sapphire
          "diff copied" = { fg = "#94e2d5"; }; # teal
          "diff token" = { underline = true; };
        };

        # lazyjj reads its theme from the jj config under `lazyjj.*`.
        # Only `highlight-color` is themable today; pick a catppuccin
        # surface color so the selected row is readable on mocha.
        lazyjj = {
          highlight-color = "#313244"; # surface0
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
      };
    };
  };
}
