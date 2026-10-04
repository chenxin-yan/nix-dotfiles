# Switch to whatever is pushed to main, nightly, with no login involved.
# Builds the committed flake.lock as-is; `just update` + push is still how
# inputs move. Local uncommitted switches get reverted by the next run.
# Reads the home `dotfiles` option, hence the paths include.
{ config, ... }:
{
  features.auto-upgrade = {
    includes = [ config.features.paths ];

    nixos =
      {
        config,
        host,
        pkgs,
        ...
      }:
      let
        user = config.users.users.${host.login};
        dotfiles = config.home-manager.users.${host.login}.dotfiles;
      in
      {
        system.autoUpgrade = {
          enable = true;
          flake = "github:chenxin-yan/nix-dotfiles";
          # --upgrade is for channels; a flake upgrade honours its lock file.
          upgrade = false;
        };

        # Keep the checkout in step too: linked configs (nvim, zsh scripts)
        # read it, not the store. HTTPS because the repo is public and this
        # runs with no SSH agent; insteadOf keeps origin's tracking refs
        # updating. A failed pull (diverged, conflicting edits) never blocks
        # the upgrade.
        systemd.services.nixos-upgrade.preStart = ''
          ${pkgs.util-linux}/bin/runuser -u ${host.login} -- env HOME=${user.home} \
            git -C ${dotfiles} -c url.https://github.com/.insteadOf=git@github.com: \
            pull --ff-only --quiet \
            || echo "auto-upgrade: pulling ${dotfiles} failed; left as-is" >&2
        '';
      };
  };
}
