# xremap translates Mac shortcut habits into Linux ones (Super+C → Ctrl+C,
# skipping terminals), following the focused app through niri's IPC. It sits
# above kanata: it grabs every keyboard except the built-in one, so the
# Voyager and kanata's own virtual keyboard both pass through it. Linux only.
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
    lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
      systemd.user.services.xremap = {
        Unit = {
          Description = "xremap: Mac-style shortcuts in Linux apps";
          PartOf = [ "graphical-session.target" ];
          After = [ "graphical-session.target" ];
        };
        Service = {
          ExecStart = lib.escapeShellArgs [
            (lib.getExe pkgs.xremap.niri)
            "--watch=config,device"
            # kanata owns the built-in keyboard (kanata feature); xremap only
            # skips it while kanata holds the grab, so make that permanent.
            "--ignore=AT Translated Set 2 keyboard"
            # The checkout file itself, not a ~/.config symlink: xremap watches
            # the file's directory, and editors replace the file on save.
            "${config.dotfiles}/modules/features/desktop/xremap/config.yml"
          ];
          Restart = "on-failure";
        };
        Install.WantedBy = [ "graphical-session.target" ];
      };
    };
}
