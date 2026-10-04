# Noctalia, the desktop shell (bar, notifications, lock screen, idle, OSD,
# polkit prompts) and its matching greetd login screen. Its TOML config is
# linked from the checkout and hot-reloads. Changes made in Noctalia's settings
# window land in ~/.local/state/noctalia/settings.toml instead; keep the ones
# you like by copying them from `noctalia config export` into config/.
{ config, ... }:
{
  features.noctalia.includes = with config.features; [ paths ];

  features.noctalia.nixos =
    { host, pkgs, ... }:
    {
      programs.noctalia = {
        enable = true;
        systemd.enable = true;
        # NetworkManager, Bluetooth, UPower and power-profiles-daemon, which
        # back the bar's widgets.
        recommendedServices.enable = true;
      };

      services.displayManager.noctalia-greeter = {
        enable = true;
        # Lets the shell copy its wallpaper and palette to the login screen
        # without a password prompt ([shell.greeter_sync] in config.toml).
        passwordlessSyncUsers = [ host.login ];
        # The desktop's cursor (niri/default.nix), not the greeter's default.
        cursorTheme = {
          package = pkgs.catppuccin-cursors.mochaLavender;
          name = "catppuccin-mocha-lavender-cursors";
        };
        # Sync brings the wallpaper and palette; these trim the rest to the
        # clock and the password box, like the lock screen.
        settings = {
          appearance = {
            hide_logo = true;
            scheme_selector_position = "hidden";
          };
          clock = {
            time_format = "{:%-I:%M}";
            date_format = "%A, %B %-d";
          };
        };
      };

      # Noctalia's lock screen authenticates against the login stack and drives
      # the fingerprint reader itself over D-Bus; pam_fprintd in that stack
      # would fight it for the sensor. greetd reuses the login stack, so logging
      # in takes the password, which also unlocks the keyring. sudo keeps
      # fingerprint.
      security.pam.services.login.fprintAuth = false;
    };

  features.noctalia.homeManager =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
      xdg.configFile."noctalia".source =
        config.lib.file.mkOutOfStoreSymlink "${config.dotfiles}/modules/features/desktop/noctalia/config";

      # Catppuccin Mocha recolours from abhishekpaul724/catppuccin-mocha-wallpapers,
      # fetched at a pinned commit rather than copied in: the repo has no
      # licence. Upstream names contain spaces, which store paths reject, so
      # each gets a local name. ~/Pictures is the folder Noctalia's picker
      # browses; config/config.toml picks the default.
      home.file =
        lib.mapAttrs'
          (
            name:
            { file, hash }:
            lib.nameValuePair "Pictures/Wallpapers/${name}" {
              source = pkgs.fetchurl {
                inherit name hash;
                url = "https://raw.githubusercontent.com/abhishekpaul724/catppuccin-mocha-wallpapers/92ed6972477babf92040e2a7179825a9897906e2/pc-catppuccin-mocha-wallpapers/${file}";
              };
            }
          )
          {
            "city-bedroom.png" = {
              file = "Screenshot%202025-06-16%20000024-catppuccin-mocha.png";
              hash = "sha256-WMzuv+u5WJhVRkGPlul0oEDSaliutpGLNuJ1YXla68w=";
            };
            "neon-street.png" = {
              file = "Screenshot%202025-07-20%20121133-catppuccin-mocha.png";
              hash = "sha256-wD/kUMqbJU1lLuKrLxOIDzM63DQhrAXrjb6pmktoaUM=";
            };
          };
    };
}
