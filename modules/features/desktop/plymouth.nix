# A themed splash from firmware logo to login screen, with the kernel and
# systemd quiet underneath (Esc shows the log). catppuccin/nix picks the
# theme; a disk passphrase prompt, if the TPM refuses, appears in it too.
{
  features.plymouth.nixos = {
    boot.plymouth.enable = true;
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
