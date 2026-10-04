# A splash from firmware logo to login screen, with the kernel and systemd
# quiet underneath (Esc shows the log). A disk passphrase prompt, if the TPM
# refuses, appears in it too.
{
  features.plymouth.nixos =
    { pkgs, ... }:
    {
      boot.plymouth = {
        enable = true;
        # adi1090x's quiet dot shimmer; catppuccin/nix's theme felt heavy.
        theme = "hexagon_dots";
        themePackages = [
          (pkgs.adi1090x-plymouth-themes.override { selected_themes = [ "hexagon_dots" ]; })
        ];
      };
      catppuccin.plymouth.enable = false;

      boot.consoleLogLevel = 3;
      boot.initrd.verbose = false;
      boot.kernelParams = [
        "quiet"
        "udev.log_level=3"
        "rd.udev.log_level=3"
        "systemd.show_status=auto"
        "rd.systemd.show_status=auto"
      ];
    };
}
