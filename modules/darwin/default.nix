{ lib, config, ... }:

{
  imports = [
    ./1password
    ./aerospace
    ./kanata
    ./sketchybar
  ];

  config = {
    darwin._1password.enable = lib.mkDefault true;
    darwin.aerospace.enable = lib.mkDefault true;
    darwin.kanata.enable = lib.mkDefault true;
    darwin.sketchybar.enable = lib.mkDefault true;
  };
}
