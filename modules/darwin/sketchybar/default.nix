{
  lib,
  config,
  pkgs,
  ...
}:

# Stable launchd wrapper for sketchybar. nix-darwin's services.sketchybar
# points ProgramArguments[0] at /nix/store/<hash>-sketchybar/bin/sketchybar
# directly; that path moves on every rebuild that bumps the closure, which
# can invalidate the macOS Background Task Management ("Allow in the
# Background") approval. We install a fixed-content wrapper script at
# /usr/local/libexec/nix-darwin/sketchybar-wrapper and force the agent to
# call it.
#
# Refs: nix-darwin#1219 (tracker), #1660, #1678, LnL7/nix-darwin#558.

let
  # Use a literal `/bin/sh` shebang (Apple-shipped, never moves) so the
  # wrapper file's content hash is fully stable across rebuilds. Using
  # pkgs.writeShellScript would embed /nix/store/<bash-hash> in the
  # shebang and churn the content on every bash version bump.
  wrapper = pkgs.writeText "sketchybar-wrapper" ''
    #!/bin/sh
    /bin/wait4path /nix/store
    exec /run/current-system/sw/bin/sketchybar "$@"
  '';
in
{
  options = {
    darwin.sketchybar.enable = lib.mkEnableOption "enables sketchybar with a stable launchd wrapper";
  };

  config = lib.mkIf config.darwin.sketchybar.enable {
    services.sketchybar.enable = true;

    # Install the wrapper before `userLaunchd` runs: nix-darwin loads
    # user LaunchAgents during the `userLaunchd` activation slot, and the
    # sketchybar agent has `RunAtLoad = true`, so the executable must
    # already exist when that plist is loaded.
    system.activationScripts.launchd.text = lib.mkAfter ''
      mkdir -p /usr/local/libexec/nix-darwin
      install -m0555 ${wrapper} /usr/local/libexec/nix-darwin/sketchybar-wrapper
    '';

    # Override the LaunchAgent's ProgramArguments to point at the stable
    # wrapper. This drops upstream's `--config ${configFile}` arg branch,
    # which is harmless here because `services.sketchybar.config` is empty
    # (config files are managed via xdg.configFile in home-manager).
    launchd.user.agents.sketchybar.serviceConfig.ProgramArguments = lib.mkForce [
      "/usr/local/libexec/nix-darwin/sketchybar-wrapper"
    ];
  };
}
