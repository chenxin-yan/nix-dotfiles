# Client config; accepting connections is sshd. ssh offers ~/.ssh/id_ed25519
# by default, which servers use; desktops use 1Password's agent instead (see
# _1password).
{ config, lib, ... }:
let
  inherit (config) hosts;
  # Every enrolled machine is pinned by its host key, so connecting to one
  # never asks to trust it. Reached as cyan-<name> over Tailscale.
  knownHosts.programs.ssh.knownHosts = lib.mapAttrs (name: publicKey: {
    hostNames = [
      name
      "cyan-${name}"
    ];
    inherit publicKey;
  }) config.hostKeys;
in
{
  features.ssh = {
    darwin = knownHosts;
    nixos = knownHosts;
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
