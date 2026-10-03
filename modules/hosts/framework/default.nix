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
        # The root partition is LUKS2, encrypted in place; the ext4 inside keeps
        # its UUID, so fileSystems."/" is unchanged. systemd's initrd prompts
        # for the passphrase, or unlocks with the TPM once one is enrolled.
        boot.initrd.systemd.enable = true;
        boot.initrd.luks.devices.cryptroot = {
          device = "/dev/disk/by-partuuid/0644c44e-5125-4041-86ec-81fc78a64f1b";
          crypttabExtraOpts = [ "tpm2-device=auto" ];
        };
        boot.loader.efi.canTouchEfiVariables = true;
        # Ryzen AI 300 support keeps improving upstream; Framework recommends the latest kernel.
        boot.kernelPackages = pkgs.linuxPackages_latest;

        networking.networkmanager.enable = true;
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
