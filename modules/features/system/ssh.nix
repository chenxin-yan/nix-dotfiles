# Client config; accepting connections is sshd.
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
        identity = "${config.home.homeDirectory}/.ssh/id_ed25519";
        inherit (pkgs.stdenv.hostPlatform) isDarwin;
      in
      {
        programs.ssh = {
          enable = true;
          enableDefaultConfig = false;
          settings = {
            "github.com" = {
              AddKeysToAgent = "yes";
              IdentityFile = identity;
            }
            // lib.optionalAttrs isDarwin {
              UseKeychain = "yes";
            };
          }
          // lib.optionalAttrs isDarwin {
            "cyan-minipc" = {
              User = hosts.minipc.login;
              IdentityFile = identity;
              ControlMaster = "auto";
              ControlPersist = "10m";
              ControlPath = "${config.home.homeDirectory}/.ssh/cm-%C";
            };

            "cyanpi" = {
              User = "yanchenxin";
              IdentityFile = identity;
            };
          };
        };
      };
  };
}
