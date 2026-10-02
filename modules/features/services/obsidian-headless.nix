# Continuous Obsidian Sync of the Atlas vault into atlasPath, hence the paths
# include. Signed in and linked from secrets, so no manual setup. Obsidian
# allows one sync method per device: not on machines running the desktop
# app's Sync.
{ config, ... }:
{
  features.obsidian-headless = {
    includes = [
      config.features.paths
      config.features.secrets
    ];

    nixos =
      { host, ... }:
      {
        # `ob login`'s session token (the contents of its auth_token file),
        # and the vault's end-to-end encryption password.
        sops.secrets.obsidian-auth-token.owner = host.login;
        sops.secrets.obsidian-vault-password.owner = host.login;
      };

    homeManager =
      {
        config,
        lib,
        osConfig,
        pkgs,
        ...
      }:
      let
        secret = name: osConfig.sops.secrets.${name}.path;
        ob = "${pkgs.obsidian-headless}/bin/ob";
        # OBSIDIAN_AUTH_TOKEN is read by ob (checked before its auth_token
        # file) but undocumented; recheck it when obsidian-headless updates.
        sync = pkgs.writeShellScript "atlas-sync" ''
          set -eu
          OBSIDIAN_AUTH_TOKEN=$(cat ${secret "obsidian-auth-token"})
          export OBSIDIAN_AUTH_TOKEN
          vault=${lib.escapeShellArg config.atlasPath}
          mkdir -p "$vault"
          # Link once; after a new remote vault, `ob sync-unlink` relinks it.
          # Without --password, ob reads it from non-TTY stdin (trailing
          # whitespace trimmed), which keeps it out of the process's argv.
          if ! ${ob} sync-status --path "$vault" --json >/dev/null 2>&1; then
            ${ob} sync-setup --vault atlas --path "$vault" \
              --device-name ${lib.escapeShellArg osConfig.networking.hostName} \
              < ${secret "obsidian-vault-password"}
          fi
          exec ${ob} sync --path "$vault" --continuous
        '';
      in
      {
        home.packages = [ pkgs.obsidian-headless ];

        systemd.user.services.atlas-sync = {
          Unit = {
            Description = "Obsidian Sync for the Atlas vault";
            # A rotated token only reaches the service on restart.
            X-Restart-Triggers = [ osConfig.sops.secrets.obsidian-auth-token.sopsFileHash ];
          };
          Service = {
            ExecStart = "${sync}";
            Restart = "on-failure";
            RestartSec = 30;
          };
          Install.WantedBy = [ "default.target" ];
        };
      };
  };
}
