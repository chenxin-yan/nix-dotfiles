{
  config,
  pkgs,
  lib,
  ...
}:

{
  options = {
    cli.taskwarrior.enable = lib.mkEnableOption "enables taskwarrior";
  };

  config = lib.mkIf config.cli.taskwarrior.enable {
    home.packages = with pkgs; [
      taskwarrior-tui
      tasksh
    ];

    programs.taskwarrior = {
      enable = true;
      package = pkgs.taskwarrior3;

      dataLocation = "${config.home.homeDirectory}/.task";

      config = {
        news.version = "3.4.2";

        # Catppuccin Mocha theme
        # Based on https://github.com/catppuccin/catppuccin
        color = {
          # General UI colors
          header = "color116"; # Text (cdd6f4)
          footnote = "color116"; # Text
          warning = "color229"; # Yellow (f9e2af)
          error = "color210"; # Red (f38ba8)
          debug = "color159"; # Sky (89dceb)

          # Task colors
          "due.today" = "color210"; # Red
          due = "color229"; # Yellow
          active = "color117"; # Blue (89b4fa)
          scheduled = "color159"; # Sky
          "tag.next" = "color180"; # Lavender (b4befe)
          blocked = "color243"; # Overlay0 (6c7086)
          blocking = "color210"; # Red
          overdue = "color210"; # Red

          # Priority colors
          "uda.priority.H" = "color210"; # Red
          "uda.priority.M" = "color229"; # Yellow
          "uda.priority.L" = "color116"; # Text

          # Project colors
          "project.none" = "";

          # Tag colors
          "tag.none" = "";
          tagged = "color180"; # Lavender

          # Completed/deleted tasks
          completed = "color150"; # Green (a6e3a1)
          deleted = "color243"; # Overlay0

          # Recurring tasks
          recurring = "color117"; # Blue

          # Calendar
          "calendar.due.today" = "color210 on color235"; # Red on Base
          "calendar.due" = "color229 on color235"; # Yellow on Base
          "calendar.overdue" = "color210 on color235"; # Red on Base
          "calendar.weekend" = "color243 on color234"; # Overlay0 on Mantle
          "calendar.holiday" = "color180 on color234"; # Lavender on Mantle
          "calendar.today" = "color117 on color235"; # Blue on Base

          # Alternating task colors
          "alternate" = "on color234"; # Mantle (181825)
        };
      };
    };

    programs.zsh = {
      shellAliases = {
        t = "task";
        tw = "taskwarrior-tui";
      };
    };
  };
}
