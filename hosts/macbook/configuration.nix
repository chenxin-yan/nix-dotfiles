{ host, pkgs, ... }:

{
  imports = [
    ../../modules/darwin/shared.nix
  ];

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 6;

  users.users.${host.login} = {
    home = "/Users/${host.login}";
    shell = pkgs.zsh;
    uid = 501;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFajA/D3AwQhbTCg+41FNno/28KYAjAKJd57R3n+dPD+"
    ];
  };
}
