# Hermes Agent: the messaging gateway, as a user service of the login. State stays mutable in ~/.hermes; Nix owns the package, the
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
      {
        imports = [ inputs.hermes-agent.homeManagerModules.default ];

        # Activation copies the secret into ~/.hermes/.env, and a changed
        # secret alone doesn't rerun it. Tying the unit to the secrets file
        # makes a new value reach .env and restarts it.
        systemd.user.services.hermes-agent.Unit.X-Restart-Triggers = [
          osConfig.sops.secrets.hermes-env.sopsFileHash
        ];

        programs.hermes-agent.enable = true;

        services.hermes-agent = {
          enable = true;
          gateway.enable = true;
          environmentFiles = [ osConfig.sops.secrets.hermes-env.path ];
          environment.AGENT_BROWSER_EXECUTABLE_PATH = "${pkgs.chromium}/bin/chromium";
          # Tools its skills call. agent-browser drives the local Chromium;
          # without it on PATH, Hermes downloads a generic-Linux build that
          # NixOS can't run.
          extraPackages = with pkgs; [
            agent-browser
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
