# Raspberry Pi 5 on its NVMe, migrated from Debian (cyanpi) in 2026-10.
# Installed by flashing system.build.sdImage, so the sd-image module stays:
# it owns the disk layout and grows / on first boot.
{ inputs, config, ... }:
{
  hosts.pi = {
    system = "aarch64-linux";
    login = "cyan";
    sshKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEA9KJWsS/AqxAP1FJ86E4OkiYszggB7mKtyoMxqE5Th";

    features = with config.features; [
      server
      secrets
      hermes
      obsidian-headless
      dokploy
    ];

    nixos =
      {
        config,
        host,
        lib,
        modulesPath,
        pkgs,
        ...
      }:
      {
        # Its board modules take the flake as a module argument.
        _module.args.nixos-raspberrypi = inputs.nixos-raspberrypi;
        imports = with inputs.nixos-raspberrypi.nixosModules; [
          inputs.nixos-raspberrypi.lib.inject-overlays
          nixpkgs-rpi
          trusted-nix-caches
          raspberry-pi-5.base
          sd-image
        ];
        # The image module pulls in the installer's tool set (and ZFS, built
        # against the vendor kernel); this is a server, not install media.
        disabledModules = [ (modulesPath + "/profiles/base.nix") ];
        # The image module also turns on drivers for every board and disk
        # type; the board module already brings the Pi 5's (NVMe, PCIe,
        # USB). Fewer modules keep each generation's initrd small on the
        # firmware partition.
        hardware.enableAllHardware = lib.mkForce false;
        # TODO: remove this workaround once nixos-raspberrypi fixes
        # https://github.com/nvmd/nixos-raspberrypi/issues/201:
        # its kernel is built by its own nixpkgs 26.05, so it lacks the
        # buildDTBs and target attributes that 26.11 modules read. Adding
        # them to passthru keeps the derivation, so the kernel still comes
        # prebuilt from nixos-raspberrypi.cachix.org.
        boot.kernelPackages = pkgs.linuxPackagesFor (
          inputs.nixos-raspberrypi.packages.${pkgs.stdenv.hostPlatform.system}.linuxPackages_rpi5.kernel.overrideAttrs
            (prev: {
              passthru = prev.passthru // {
                buildDTBs = true;
                target = "Image";
              };
            })
        );

        # Its colours come from a palette built at evaluation, which an x86_64
        # machine can't build for aarch64, so `nix flake check` would fail
        # there. Headless, so the console is rarely seen anyway.
        catppuccin.tty.enable = false;

        time.timeZone = "America/Los_Angeles";
        i18n.defaultLocale = "en_US.UTF-8";

        sops.secrets.cyan-password = {
          sopsFile = ../../../secrets/hosts/pi.yaml;
          neededForUsers = true;
        };
        users.users.${host.login} = {
          isNormalUser = true;
          description = "Chenxin Yan";
          # Matches the owner of the restored home files.
          uid = 1000;
          extraGroups = [ "wheel" ];
          hashedPasswordFile = config.sops.secrets.cyan-password.path;
          shell = pkgs.zsh;
          linger = true; # user services (Hermes, Atlas sync) run without a login
        };

        environment.systemPackages = [ pkgs.git ];

        # Everything but SSH stays on the tailnet; SSH also on the LAN as a
        # way in when Tailscale is down.
        networking.firewall = {
          trustedInterfaces = [ "tailscale0" ];
          allowedTCPPorts = [ 22 ];
          allowedUDPPorts = [ config.services.tailscale.port ];
        };

        # Let Tailscale (MagicDNS) manage DNS through resolved rather than
        # rewriting resolv.conf: https://github.com/tailscale/tailscale/issues/4254
        services.resolved.enable = true;

        system.stateVersion = "26.11";
      };

    homeManager =
      { pkgs, ... }:
      {
        home.stateVersion = "26.11";

        home.packages = with pkgs; [
          # terminfo for xterm-ghostty so SSH sessions from Ghostty clients work
          ghostty.terminfo
        ];
      };
  };
}
