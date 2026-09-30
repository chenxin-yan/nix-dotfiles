{ config, ... }:
{
  hosts.macbook = {
    system = "aarch64-darwin";
    login = "yanchenxin";

    features = with config.features; [ mac ];

    configuration =
      { host, pkgs, ... }:
      {
        # Used for backwards compatibility, please read the changelog before changing.
        # $ darwin-rebuild changelog
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

    home = {
      home.stateVersion = "25.05";

      cli.syncthing.enable = true;
    };
  };
}
