{ config, ... }:
let
  inherit (config) hosts;
in
{
  hosts.minipc = {
    system = "x86_64-linux";
    login = "cyan";

    features = with config.features; [
      server
      workstation
      syncthing
    ];

    nixos =
      {
        config,
        host,
        pkgs,
        ...
      }:

      {
        imports = [
          ./_hardware-configuration.nix
        ];

        # Bootloader.
        boot.loader.systemd-boot.enable = true;
        boot.loader.efi.canTouchEfiVariables = true;

        # Enable networking
        networking.networkmanager.enable = true;

        # Set your time zone.
        time.timeZone = "America/New_York";

        # Select internationalisation properties.
        i18n.defaultLocale = "en_US.UTF-8";

        i18n.extraLocaleSettings = {
          LC_ADDRESS = "en_US.UTF-8";
          LC_IDENTIFICATION = "en_US.UTF-8";
          LC_MEASUREMENT = "en_US.UTF-8";
          LC_MONETARY = "en_US.UTF-8";
          LC_NAME = "en_US.UTF-8";
          LC_NUMERIC = "en_US.UTF-8";
          LC_PAPER = "en_US.UTF-8";
          LC_TELEPHONE = "en_US.UTF-8";
          LC_TIME = "en_US.UTF-8";
        };

        programs.nix-ld.enable = true;
        programs.nix-ld.libraries = with pkgs; [
        ];

        # Define a user account. Don't forget to set a password with ‘passwd’.
        users.users.${host.login} = {
          isNormalUser = true;
          description = "Chenxin Yan";
          uid = 1000;
          extraGroups = [
            "networkmanager"
            "wheel"
          ];
          openssh.authorizedKeys.keys = [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF4X1mHyGNSyyVqrWSIO/slGUBFPzcMOuDmP9UKI1FdN"
          ];
          shell = pkgs.zsh;
          linger = true; # Keep user services running without active login session
        };

        # List packages installed in system profile. To search, run:
        # $ nix search wget
        environment.systemPackages = with pkgs; [
          git
        ];

        # Some programs need SUID wrappers, can be configured further or are
        # started in user sessions.
        # programs.mtr.enable = true;
        # programs.gnupg.agent = {
        #   enable = true;
        #   enableSSHSupport = true;
        # };

        # List services that you want to enable:

        services.openssh.settings.PermitRootLogin = "yes";

        # Firewall
        # - Trust all Tailscale traffic (no need to open ports for Tailscale-only services)
        # - Allow Tailscale UDP port for direct peer-to-peer connections (avoids DERP relay)
        # - Keep SSH open on LAN as emergency fallback
        # - Syncthing ports open on LAN (localAnnounceEnabled = true)
        #   8384: GUI, 22000: sync traffic, 21027: discovery
        #   source: https://docs.syncthing.net/users/firewall.html
        networking.firewall = {
          trustedInterfaces = [ "tailscale0" ];
          allowedTCPPorts = [
            22
            8384
            22000
          ];
          allowedUDPPorts = [
            config.services.tailscale.port
            22000
            21027
          ];
        };

        # This value determines the NixOS release from which the default
        # settings for stateful data, like file locations and database versions
        # on your system were taken. It‘s perfectly fine and recommended to leave
        # this value at the release version of the first install of this system.
        # Before changing this value read the documentation for this option
        # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
        system.stateVersion = "25.05"; # Did you read the comment?

        # Use systemd-resolved for DNS (fixes known Tailscale DNS issue on NixOS,
        # enables MagicDNS). See: https://github.com/tailscale/tailscale/issues/4254
        services.resolved.enable = true;
        services.envfs.enable = true;
      };

    homeManager =
      {
        config,
        pkgs,
        ...
      }:

      {
        home.stateVersion = "25.05";

        home.packages = with pkgs; [
          # terminfo for xterm-ghostty so SSH sessions from Ghostty clients work
          ghostty.terminfo
        ];

        services.ssh-agent.enable = true;

        home.file.".ssh/known_hosts.d/cyan-macbook".text =
          "cyan-macbook ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILWPwldEec8fXHXQVExXb+Wix89Sxs5fOxxYCrShl+aI";

        programs.ssh = {
          settings = {
            "cyan-macbook" = {
              User = hosts.macbook.login;
              IdentityFile = "${config.home.homeDirectory}/.ssh/id_ed25519";
              CheckHostIP = false;
              UserKnownHostsFile = "${config.home.homeDirectory}/.ssh/known_hosts.d/cyan-macbook ${config.home.homeDirectory}/.ssh/known_hosts";
            };
          };
        };
      };
  };
}
