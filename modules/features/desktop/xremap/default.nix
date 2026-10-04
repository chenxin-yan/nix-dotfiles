# xremap translates Mac shortcut habits into Linux ones (Super+C → Ctrl+C,
# skipping terminals), following the focused app through niri's IPC. It sits
# above kanata: kanata's virtual keyboard and every external keyboard pass
# through it. Linux only.
#
# Two instances, because xremap's virtual keyboard copies the bus of the first
# keyboard it grabs, and libinput takes a PS/2-bus keyboard for the built-in
# one. Any key from a "built-in" keyboard while the lid is closed makes
# libinput report the lid open, so with one instance typing on the Voyager
# woke the closed laptop panel. Kanata (PS/2, like the real keyboard) keeps
# its own instance, which keeps the touchpad's disable-while-typing; the
# external one comes out as USB. One instance will do if xremap gains a way
# to set the output bus.
{ config, ... }:
{
  features.xremap.includes = with config.features; [ paths ];

  features.xremap.nixos =
    { host, ... }:
    {
      # Read keyboards and create the remapped one as the login user. That
      # user's processes can also read keystrokes; xremap's documented
      # trade-off for following the focused window from the user session.
      hardware.uinput.enable = true;
      users.users.${host.login}.extraGroups = [
        "input"
        "uinput"
      ];
    };

  features.xremap.homeManager =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      service = description: devices: {
        Unit = {
          Description = "xremap: Mac-style shortcuts in Linux apps (${description})";
          PartOf = [ "graphical-session.target" ];
          After = [ "graphical-session.target" ];
        };
        Service = {
          ExecStart = lib.escapeShellArgs (
            [
              (lib.getExe pkgs.xremap.niri)
              "--watch=config,device"
            ]
            ++ devices
            ++ [
              # The checkout file itself, not a ~/.config symlink: xremap watches
              # the file's directory, and editors replace the file on save.
              "${config.dotfiles}/modules/features/desktop/xremap/config.yml"
            ]
          );
          Restart = "on-failure";
        };
        Install.WantedBy = [ "graphical-session.target" ];
      };
    in
    lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
      systemd.user.services.xremap = service "built-in keyboard" [ "--device=kanata" ];
      systemd.user.services.xremap-external = service "external keyboards" [
        # kanata owns the built-in keyboard (kanata feature); xremap only
        # skips it while kanata holds the grab, so make that permanent.
        "--ignore=AT Translated Set 2 keyboard"
        "--ignore=kanata"
        # The other instance's virtual keyboard (names contain "xremap").
        "--ignore=xremap"
      ];
    };
}
