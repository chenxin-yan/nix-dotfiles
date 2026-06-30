{
  config,
  pkgs,
  lib,
  ...
}:

let
  isDarwin = pkgs.stdenv.isDarwin;
in
{
  options = {
    cli.podman.enable = lib.mkEnableOption "enables podman container manager";
  };

  config = lib.mkIf config.cli.podman.enable {
    home.packages =
      (with pkgs; [
        docker-compose
        dive

        # editor
        dockerfile-language-server
        docker-compose-language-service
        hadolint
      ])
      ++ lib.optionals isDarwin (with pkgs; [
        podman
      ]);

    programs.lazydocker.enable = true;

    programs.zsh = {
      shellAliases = {
        dk = "lazydocker";
      } // lib.optionalAttrs isDarwin {
        docker = "podman";
      };

      initContent = lib.mkIf isDarwin ''
        # Set DOCKER_HOST for Podman machine on macOS.
        if command -v podman >/dev/null 2>&1; then
          export DOCKER_HOST=unix://$(podman machine inspect --format '{{.ConnectionInfo.PodmanSocket.Path}}')
        fi
      '';
    };
  };
}
