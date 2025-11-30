{ lib, config, ... }:

{
  imports = [
    ./1password
  ];

  config = {
    darwin._1password.enable = lib.mkDefault true;
  };
}
