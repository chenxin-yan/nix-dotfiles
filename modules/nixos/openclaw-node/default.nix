{ lib, config, pkgs, ... }:

let
  cfg = config.nixos.openclaw-node;

  openclawConfig = builtins.toJSON {
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

    tokenFile = lib.mkOption {
      type = lib.types.str;
      description = "Path to file containing the gateway auth token";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.openclaw ];

    home-manager.users.cyan.home.file.".openclaw/openclaw.json".text = openclawConfig;

    # Systemd user service — runs as the `cyan` user
    # Starts after Tailscale is up so the gateway URL is reachable
    home-manager.users.cyan.systemd.user.services.openclaw-node = {
      Unit = {
        Description = "OpenClaw Node Host";
        After = [ "network-online.target" ];
        Wants = [ "network-online.target" ];
      };
      Service = {
        Type = "simple";
        ExecStart = "${pkgs.openclaw}/bin/openclaw node run --host cyanpi.tail181cc6.ts.net --port 443 --tls --display-name \"${cfg.displayName}\"";
        Restart = "always";
        RestartSec = "5s";
        EnvironmentFile = cfg.tokenFile;
        Environment = [
          "OPENCLAW_STATE_DIR=/home/cyan/.openclaw"
          "OPENCLAW_CONFIG_PATH=/home/cyan/.openclaw/openclaw.json"
        ];
      };
      Install = {
        WantedBy = [ "default.target" ];
      };
    };
  };
}
