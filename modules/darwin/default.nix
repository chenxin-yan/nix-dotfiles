{ lib, config, ... }:

{
  imports = [
    ./1password
    ./aerospace
    ./kanata
  ];

  config = {
    darwin._1password.enable = lib.mkDefault true;
    darwin.aerospace.enable = lib.mkDefault true;
    darwin.kanata.enable = lib.mkDefault true;
  };
}
