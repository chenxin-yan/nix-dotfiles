let
  # The desktop SSH key: its private half lives in 1Password and is used
  # through its agent (see _1password). Every machine running sshd accepts it.
  desktopKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFWnvoxNfnjA+u4YQy6/nmnpywOJeLngB4Jz1aB1Q1It";
  # Keys only, no root, and only the keys declared here or in host files:
  # a hand-added ~/.ssh/authorized_keys is ignored.
  server =
    { host, ... }:
    {
      services.openssh.enable = true;
      users.users.${host.login}.openssh.authorizedKeys.keys = [ desktopKey ];
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
