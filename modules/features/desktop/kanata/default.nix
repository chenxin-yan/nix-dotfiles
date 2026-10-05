# Kanata on the built-in laptop keyboards; ./layout.kbd is shared, each OS
# adds its own defcfg. The Voyager is left alone: it runs its layout in
# firmware.
#
# macOS: Kanata + Karabiner-DriverKit-VirtualHIDDevice (driver only, no GUI app).
#
# We replace the homebrew karabiner-elements cask with the karabiner-dk
# driver and run its VHID daemon ourselves via launchd.
# This drops the Karabiner-Elements GUI (which we never used) while
# keeping the virtual HID device that kanata needs. The daemon reads the
# keymap that the Home Manager half links into ~/.config/kanata.
#
# Refs:
#   - jtroo/kanata Discussion #1537 (canonical macOS launchd recipe)
#   - pqrs-org/Karabiner-DriverKit-VirtualHIDDevice README
#   - nix-darwin services/karabiner-elements (pattern we mirror)
#   - https://nick-liu.com/posts/tcc-cdhash-trap/ (why kanata is re-signed)
let
  # 65 ms matches the Voyager's Flow Tap.
  sharedDefcfg = ''
    process-unmapped-keys yes
    tap-hold-require-prior-idle 65
  '';
in
{
  features.kanata.darwin =
    {
      lib,
      config,
      pkgs,
      ...
    }:
    let
      userHome = "/Users/${config.system.primaryUser}";
      # The driver version kanata is built against; a newer standalone
      # karabiner-dk isn't guaranteed to speak the same IPC.
      karabinerDk = pkgs.kanata.darwinDriver;

      # System extensions (.dext) cannot live in /nix/store and cannot be
      # symlinked — sysextd verifies the parent .app's filesystem path. We
      # copy the manager .app (which embeds the .dext) to a stable location
      # under /Applications. Mirrors nix-darwin's services.karabiner-elements
      # `parentAppDir` pattern.
      managerParentDir = "/Applications/.Nix-Karabiner-DriverKit";
      managerApp = "${managerParentDir}/.Karabiner-VirtualHIDDevice-Manager.app";

      # TCC pins Input Monitoring + Accessibility grants to a path and a
      # code-signing requirement. Nix's ad-hoc signature makes that
      # requirement the binary's cdhash, which changes on every rebuild. We
      # run kanata from a fixed path, re-signed with a host-local
      # self-signed key, so the requirement becomes `identifier
      # "org.nixos.kanata" and certificate root = H"…"` and survives updates.
      # Grant both permissions to `stableKanata` once per machine (again
      # only if `signingDir` is lost); steps in README → macOS permissions.
      kanataExe = lib.getExe pkgs.kanata;
      stableKanata = "/usr/local/libexec/nix-kanata/kanata";
      signingDir = "/var/db/nix-kanata";
    in
    {
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

        if [ ! -s ${signingDir}/key.pem ]; then
          install -d -m 0700 ${signingDir}
          # Code signing rejects certs without keyUsage=digitalSignature.
          ${lib.getExe pkgs.openssl} req -x509 -newkey rsa:2048 -nodes -days 36500 \
            -subj "/CN=nix-kanata-codesign" \
            -addext "keyUsage=critical,digitalSignature" \
            -addext "extendedKeyUsage=critical,codeSigning" \
            -keyout ${signingDir}/key.pem -out ${signingDir}/cert.pem 2>/dev/null
          chmod 0600 ${signingDir}/key.pem
        fi
        mkdir -p "$(dirname ${stableKanata})"
        install -m 0755 ${kanataExe} ${stableKanata}.new
        # rcodesign logs to stderr on success; surface it only on failure.
        # No timestamp server, so activation works offline.
        out=$(${lib.getExe pkgs.rcodesign} sign --timestamp-url none \
          --pem-file ${signingDir}/key.pem --pem-file ${signingDir}/cert.pem \
          --binary-identifier org.nixos.kanata ${stableKanata}.new 2>&1) \
          || { echo "$out" >&2; exit 1; }
        mv -f ${stableKanata}.new ${stableKanata}
      '';

      launchd.daemons.kanata = {
        serviceConfig = {
          ProgramArguments = [
            stableKanata
            "--cfg"
            "${userHome}/.config/kanata/kanata.kbd"
          ];
          KeepAlive = true;
          RunAtLoad = true;
          UserName = "root";
          StandardOutPath = "${userHome}/Library/Logs/kanata.log";
          StandardErrorPath = "${userHome}/Library/Logs/kanata.error.log";
          # Unused by kanata: it changes the plist whenever the package does,
          # so activation restarts the daemon onto the new binary.
          EnvironmentVariables.KANATA_STORE_PATH = kanataExe;
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

  features.kanata.homeManager =
    { pkgs, lib, ... }:
    lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
      # Product name of every MacBook's built-in keyboard (`kanata --list`).
      xdg.configFile."kanata/kanata.kbd".text = ''
        (defcfg
          ${sharedDefcfg}
          macos-dev-names-include ("Apple Internal Keyboard / Trackpad"))
      ''
      + builtins.readFile ./layout.kbd;
    };

  features.kanata.nixos = {
    services.kanata = {
      enable = true;
      keyboards.internal = {
        # The kernel's atkbd driver names a laptop's built-in (i8042)
        # keyboard this, so external keyboards are never grabbed.
        extraDefCfg = sharedDefcfg + ''
          linux-dev-names-include ("AT Translated Set 2 keyboard")
        '';
        config = builtins.readFile ./layout.kbd;
      };
    };
  };
}
