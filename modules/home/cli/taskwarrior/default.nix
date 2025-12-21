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
        urgency.user.tag.someday.coefficient = "-10.0";
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
