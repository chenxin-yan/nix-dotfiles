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
          inputs.lanzaboote.nixosModules.lanzaboote
        ];

        # Secure Boot with our own keys: lanzaboote signs every boot entry.
        # Keys are generated on first boot into /var/lib/sbctl (on the
        # encrypted root) and written to the firmware by systemd-boot once the
        # BIOS is put in setup mode. Microsoft's and Framework's built-in keys
        # are kept: option ROMs and Framework's firmware updates need them.
        boot.lanzaboote = {
          enable = true;
          pkiBundle = "/var/lib/sbctl";
          # systemd-pcrlock, behind measured boot, allows at most 4.
          configurationLimit = 4;
          autoGenerateKeys.enable = true;
          autoEnrollKeys = {
            enable = true;
            includeFirmwareBuiltinKeys = true;
          };
          # The TPM releases the disk key only when firmware (PCR 0), the
          # signed boot chain (4) and the Secure Boot state (7) match; every
          # rebuild updates the policy. Lanzaboote calls PCRs 1-3 flaky. No TPM
          # PIN, so the greeter is the only password; the LUKS passphrase in
          # 1Password is the fallback when the TPM refuses (e.g. BIOS update).
          measuredBoot = {
            enable = true;
            pcrs = [
              0
              4
              7
            ];
          };
        };
        environment.systemPackages = [ pkgs.sbctl ];
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
