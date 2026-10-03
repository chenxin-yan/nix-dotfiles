{ config, inputs, ... }:
{
  hosts.framework = {
    system = "x86_64-linux";
    login = "cyan";

    features = with config.features; [
      workstation
      desktop
    ];

    nixos =
      { host, pkgs, ... }:
      {
        imports = [
          ./_hardware-configuration.nix
          inputs.nixos-hardware.nixosModules.framework-amd-ai-300-series
        ];

        boot.loader.systemd-boot.enable = true;
        boot.loader.efi.canTouchEfiVariables = true;
        # Ryzen AI 300 support keeps improving upstream; Framework recommends the latest kernel.
        boot.kernelPackages = pkgs.linuxPackages_latest;

        networking.networkmanager.enable = true;

        # Stop charging at 80% to slow battery wear (kernel cros_charge_control).
        # udev re-checks on every battery event and writes only when it differs.
        services.udev.extraRules = ''
          SUBSYSTEM=="power_supply", KERNEL=="BAT1", ATTR{charge_control_end_threshold}!="80", ATTR{charge_control_end_threshold}="80"
        '';
        time.timeZone = "America/Los_Angeles";

        users.users.${host.login} = {
          isNormalUser = true;
          description = "Chenxin Yan";
          uid = 1000;
          extraGroups = [
            "networkmanager"
            "wheel"
          ];
          shell = pkgs.zsh;
        };

        # The NixOS release this machine was installed with; read the release notes before changing.
        system.stateVersion = "26.05";
      };

    homeManager.home.stateVersion = "26.11";
  };
}
