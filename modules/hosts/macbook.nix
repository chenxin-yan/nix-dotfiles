{ config, ... }:
{
  hosts.macbook = {
    system = "aarch64-darwin";
    login = "yanchenxin";

    features = with config.features; [
      workstation
      desktop
    ];

    darwin =
      { host, pkgs, ... }:
      {
        # Used for backwards compatibility, please read the changelog before changing.
        # $ darwin-rebuild changelog
        system.stateVersion = 6;

        users.users.${host.login} = {
          home = "/Users/${host.login}";
          shell = pkgs.zsh;
          uid = 501;
        };
      };

    homeManager = {
      home.stateVersion = "25.05";
    };
  };
}
