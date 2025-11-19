{
  config,
  pkgs,
  inputs,
  ...
}:

{
  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = [
    pkgs.kanata
  ];

  # Necessary for using flakes on this system.
  nix.settings.experimental-features = "nix-command flakes";

  # Automatic garbage collection
  nix.gc = {
    automatic = true;
    interval = [ { Weekday = 7; } ]; # Sunday (any time)
    options = "--delete-older-than 7d";
  };

  # Automatic Nix store optimization
  nix.optimise = {
    automatic = true;
    interval = [ { Weekday = 7; } ]; # Sunday (any time)
  };

  # Set Git commit hash for darwin-version.
  system.configurationRevision = config.rev or config.dirtyRev or null;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 6;

  system.primaryUser = "yanchenxin";

  users.users.${config.system.primaryUser} = {
    name = "${config.system.primaryUser}";
    home = "/Users/${config.system.primaryUser}";
  };

  # The platform the configuration will be used on.
  nixpkgs.hostPlatform = "aarch64-darwin";
  nixpkgs.config.allowUnfree = true;

  fonts.packages = [
    pkgs.nerd-fonts.jetbrains-mono
    pkgs.sketchybar-app-font
  ];

  # Kanata system daemon
  launchd.daemons.kanata = {
    serviceConfig = {
      ProgramArguments = [
        "/run/current-system/sw/bin/kanata"
        "--cfg"
        "/Users/${config.system.primaryUser}/.config/kanata/kanata.kbd"
      ];
      KeepAlive = true;
      RunAtLoad = true;
      UserName = "root";
      StandardOutPath = "/Users/${config.system.primaryUser}/Library/Logs/kanata.log";
      StandardErrorPath = "/Users/${config.system.primaryUser}/Library/Logs/kanata.error.log";
    };
  };

  homebrew = {
    enable = true;
    casks = [
      "ghostty"
      "iina"
      "karabiner-elements"
    ];
    onActivation.cleanup = "zap";
  };

  services.sketchybar.enable = true;
}
