{
  imports = [
    ../../profiles/home/darwin.nix
  ];

  home.stateVersion = "25.05";

  cli.syncthing.enable = false;
}
