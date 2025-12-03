{
  lib,
  config,
  pkgs,
  ...
}:

{
  options = {
    nixos.bluetooth.enable = lib.mkEnableOption "enables bluetooth config";
  };

  config = lib.mkIf config.nixos.bluetooth.enable {
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;
    };

    environment.systemPackages = with pkgs; [
      bluez # Bluetooth support
      bluez-tools # Bluetooth tools
    ];
  };
}
