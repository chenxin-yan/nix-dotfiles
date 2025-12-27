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

      settings = {
        options = {
          urAccepted = -1;
          localAnnounceEnabled = true;
        };

        devices = {
          "macbook" = {
            id = "VVPBX7E-COCNGXP-WASVT2N-HU4M2C2-N3E7MZT-LZQMA2R-T7EF55R-WFADDQM";
          };
          "nixos" = {
            id = "A7ARLLU-2SID46Y-XVXR2KS-UX4H5RY-OGWNAUK-ZHPQN5E-SG5DPEH-G76JUAH";
          };
        };

        folders = {
          "dev" = {
            path = "~/dev";
            devices = [
              "macbook"
              "nixos"
            ];
            ignorePerms = false;
          };
          "notes" = {
            path = "~/notes";
            devices = [
              "macbook"
              "nixos"
            ];
            ignorePerms = false;
          };
        };
      };
    };

    # Create .stignore files to exclude .DS_Store and node_modules
    home.file = {
      "dev/.stignore".text = ''
        .DS_Store
        node_modules
      '';
      "notes/.stignore".text = ''
        .DS_Store
      '';
    };
  };
}
