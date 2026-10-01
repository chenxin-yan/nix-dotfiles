# Continuous Obsidian Sync of the Atlas vault into atlasPath, hence the paths
# include. Enrol once by hand (`ob login`, then
# `ob sync-setup --vault Atlas --path "$ATLAS_PATH"`) and start the unit;
# until then it stays idle.
{ config, ... }:
{
  features.obsidian-headless = {
    includes = [ config.features.paths ];

    homeManager =
      { config, pkgs, ... }:
      {
        home.packages = [ pkgs.obsidian-headless ];

        systemd.user.services.atlas-sync = {
          Unit = {
            Description = "Obsidian Sync for the Atlas vault";
            ConditionDirectoryNotEmpty = "${config.xdg.configHome}/obsidian-headless/sync";
          };
          Service = {
            ExecStart = "${pkgs.obsidian-headless}/bin/ob sync --continuous";
            WorkingDirectory = config.atlasPath;
            Restart = "on-failure";
            RestartSec = 30;
          };
          Install.WantedBy = [ "default.target" ];
        };
      };
  };
}
