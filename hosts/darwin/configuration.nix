{
  config,
  pkgs,
  inputs,
  ...
}:

{

  imports = [
    ../../modules/darwin
  ];

  # Fix macOS locale issue (BCP 47 format incompatible with Unix tools)
  environment.variables = {
    LANG = "en_US.UTF-8";
    LC_ALL = "en_US.UTF-8";
  };

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
    keymapp
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

  programs.zsh.enable = true;
  users.users.${config.system.primaryUser} = {
    name = "${config.system.primaryUser}";
    home = "/Users/${config.system.primaryUser}";
    shell = pkgs.zsh;
    uid = 501;
  };

  # The platform the configuration will be used on.
  nixpkgs.hostPlatform = "aarch64-darwin";
  nixpkgs.config.allowUnfree = true;

  fonts.packages = [
    pkgs.nerd-fonts.jetbrains-mono
    pkgs.sketchybar-app-font
    pkgs.geist-font
  ];

  homebrew = {
    enable = true;
    brews = [
      "mole"
    ];
    casks = [
      "ghostty"
      "iina"
      "todoist-app"
    ];
    onActivation.cleanup = "zap";
  };

  services.sketchybar.enable = true;

  services.tailscale.enable = true;
}
