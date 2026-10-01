# Hermes Agent: the messaging gateway and the web dashboard, as user services
# of the login. State stays mutable in ~/.hermes; Nix owns the package, the
# units and .env.
{ inputs, config, ... }:
{
  features.hermes = {
    includes = [ config.features.secrets ];

    # Every .env line that isn't a host path, as one dotenv secret: API keys,
    # tokens and the Discord allow-list. They belong to this machine's
    # Hermes, so they live in its own secrets file.
    nixos =
      { config, host, ... }:
      {
        sops.secrets.hermes-env = {
          sopsFile = ../../../secrets/hosts/${config.networking.hostName}.yaml;
          owner = host.login;
        };
      };

    homeManager =
      { osConfig, pkgs, ... }:
      let
        # Activation copies the secret into ~/.hermes/.env, and a changed
        # secret alone doesn't rerun it. Tying the units to the secrets file
        # makes a new value reach .env and restarts both.
        restartOnSecretChange.Unit.X-Restart-Triggers = [
          osConfig.sops.secrets.hermes-env.sopsFileHash
        ];
      in
      {
        imports = [ inputs.hermes-agent.homeManagerModules.default ];

        systemd.user.services.hermes-agent = restartOnSecretChange;
        systemd.user.services.hermes-backend = restartOnSecretChange;

        programs.hermes-agent.enable = true;

        services.hermes-agent = {
          enable = true;
          gateway.enable = true;
          # Only on the tailnet: wait for tailscale0 and bind to its address.
          backend = {
            mode = "dashboard";
            waitFor = "interface";
            interfaceName = "tailscale0";
          };
          environmentFiles = [ osConfig.sops.secrets.hermes-env.path ];
          environment.AGENT_BROWSER_EXECUTABLE_PATH = "${pkgs.chromium}/bin/chromium";
          # Tools its skills call.
          extraPackages = with pkgs; [
            gh
            gogcli
            git
            chromium
            ffmpeg
            nodejs
          ];
        };
      };
  };
}
