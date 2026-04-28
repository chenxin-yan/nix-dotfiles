{
  lib,
  config,
  pkgs,
  ...
}:

# Kanata + Karabiner-DriverKit-VirtualHIDDevice (driver only, no GUI app).
#
# We replace the homebrew karabiner-elements cask with the standalone
# pkgs.karabiner-dk driver and run its VHID daemon ourselves via launchd.
# This drops the Karabiner-Elements GUI (which we never used) while
# keeping the virtual HID device that kanata needs.
#
# Refs:
#   - jtroo/kanata Discussion #1537 (canonical macOS launchd recipe)
#   - pqrs-org/Karabiner-DriverKit-VirtualHIDDevice README
#   - nix-darwin services/karabiner-elements (pattern we mirror)

let
  userHome = "/Users/${config.system.primaryUser}";
  karabinerDk = pkgs.karabiner-dk;

  # System extensions (.dext) cannot live in /nix/store and cannot be
  # symlinked — sysextd verifies the parent .app's filesystem path. We
  # copy the manager .app (which embeds the .dext) to a stable location
  # under /Applications. Mirrors nix-darwin's services.karabiner-elements
  # `parentAppDir` pattern.
  managerParentDir = "/Applications/.Nix-Karabiner-DriverKit";
  managerApp = "${managerParentDir}/.Karabiner-VirtualHIDDevice-Manager.app";
in
{
  options = {
    darwin.kanata.enable = lib.mkEnableOption "enables Kanata + Karabiner-DriverKit-VirtualHIDDevice";
  };

  config = lib.mkIf config.darwin.kanata.enable {
    environment.systemPackages = [
      pkgs.kanata
      karabinerDk
    ];

    # Copy the manager .app to /Applications so the embedded .dext can
    # be activated. preActivation runs early so the new bundle is in
    # place before launchd loads our daemons.
    system.activationScripts.preActivation.text = lib.mkAfter ''
      rm -rf ${managerParentDir}
      mkdir -p ${managerParentDir}
      cp -R "${karabinerDk}/Applications/.Karabiner-VirtualHIDDevice-Manager.app" ${managerParentDir}/
    '';

    launchd.daemons.kanata = {
      serviceConfig = {
        ProgramArguments = [
          "/run/current-system/sw/bin/kanata"
          "--cfg"
          "${userHome}/.config/kanata/kanata.kbd"
        ];
        KeepAlive = true;
        RunAtLoad = true;
        UserName = "root";
        StandardOutPath = "${userHome}/Library/Logs/kanata.log";
        StandardErrorPath = "${userHome}/Library/Logs/kanata.error.log";
      };
    };

    # Long-running VHID daemon. Label matches the one Karabiner-Elements
    # itself uses (verified via `launchctl print system/...` on a live
    # machine), so anything that looks for it by that name still works.
    # `command =` form auto-wraps with `/bin/sh -c "wait4path /nix/store
    # && exec ..."`.
    launchd.daemons.karabiner-vhiddaemon = {
      command = ''"${karabinerDk}/Library/Application Support/org.pqrs/Karabiner-DriverKit-VirtualHIDDevice/Applications/Karabiner-VirtualHIDDevice-Daemon.app/Contents/MacOS/Karabiner-VirtualHIDDevice-Daemon"'';
      serviceConfig = {
        Label = "org.pqrs.service.daemon.Karabiner-VirtualHIDDevice-Daemon";
        RunAtLoad = true;
        KeepAlive = true;
        ProcessType = "Interactive";
      };
    };

    # One-shot at boot: re-activate the system extension. Idempotent.
    # The manager `activate` subcommand exits once the dext is registered.
    launchd.daemons.karabiner-vhidmanager = {
      command = ''"${managerApp}/Contents/MacOS/Karabiner-VirtualHIDDevice-Manager" activate'';
      serviceConfig = {
        Label = "org.pqrs.service.daemon.Karabiner-VirtualHIDDevice-Manager";
        RunAtLoad = true;
      };
    };
  };
}
