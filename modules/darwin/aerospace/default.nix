{ pkgs, lib, ... }:

{
  home.file.".config/aerospace/aerospace.toml".source = lib.mkForce ./config/aerospace.toml;

  programs.aerospace = {
    enable = true;

    # Enable launchd service management
    launchd = {
      enable = true;
      keepAlive = true;
    };
  };
}
