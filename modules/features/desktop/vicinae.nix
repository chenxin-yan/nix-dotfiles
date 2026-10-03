# Vicinae, a Raycast-style launcher (Raycast extensions, clipboard history,
# file search) on Super+Space, the Mac's Cmd+Space. Linux only: the Mac keeps
# Raycast. catppuccin/nix themes it.
{
  features.vicinae.homeManager =
    { lib, pkgs, ... }:
    lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
      programs.vicinae = {
        enable = true;
        systemd.enable = true;
        settings.font.normal.family = "system";
      };
    };
}
