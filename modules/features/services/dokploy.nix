{ inputs, config, ... }:
let
  secrets = [
    "dokploy-db-password"
    "dokploy-auth-secret"
    # Never rotate: values Dokploy stored can't be re-keyed.
    "dokploy-encryption-key"
  ];
in
{
  features.dokploy = {
    includes = [ config.features.secrets ];

    nixos =
      {
        config,
        lib,
        pkgs,
        ...
      }:
      let
        secret = name: config.sops.secrets.${name}.path;
      in
      {
        imports = [ inputs.nix-dokploy.nixosModules.default ];

        sops.secrets = lib.genAttrs secrets (_: {
          sopsFile = ../../../secrets/hosts/${config.networking.hostName}.yaml;
        });

        virtualisation.docker = {
          enable = true;
          daemon.settings.live-restore = false;
        };

        services.dokploy = {
          enable = true;
          database.passwordFile = secret "dokploy-db-password";
          auth.secretFile = secret "dokploy-auth-secret";
          encryption.keyFile = secret "dokploy-encryption-key";
          # Swarm advertises the tailnet address; wait for it at boot.
          swarm.advertiseAddress = {
            command = ''for _ in $(seq 60); do ip=$(tailscale ip -4 2>/dev/null | head -n1) && [ -n "$ip" ] && break; sleep 2; done; echo "''${ip:-}"'';
            extraPackages = [ pkgs.tailscale ];
          };
        };
        systemd.services.dokploy-stack = {
          after = [ "tailscaled.service" ];
          wants = [ "tailscaled.service" ];
          serviceConfig = {
            Restart = "on-failure";
            RestartSec = 30;
          };
        };

        networking.firewall.extraCommands =
          let
            rules = pkgs.writeText "docker-user.rules" ''
              *filter
              :DOCKER-USER - [0:0]
              -A DOCKER-USER -m conntrack --ctstate RELATED,ESTABLISHED -j RETURN
              -A DOCKER-USER -i e+ -j DROP
              -A DOCKER-USER -i wl+ -j DROP
              -A DOCKER-USER -j RETURN
              COMMIT
            '';
          in
          ''
            iptables-restore --noflush ${rules}
            ip6tables-restore --noflush ${rules}
          '';
      };
  };
}
