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

      # Catppuccin Mocha recolours from wallppuccin, fetched at a pinned commit
      # rather than copied in: the repo has no licence and most images are
      # third-party art. ~/Pictures is the folder Noctalia's picker browses;
      # config/config.toml picks the default.
      home.file =
        lib.mapAttrs'
          (
            name: hash:
            lib.nameValuePair "Pictures/Wallpapers/${name}" {
              source = pkgs.fetchurl {
                url = "https://raw.githubusercontent.com/imanubdesigner/wallppuccin/84408d96a3be131c4097bda7b20b8cec2b3b07cd/wallpapers/${name}";
                inherit hash;
              };
            }
          )
          {
            "jungle-cats-hideaway.jpg" = "sha256-GZ9QETKe4XV+LGW3KUU4fudb3/1Rj0FVgOKxiU53li4=";
            "jupiter.png" = "sha256-fGVRjdjaGgdAoSvwGCY+/EC+oBeBnODF6JGx7xTtQdQ=";
          };
    };
}
