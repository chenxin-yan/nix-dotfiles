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
        hasOnePassword = host: lib.any (f: f.name == "_1password") host.selected;
        desktops = lib.attrNames (lib.filterAttrs (_: hasOnePassword) hosts);
      in
      {
        programs.ssh = {
          enable = true;
          enableDefaultConfig = false;
          settings =
            lib.mapAttrs (
              _: host:
              {
                User = host.login;
                ControlMaster = "auto";
                ControlPersist = "10m";
                ControlPath = "${config.home.homeDirectory}/.ssh/cm-%C";
              }
              # Over SSH a desktop's own 1Password can't be unlocked, so it
              # uses this machine's agent instead (see _1password). Set here,
              # not with -A: a reused ControlMaster connection ignores -A.
              // lib.optionalAttrs (hasOnePassword host) {
                ForwardAgent = "yes";
              }
            ) hosts
            # A shared connection forwards the agent of the session that opened
            # it, so one opened over SSH must not serve local sessions or the
            # reverse. Before the host blocks: ssh keeps the first ControlPath.
            // lib.optionalAttrs (desktops != [ ]) {
              ${''Match host ${lib.concatStringsSep "," desktops} exec "test -n \"$SSH_CONNECTION\""''} =
                lib.hm.dag.entryBefore desktops
                  { ControlPath = "none"; };
            }
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
