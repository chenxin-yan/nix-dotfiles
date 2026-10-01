{ config, ... }:
{
  hosts.minipc = {
    system = "x86_64-linux";
    login = "cyan";
    sshKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFajA/D3AwQhbTCg+41FNno/28KYAjAKJd57R3n+dPD+";

    features = with config.features; [
      workstation
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
        time.timeZone = "America/Los_Angeles";

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

        # Firewall
        # - Trust all Tailscale traffic (no need to open ports for Tailscale-only services)
        # - Allow Tailscale UDP port for direct peer-to-peer connections (avoids DERP relay)
        # - Keep SSH open on LAN as emergency fallback
        networking.firewall = {
          trustedInterfaces = [ "tailscale0" ];
          allowedTCPPorts = [ 22 ];
          allowedUDPPorts = [ config.services.tailscale.port ];
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
      { pkgs, ... }:

      {
        home.stateVersion = "25.05";

        home.packages = with pkgs; [
          # terminfo for xterm-ghostty so SSH sessions from Ghostty clients work
          ghostty.terminfo
        ];

        services.ssh-agent.enable = true;
      };
  };
}
