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
          "raspberry-pi" = {
            id = "6IKQFQ3-YQWC5MP-V7BOK6A-UP65HUU-DQWZRK5-LYAG3XP-7EEICGF-J624PAT";
          };
        };

        folders = {
          "dev" = {
            path = "~/dev";
            devices = [
              "macbook"
              "nixos"
            ];
            ignorePerms = true;
          };
          "PARA" = {
            path = "~/PARA";
            devices = [
              "macbook"
              "raspberry-pi"
            ];
            ignorePerms = true;
          };
        };
      };
    };

    # Create .stignore for dev sync exclusions
    home.file = {
      "PARA/.stignore".text = ''
        (?d).DS_Store
        (?d).Spotlight-V100
        (?d).Trashes
        (?d)._*
      '';
      "dev/.stignore".text = ''
        (?d).DS_Store
        (?d)node_modules
        (?d)worktrees
        (?d)**/.git/worktrees
        (?d).git
        (?d)__pycache__
        (?d).pytest_cache
        (?d).mypy_cache
        (?d).ruff_cache
        (?d).tox
        (?d).venv
        (?d)venv
        (?d).next
        (?d).nuxt
        (?d).svelte-kit
        (?d).turbo
        (?d).parcel-cache
        (?d).vite
        (?d).cache
        (?d)dist
        (?d)build
        (?d)out
        (?d)coverage
        (?d).coverage
        (?d)target
        (?d).gradle
        (?d).idea
        (?d).direnv
        (?d).wrangler
        (?d)*.egg-info
        (?d).eslintcache
        (?d).output
      '';
    };
  };
}
