{
  config,
  pkgs,
  lib,
  ...
}:

let
  isLinux = pkgs.stdenv.isLinux;
  isDarwin = pkgs.stdenv.isDarwin;
in
{
  home.packages = with pkgs; [
    podman
    podman-compose
    dive

    # editor
    dockerfile-language-server
    docker-compose-language-service
    hadolint
  ];

  programs.lazydocker.enable = true;

  # Linux-specific Podman service configuration
  services.podman = lib.mkIf isLinux {
    enable = true;

    # Auto-update containers
    autoUpdate = {
      enable = true;
    };

    # Enable type checks for quadlet configurations
    enableTypeChecks = true;
  };

  # Environment variables for Docker API compatibility
  home.sessionVariables = lib.mkIf isLinux {
    DOCKER_HOST = "unix:///run/user/1000/podman/podman.sock";
  };

  # Shell configuration with platform-specific DOCKER_HOST setup
  programs.zsh = {
    shellAliases = {
      docker = "podman";
      docker-compose = "podman-compose";
      dk = "lazydocker";
    };

    # Add DOCKER_HOST setup for macOS
    initContent = lib.mkIf isDarwin ''
      # Set DOCKER_HOST for Podman on macOS
      if command -v podman >/dev/null 2>&1; then
        export DOCKER_HOST=unix://$(podman machine inspect --format '{{.ConnectionInfo.PodmanSocket.Path}}')
      fi
    '';
  };
}
