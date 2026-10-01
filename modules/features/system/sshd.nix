{ config, lib, ... }:
let
  # The desktop SSH key: its private half lives in 1Password and is used
  # through its agent (see _1password). Machines without 1Password declare
  # their own key as `hosts.<name>.sshKey`. Every machine running sshd
  # accepts all of them, so any fleet machine can reach any other.
  desktopKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFWnvoxNfnjA+u4YQy6/nmnpywOJeLngB4Jz1aB1Q1It";
  fleetKeys = [
    desktopKey
  ]
  ++ lib.filter (k: k != null) (lib.mapAttrsToList (_: h: h.sshKey) config.hosts);
  # Keys only, no root, and only the keys declared here:
  # a hand-added ~/.ssh/authorized_keys is ignored.
  server =
    { host, ... }:
    {
      services.openssh.enable = true;
      users.users.${host.login}.openssh.authorizedKeys.keys = fleetKeys;
    };
in
{
  features.sshd = {
    darwin = {
      imports = [ server ];
      # nix-darwin's own AuthorizedKeysCommand still serves the declared keys.
      services.openssh.extraConfig = ''
        PasswordAuthentication no
        KbdInteractiveAuthentication no
        PermitRootLogin no
        AuthorizedKeysFile none
      '';
    };
    nixos = {
      imports = [ server ];
      services.openssh.settings = {
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
        PermitRootLogin = "no";
      };
      services.openssh.authorizedKeysInHomedir = false;
    };
  };
}
