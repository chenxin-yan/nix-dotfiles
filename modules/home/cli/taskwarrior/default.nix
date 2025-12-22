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

        # ============================================
        # Catppuccin Mocha Color Theme
        # ============================================
        # Using 256-color approximations for compatibility
        # Mocha palette reference:
        #   Base: #1e1e2e, Surface0: #313244, Surface1: #45475a, Surface2: #585b70
        #   Overlay0: #6c7086, Overlay1: #7f849c, Overlay2: #9399b2
        #   Text: #cdd6f4, Subtext0: #a6adc8, Subtext1: #bac2de
        #   Red: #f38ba8, Maroon: #eba0ac, Peach: #fab387, Yellow: #f9e2af
        #   Green: #a6e3a1, Teal: #94e2d5, Sky: #89dceb, Sapphire: #74c7ec
        #   Blue: #89b4fa, Lavender: #b4befe, Mauve: #cba6f7, Pink: #f5c2e7

        # General UI colors
        color = "on";
        "color.label" = "color117"; # Sky - for labels
        "color.label.sort" = "color117";
        "color.alternate" = "on color236"; # Surface0 - alternating row background
        "color.header" = "color117"; # Sky - header text
        "color.footnote" = "color80"; # Sapphire - footnote text
        "color.warning" = "color222"; # Yellow - warnings
        "color.error" = "color210"; # Red - errors
        "color.debug" = "color141"; # Mauve - debug info

        # Task state colors
        "color.completed" = "color151"; # Green - completed tasks
        "color.deleted" = "color243"; # Overlay0 - deleted tasks
        "color.active" = "color111"; # Blue - active/started tasks
        "color.recurring" = "color111"; # Blue - recurring tasks
        "color.scheduled" = "color116"; # Teal - scheduled tasks
        "color.until" = "color243"; # Overlay0 - until date
        "color.blocked" = "color246"; # Overlay1 - blocked tasks
        "color.blocking" = "color141"; # Mauve - blocking tasks

        # Due date colors
        "color.due" = "color222"; # Yellow - due tasks
        "color.due.today" = "color217"; # Maroon - due today
        "color.overdue" = "color210"; # Red - overdue tasks

        # Priority colors (heat-map style: H=hot, L=cool)
        # Note: priority is a UDA in Taskwarrior 3, so we use color.uda.priority.*
        "color.uda.priority.H" = "color216"; # Peach - high priority
        "color.uda.priority.M" = "color222"; # Yellow - medium priority
        "color.uda.priority.L" = "color116"; # Teal - low priority

        # Color rule precedence - uda. must come before tag./project. to show priority colors
        "rule.precedence.color" =
          "deleted,completed,active,keyword.,uda.,tag.,project.,overdue,scheduled,due.today,due,blocked,blocking,recurring,tagged";

        # Tag colors
        "color.tagged" = "color218"; # Pink - tagged tasks
        "color.tag.next" = "color216"; # Peach - next tag
        "color.tag.none" = "";
        "color.project.none" = "";

        # Calendar colors
        "color.calendar.today" = "color111 on color236"; # Blue on Surface0
        "color.calendar.due" = "color222 on color236"; # Yellow on Surface0
        "color.calendar.due.today" = "color217 on color236"; # Maroon on Surface0
        "color.calendar.overdue" = "color210 on color236"; # Red on Surface0
        "color.calendar.holiday" = "color216 on color236"; # Peach on Surface0
        "color.calendar.scheduled" = "color116 on color236"; # Teal on Surface0
        "color.calendar.weekend" = "color243 on color236"; # Overlay0 on Surface0
        "color.calendar.weeknumber" = "color80"; # Sapphire

        # Burndown chart colors
        "color.burndown.pending" = "on color210"; # Red background
        "color.burndown.started" = "on color222"; # Yellow background
        "color.burndown.done" = "on color151"; # Green background

        # History report colors
        "color.history.add" = "color0 on color151"; # Black on Green
        "color.history.done" = "color0 on color111"; # Black on Blue
        "color.history.delete" = "color0 on color210"; # Black on Red

        # Sync colors
        "color.sync.added" = "color151"; # Green
        "color.sync.changed" = "color222"; # Yellow
        "color.sync.rejected" = "color210"; # Red

        # Undo colors
        "color.undo.before" = "color210"; # Red - before change
        "color.undo.after" = "color151"; # Green - after change

        # Summary colors
        "color.summary.bar" = "black on color111"; # Black on Blue
        "color.summary.background" = "white on color236"; # White on Surface0

        report.next.columns = "id,start.age,depends.indicator,priority,project,tags,recur.indicator,scheduled.countdown,due,until.remaining,description,urgency";
        report.next.labels = "ID,Active,D,P,Project,Tags,R,Sch,Due,Until,Description,Urg";
        report.next.filter = "status:pending -WAITING -someday limit:page";

        # Custom inbox report for tasks without a project
        report.inbox.description = "Tasks without a project";
        report.inbox.columns = "id,start.age,priority,tags,due,description";
        report.inbox.labels = "ID,Active,P,Tags,Due,Description";
        report.inbox.filter = "status:pending project: tags:";

        # Custom ddl report for tasks due within 2 weeks
        report.ddl.description = "Tasks due within 2 weeks";
        report.ddl.columns = "id,start.age,priority,project,tags,due.relative,description,urgency";
        report.ddl.labels = "ID,Active,P,Project,Tags,Due,Description,Urg";
        report.ddl.filter = "status:pending due.before:2weeks";
        report.ddl.sort = "due+";

        # Custom today report for tasks due/scheduled today or before, or tagged as next
        report.today.description = "Tasks for today";
        report.today.columns = "id,start.age,priority,project,tags,due.relative,scheduled.relative,description,urgency";
        report.today.labels = "ID,Active,P,Project,Tags,Due,Scheduled,Description,Urg";
        report.today.filter = "status:pending ( due.before:tomorrow or scheduled.before:tomorrow or +next )";
        report.today.sort = "urgency-";

        # Urgency coefficients
        urgency.user.tag.someday.coefficient = "-20.0";
      };
    };

    programs.zsh = {
      shellAliases = {
        t = "task";
        tw = "taskwarrior-tui";
        ti = "taskwarrior-tui --report inbox";
      };
    };
  };
}
