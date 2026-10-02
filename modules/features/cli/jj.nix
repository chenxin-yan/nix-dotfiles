{
  features.jj.homeManager =
    { config, ... }:
    {
      # jj is used in colocated mode (.jj + .git side by side); run
      # `jj git init --colocate` per repo. Git tooling keeps working.
      programs.jujutsu = {
        enable = true;
        settings = {
          # Identity lives in the git module; requires core.git.enable.
          user = config.programs.git.settings.user;
          ui.default-command = "log";
          # Locally created bookmarks track origin, so they push without
          # `jj bookmark track`.
          remotes.origin.auto-track-created-bookmarks = "*";
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
