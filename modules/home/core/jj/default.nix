{
  config,
  lib,
  ...
}:

{
  options = {
    core.jj.enable = lib.mkEnableOption "enables jujutsu version control and related tools";
  };

  config = lib.mkIf config.core.jj.enable {
    # jj is used in colocated mode (.jj + .git side by side); run
    # `jj git init --colocate` per repo. Git tooling keeps working.
    programs.jujutsu = {
      enable = true;
      settings = {
        # Identity lives in the git module; requires core.git.enable.
        user = config.programs.git.settings.user;
        ui.default-command = "log";
        git.push-new-bookmarks = true;
      };
    };

    programs.jjui.enable = true;

    programs.difftastic = {
      enable = true;
      jujutsu.enable = true;
    };

    programs.zsh.shellAliases.j = "jj";
  };
}
