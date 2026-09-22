# System settings shared by every registered Mac. Account facts, state
# versions and hostnames stay in hosts/<name>/configuration.nix and the flake.
{ config, pkgs, ... }:

{
  imports = [
    ./.
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

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Set Git commit hash for darwin-version.
  system.configurationRevision = config.rev or config.dirtyRev or null;

  programs.zsh.enable = true;

  nixpkgs.config.allowUnfree = true;

  fonts.packages = [
    pkgs.nerd-fonts.jetbrains-mono
    pkgs.sketchybar-app-font
    pkgs.geist-font
  ];

  # Both Macs deliberately remove unlisted Homebrew packages and associated
  # cask data; include everything to retain in the effective Homebrew config.
  homebrew = {
    enable = true;
    brews = [
      "mole"
    ];
    casks = [
      "font-sf-pro"
      "todoist-app"
    ];
    onActivation = {
      cleanup = "zap";
    };
  };

  services.tailscale.enable = true;

  services.openssh.enable = true;
}
