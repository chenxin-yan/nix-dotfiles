{ config, ... }:
{
  hosts.work-macbook = {
    system = "aarch64-darwin";
    login = "chenxin-yan";

    # Docker via colima instead of podman (see home below).
    features = with config.features; [
      _1password
      kanata
      sketchybar
    ];

    configuration =
      { host, pkgs, ... }:
      {
        imports = [
          ../../legacy/profiles/darwin
        ];

        system.stateVersion = 6;

        users.users.${host.login} = {
          home = "/Users/${host.login}";
          shell = pkgs.zsh;
          uid = 501;
          openssh.authorizedKeys.keys = [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFajA/D3AwQhbTCg+41FNno/28KYAjAKJd57R3n+dPD+"
          ];
        };
      };

    home =
      { pkgs, ... }:
      {
        imports = [
          ../../legacy/profiles/home/darwin.nix
        ];

        home.stateVersion = "25.05";

        home.packages = with pkgs; [
          colima
          docker
          docker-compose
          docker-buildx
        ];

        programs.lazydocker.enable = true;
        cli.syncthing.enable = false;
      };
  };
}
