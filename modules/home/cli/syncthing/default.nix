{
  config,
  pkgs,
  lib,
  ...
}:

{
  options = {
    cli.syncthing.enable = lib.mkEnableOption "enables syncthing file synchronization";
  };

  config = lib.mkIf config.cli.syncthing.enable {
    services.syncthing = {
      enable = true;

      overrideDevices = true;
      overrideFolders = true;

      # Global settings
      settings = {
        options = {
          # Disable usage reporting
          urAccepted = -1;
          # Enable local discovery
          localAnnounceEnabled = true;
        };
      };

      # Uncomment and configure devices when you have device IDs
      # settings.devices = {
      #   "macbook" = {
      #     id = "XXXXXXX-XXXXXXX-XXXXXXX-XXXXXXX-XXXXXXX-XXXXXXX-XXXXXXX-XXXXXXX";
      #   };
      #   "nixos-desktop" = {
      #     id = "XXXXXXX-XXXXXXX-XXXXXXX-XXXXXXX-XXXXXXX-XXXXXXX-XXXXXXX-XXXXXXX";
      #   };
      # };

      # Uncomment and configure folders to sync
      # settings.folders = {
      #   "Documents" = {
      #     path = "~/Documents";
      #     devices = [ "macbook" "nixos-desktop" ];
      #   };
      #   "Notes" = {
      #     path = "~/Notes";
      #     devices = [ "macbook" "nixos-desktop" ];
      #   };
      # };
    };
  };
}
