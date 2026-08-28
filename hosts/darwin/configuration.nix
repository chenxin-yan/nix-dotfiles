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

  # Determinate manages the Nix installation and daemon on this machine.
  nix.enable = false;

  # Set Git commit hash for darwin-version.
  system.configurationRevision = config.rev or config.dirtyRev or null;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 6;

  programs.zsh.enable = true;
  users.users.${config.system.primaryUser} = {
    name = "${config.system.primaryUser}";
    home = "/Users/${config.system.primaryUser}";
    shell = pkgs.zsh;
    uid = 501;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFajA/D3AwQhbTCg+41FNno/28KYAjAKJd57R3n+dPD+"
    ];
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
    taps = [
      "daytonaio/cli"
    ];
    brews = [
      "mole"
      "daytonaio/cli/daytona"
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
