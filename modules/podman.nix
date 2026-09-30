# Podman: the NixOS service on Linux; on macOS Home Manager runs the
# podman machine. Client tooling comes from the Home Manager half on both.
{
  flake.modules.nixos.features =
    {
      lib,
      config,
      host,
      ...
    }:
    {
      options = {
        nixos.podman.enable = lib.mkEnableOption "enables podman container manager";
      };

      config = lib.mkIf config.nixos.podman.enable {
        virtualisation.podman = {
          enable = true;
          dockerCompat = true;
          dockerSocket.enable = true;
          defaultNetwork.settings.dns_enabled = true;
        };

        users.users.${host.login}.extraGroups = [ "podman" ];
      };
    };

  flake.modules.homeManager.features =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
    in
    {
      options = {
        cli.podman.enable = lib.mkEnableOption "enables podman container manager";
      };

      config = lib.mkIf config.cli.podman.enable {
        home.packages = with pkgs; [
          docker-compose
          dive

          # editor
          dockerfile-language-server
          docker-compose-language-service
          hadolint
        ];

        services.podman = lib.mkIf isDarwin {
          enable = true;
          useDefaultMachine = true;
        };

        programs.lazydocker.enable = true;

        programs.zsh = {
          shellAliases = {
            dk = "lazydocker";
          }
          // lib.optionalAttrs isDarwin {
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
    };
}
