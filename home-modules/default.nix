{ lib, pkgs, ... }:

{
  imports = [
    ./app
    ./cli
    ./core
    ./dev
  ];
}
