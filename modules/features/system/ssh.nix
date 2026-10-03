# Client config; accepting connections is sshd. ssh offers ~/.ssh/id_ed25519
# by default, which servers use; desktops use 1Password's agent instead (see
# _1password).
{ config, lib, ... }:
let
  inherit (config) hosts;
  # Every enrolled machine is pinned by its host key, so connecting to one
  # never asks to trust it. Reached by its inventory name, which is also its
  # hostname and so its Tailscale MagicDNS name.
  knownHosts.programs.ssh.knownHosts =
    lib.mapAttrs (name: publicKey: {
      hostNames = [ name ];
      inherit publicKey;
    }) config.hostKeys
    // {
      # GitHub's published key (api.github.com/meta, SHA256:+DiY3wvv…), so a
      # new machine can push over SSH without a trust prompt.
      "github.com".publicKey =
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl";
    };
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
          settings =
            lib.mapAttrs (_: host: {
              User = host.login;
              ControlMaster = "auto";
              ControlPersist = "10m";
              ControlPath = "${config.home.homeDirectory}/.ssh/cm-%C";
            }) hosts
            // {
              "github.com" = {
                AddKeysToAgent = "yes";
              }
              // lib.optionalAttrs isDarwin {
                UseKeychain = "yes";
              };

            };
        };
      };
  };
}
