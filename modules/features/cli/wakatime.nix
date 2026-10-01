{ config, ... }:
let
  declareSecret =
    { host, ... }:
    {
      sops.secrets.wakatime.owner = host.login;
    };
in
{
  features.wakatime = {
    includes = [ config.features.secrets ];
    darwin = declareSecret;
    nixos = declareSecret;
    homeManager =
      { osConfig, pkgs, ... }:
      {
        home.packages = [ pkgs.wakatime-cli ];

        # Replaces any hand-written file; an api_key line in it would take
        # precedence over the vault command.
        home.file.".wakatime.cfg" = {
          force = true;
          text = ''
            [settings]
            api_key_vault_cmd = ${pkgs.coreutils}/bin/cat ${osConfig.sops.secrets.wakatime.path}
            debug = false
            hidefilenames = false
            ignore =
                COMMIT_EDITMSG$
                PULLREQ_EDITMSG$
                MERGE_MSG$
                TAG_EDITMSG$
          '';
        };
      };
  };
}
