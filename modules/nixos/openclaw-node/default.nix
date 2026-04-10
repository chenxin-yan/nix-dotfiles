{
  lib,
  config,
  pkgs,
  ...
}:

let
  cfg = config.nixos.openclaw-node;
  openclawGatewayPkg = pkgs."openclaw-gateway";
  gatewayScheme = if cfg.gatewayTls then "wss" else "ws";
  gatewayUrl = "${gatewayScheme}://${cfg.gatewayHost}:${toString cfg.gatewayPort}";
  bundledPluginsDir = "${openclawGatewayPkg}/lib/openclaw/extensions";
  openclawConfig = builtins.toJSON {
    gateway = {
      mode = "remote";
      remote = {
        url = gatewayUrl;
      };
    };

    browser = {
      enabled = true;
      defaultProfile = "openclaw";
      headless = false;
      noSandbox = false;
      executablePath = "${pkgs.chromium}/bin/chromium";
    };

    nodeHost = {
      browserProxy = {
        enabled = true;
        allowProfiles = [ "openclaw" ];
      };
    };
  };
in
{
  options.nixos.openclaw-node = {
    enable = lib.mkEnableOption "OpenClaw node host";

    displayName = lib.mkOption {
      type = lib.types.str;
      default = "NixOS MiniPC";
      description = "Display name for this node in the gateway";
    };

    gatewayHost = lib.mkOption {
      type = lib.types.str;
      default = "cyanpi.tail181cc6.ts.net";
      description = "Hostname of the remote OpenClaw gateway";
    };

    gatewayPort = lib.mkOption {
      type = lib.types.port;
      default = 443;
      description = "Port of the remote OpenClaw gateway";
    };

    gatewayTls = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to connect to the remote OpenClaw gateway over TLS";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.openclaw ];

    home-manager.users.cyan.imports = [
      (
        { lib, ... }:
        {
          # The nix-openclaw package ships bundled plugin manifests under
          # lib/openclaw/extensions, so point OpenClaw there explicitly.
          home.file.".openclaw/.env".text = ''
            OPENCLAW_BUNDLED_PLUGINS_DIR=${bundledPluginsDir}
          '';

          home.activation.cleanupOpenclawTokenArtifacts = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
            rm -f "$HOME/.secrets/openclaw-gateway-token"
          '';

          home.activation.cleanupLegacyOpenclawGatewayService = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
            service_file="$HOME/.config/systemd/user/openclaw-gateway.service"

            if [ -e "$service_file" ]; then
              ${pkgs.systemd}/bin/systemctl --user disable --now openclaw-gateway.service >/dev/null 2>&1 || true
              rm -f "$service_file"
              ${pkgs.systemd}/bin/systemctl --user daemon-reload >/dev/null 2>&1 || true
            fi
          '';

          # Systemd user service — runs as the `cyan` user
          # Starts after the network is up so the remote gateway is reachable
          systemd.user.services.openclaw-node = {
            Unit = {
              Description = "OpenClaw Node Host";
              After = [ "network-online.target" ];
              Wants = [ "network-online.target" ];
            };
            Service = {
              Type = "simple";
              ExecStart = "${pkgs.openclaw}/bin/openclaw node run --host ${cfg.gatewayHost} --port ${toString cfg.gatewayPort}${lib.optionalString cfg.gatewayTls " --tls"} --display-name \"${cfg.displayName}\"";
              Restart = "always";
              RestartSec = "5s";
              Environment = [
                "OPENCLAW_STATE_DIR=/home/cyan/.openclaw"
                "OPENCLAW_CONFIG_PATH=/home/cyan/.openclaw/openclaw.json"
                "OPENCLAW_BUNDLED_PLUGINS_DIR=${bundledPluginsDir}"
              ];
            };
            Install = {
              WantedBy = [ "default.target" ];
            };
          };
        }
      )
    ];
  };
}
