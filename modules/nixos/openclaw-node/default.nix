{ lib, config, pkgs, ... }:

let
  cfg = config.nixos.openclaw-node;
in
{
  options.nixos.openclaw-node = {
    enable = lib.mkEnableOption "OpenClaw node host";

    gatewayUrl = lib.mkOption {
      type = lib.types.str;
      default = "https://cyanpi.tail181cc6.ts.net";
      description = "URL of the OpenClaw gateway on the Pi";
    };

    displayName = lib.mkOption {
      type = lib.types.str;
      default = "NixOS Browser Node";
      description = "Display name for this node in the gateway";
    };

    tokenFile = lib.mkOption {
      type = lib.types.str;
      description = "Path to file containing the gateway auth token";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.openclaw ];

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
        ExecStart = "${pkgs.openclaw}/bin/openclaw node run --host ${cfg.gatewayUrl} --display-name \"${cfg.displayName}\"";
        Restart = "on-failure";
        RestartSec = "15s";
        EnvironmentFile = cfg.tokenFile;
      };
      Install = {
        WantedBy = [ "default.target" ];
      };
    };
  };
}
