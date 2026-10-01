# Every machine with a role: maintained, on the tailnet, reachable over SSH.
{ config, ... }:
{
  features.fleet.includes = with config.features; [
    base
    nix-gc
    unfree
    tailscale
    sshd
    _1password-cli
  ];
}
