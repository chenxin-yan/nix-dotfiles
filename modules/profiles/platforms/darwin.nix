# Added to every *-darwin host: what nix-darwin needs to run this repo,
# plus settings that only exist for macOS.
{ config, ... }:
{
  features.darwin = {
    includes = with config.features; [
      nix-settings
      nh
    ];

    darwin = {
      # Fix macOS locale issue (BCP 47 format incompatible with Unix tools)
      environment.variables = {
        LANG = "en_US.UTF-8";
        LC_ALL = "en_US.UTF-8";
      };

      # Keyboard first. universalaccess.reduceMotion is left to System
      # Settings: writing that domain needs Full Disk Access, which would fail
      # activation from a terminal without it.
      system.defaults = {
        NSGlobalDomain = {
          AppleKeyboardUIMode = 2; # Tab reaches every control (2 on Sonoma and later)
          ApplePressAndHoldEnabled = false; # held keys repeat (hjkl) instead of offering accents
          InitialKeyRepeat = 15;
          KeyRepeat = 2;
          NSAutomaticWindowAnimationsEnabled = false;
        };
        dock = {
          autohide = true;
          mru-spaces = false; # Spaces keep their order instead of following use
          expose-animation-duration = 0.1;
        };
      };

      # Every Mac deliberately removes unlisted Homebrew packages and
      # associated cask data; features add the casks they need.
      homebrew = {
        enable = true;
        brews = [
          "mole"
        ];
        onActivation = {
          cleanup = "zap";
        };
      };
    };
  };
}
