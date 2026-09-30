# Podman: the NixOS service on Linux; on macOS Home Manager runs the
# podman machine. Client tooling comes from the Home Manager half on both.
{
  features.podman.nixos =
    { host, ... }:
    {
      virtualisation.podman = {
        enable = true;
        dockerCompat = true;
        dockerSocket.enable = true;
        defaultNetwork.settings.dns_enabled = true;
      };

      users.users.${host.login}.extraGroups = [ "podman" ];
    };

  features.podman.homeManager =
    { pkgs, lib, ... }:
    let
      isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
    in
    {
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

        # mkAfter: runs after the zsh feature's `source ~/.env`, so this
        # DOCKER_HOST wins over one set there.
        initContent = lib.mkIf isDarwin (
          lib.mkAfter ''
            # Set DOCKER_HOST for Podman machine on macOS.
            if command -v podman >/dev/null 2>&1; then
              export DOCKER_HOST=unix://$(podman machine inspect --format '{{.ConnectionInfo.PodmanSocket.Path}}')
            fi
          ''
        );
      };
    };
}
