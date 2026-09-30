{ config, ... }:
{
  hosts.work-macbook = {
    system = "aarch64-darwin";
    login = "chenxin-yan";

    features = with config.features; [ mac ];
    # Docker via colima instead of podman (see home below).
    exclude = with config.features; [ podman ];

    configuration =
      { host, pkgs, ... }:
      {
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
        home.stateVersion = "25.05";

        home.packages = with pkgs; [
          colima
          docker
          docker-compose
          docker-buildx
        ];

        programs.lazydocker.enable = true;
      };
  };
}
