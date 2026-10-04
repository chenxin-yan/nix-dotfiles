# Keep the kernel and systemd quiet during boot, so the screen goes from the
# firmware logo to the login screen without a scrolling log.
{
  features.quiet-boot.nixos = {
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
