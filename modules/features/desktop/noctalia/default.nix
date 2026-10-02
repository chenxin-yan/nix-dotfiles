# Noctalia, the desktop shell (bar, notifications, lock screen, idle, OSD,
# polkit prompts) and its matching greetd login screen. Its TOML config is
# linked from the checkout and hot-reloads. Changes made in Noctalia's settings
# window land in ~/.local/state/noctalia/settings.toml instead; keep the ones
# you like by copying them from `noctalia config export` into config/.
{ config, ... }:
{
  features.noctalia.includes = with config.features; [ paths ];

  features.noctalia.nixos =
    { host, ... }:
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
        # Login screen picks up the shell's wallpaper and palette without a
        # password prompt.
        passwordlessSyncUsers = [ host.login ];
      };

      # Noctalia's lock screen authenticates against the login stack and drives
      # the fingerprint reader itself over D-Bus; pam_fprintd in that stack
      # would fight it for the sensor. Logging in takes the password, which
      # also unlocks the keyring. sudo keeps fingerprint.
      security.pam.services.login.fprintAuth = false;
      security.pam.services.greetd.fprintAuth = false;
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
    };
}
