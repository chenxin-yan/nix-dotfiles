let
  # The desktop SSH key: its private half lives in 1Password and is used
  # through its agent (see _1password). Every machine running sshd accepts it.
  desktopKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFWnvoxNfnjA+u4YQy6/nmnpywOJeLngB4Jz1aB1Q1It";
  server =
    { host, ... }:
    {
      services.openssh.enable = true;
      users.users.${host.login}.openssh.authorizedKeys.keys = [ desktopKey ];
    };
in
{
  features.sshd = {
    darwin = server;
    nixos = server;
  };
}
