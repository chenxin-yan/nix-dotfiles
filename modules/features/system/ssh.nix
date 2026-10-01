# Client config; accepting connections is sshd. ssh offers ~/.ssh/id_ed25519
# by default, which servers use; desktops use 1Password's agent instead (see
# _1password).
{ config, ... }:
let
  inherit (config) hosts;
in
{
  features.ssh = {
    homeManager =
      {
        config,
        lib,
        pkgs,
        ...
      }:
      let
        inherit (pkgs.stdenv.hostPlatform) isDarwin;
      in
      {
        programs.ssh = {
          enable = true;
          enableDefaultConfig = false;
          settings = {
            "github.com" = {
              AddKeysToAgent = "yes";
            }
            // lib.optionalAttrs isDarwin {
              UseKeychain = "yes";
            };

            "cyan-minipc" = {
              User = hosts.minipc.login;
              ControlMaster = "auto";
              ControlPersist = "10m";
              ControlPath = "${config.home.homeDirectory}/.ssh/cm-%C";
            };

            "cyanpi" = {
              User = "yanchenxin";
            };
          };
        };
      };
  };
}
