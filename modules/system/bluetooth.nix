{
  features.bluetooth.nixos =
    { pkgs, ... }:
    {
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
