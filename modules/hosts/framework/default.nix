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
      {
        host,
        lib,
        pkgs,
        ...
      }:
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
          # rebuild and boot updates the policy. Lanzaboote calls PCRs 1-3
          # flaky. No TPM PIN, so the greeter is the only password. After a
          # BIOS update the TPM refuses once: unlock with the LUKS passphrase
          # in 1Password, and that boot re-seals for the new firmware. Only
          # re-enroll if pcrlock.json is deleted:
          #   systemd-cryptenroll --wipe-slot=tpm2 --tpm2-device=auto \
          #     --tpm2-pcrlock=/var/lib/systemd/pcrlock.json \
          #     --tpm2-pcrs=15:sha256=0000000000000000000000000000000000000000000000000000000000000000 \
          #     /dev/nvme0n1p2
          # (PCR 15 at zero: see cryptroot below.)
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
        # The root partition is LUKS2, encrypted in place. systemd's initrd
        # unlocks it with the TPM, or prompts for the passphrase.
        #
        # A TPM that unlocks without a PIN must only ever hand the key to our
        # own root. Otherwise an attacker swaps in a partition they control,
        # our signed initrd boots it with PCRs 0/4/7 intact, and their code
        # asks the TPM for the real key (oddlama.org/blog/bypassing-disk-
        # encryption-with-tpm2-unlock). So: the key is also bound to PCR 15
        # being zero, which tpm2-measure-pcr extends as soon as any volume is
        # unlocked; and root and resume name the mapper device, so nothing
        # that skipped the unlock (a plain ext4 or a planted hibernation image
        # with our UUID) can be used. tpm2-device=auto is still needed: the
        # measure option turns off the token plugin that would imply it.
        boot.initrd.systemd.enable = true;
        boot.initrd.luks.devices.cryptroot = {
          device = "/dev/disk/by-partuuid/0644c44e-5125-4041-86ec-81fc78a64f1b";
          # Lets fstrim reach the SSD. The tradeoff: someone holding the disk
          # can tell which blocks are free, never what the others contain.
          allowDiscards = true;
          crypttabExtraOpts = [
            "tpm2-device=auto"
            "tpm2-measure-pcr=yes"
          ];
        };
        fileSystems."/".device = lib.mkForce "/dev/mapper/cryptroot";
        boot.resumeDevice = "/dev/mapper/cryptroot";
        boot.loader.efi.canTouchEfiVariables = true;
        # Skip the boot menu; hold Space at power-on to show it (older
        # generations, firmware setup).
        boot.loader.timeout = 0;

        # Room for a hibernation image of all 64 GB of RAM, on the encrypted
        # root so the image is encrypted too. The offset is the swapfile's
        # first block, as systemd reports it at boot ("Reported hibernation
        # image: ... offset="); it changes only if the swapfile is recreated.
        # The resume= above outranks the HibernateLocation EFI variable, which
        # anything that boots could rewrite.
        boot.kernelParams = [ "resume_offset=78739456" ];
        swapDevices = [
          {
            device = "/var/lib/swapfile";
            size = 64 * 1024;
          }
        ];
        # With no HibernateDelaySec, systemd hibernates only when the battery
        # runs low; Noctalia's suspend uses the same mode (noctalia/config).
        services.logind.settings.Login.HandleLidSwitch = "suspend-then-hibernate";
        # The default "platform" mode enters ACPI S4 after writing the image; a
        # spurious wakeup event there makes the kernel roll back, and amdgpu
        # doesn't survive the rollback (black screen, niri crashes). Plain
        # power-off skips that check; nothing needs to wake the laptop from S4.
        systemd.sleep.settings.Sleep.HibernateMode = "shutdown";
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

        # The default system service re-runs Home Manager only when its
        # generation changes, so a switch that changes nothing skipped steps
        # that sync app-owned state (Helium's Preferences). As a user service,
        # Home Manager restarts it on every switch, like nix-darwin's
        # activation. Headless hosts keep the default, which activates before
        # logins at boot. Drop once the default mode re-runs on every switch:
        # https://github.com/nix-community/home-manager/issues/10030
        home-manager.startAsUserService = true;

        # The NixOS release this machine was installed with; read the release notes before changing.
        system.stateVersion = "26.05";
      };

    homeManager.home.stateVersion = "26.11";
  };
}
