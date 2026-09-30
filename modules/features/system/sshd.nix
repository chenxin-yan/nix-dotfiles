let
  server.services.openssh.enable = true;
in
{
  features.sshd = {
    darwin = server;
    nixos = server;
  };
}
