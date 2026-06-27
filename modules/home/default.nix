{ lib, pkgs, ... }:

{
  imports = [
    ./agents
    ./app
    ./cli
    ./core
    ./dev
  ];

  config.agents.enable = lib.mkDefault true;
}
