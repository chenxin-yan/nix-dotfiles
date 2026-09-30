{ pkgs, ... }:

{
  imports = [
    ../../profiles/home/darwin.nix
  ];

  home.stateVersion = "25.05";

  home.packages = with pkgs; [
    colima
    docker
    docker-compose
    docker-buildx
  ];

  cli.podman.enable = false;
  programs.lazydocker.enable = true;
  cli.syncthing.enable = false;
}
