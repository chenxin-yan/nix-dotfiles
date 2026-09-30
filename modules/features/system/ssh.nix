let
  server.services.openssh.enable = true;
in
{
  features.ssh = {
    darwin = server;
    nixos = server;

    homeManager =
      {
        config,
        lib,
        pkgs,
        ...
      }:
      {
        programs.ssh = {
          enable = true;
          enableDefaultConfig = false;
          settings."github.com" = {
            AddKeysToAgent = "yes";
            IdentityFile = "${config.home.homeDirectory}/.ssh/id_ed25519";
          }
          // lib.optionalAttrs pkgs.stdenv.hostPlatform.isDarwin {
            UseKeychain = "yes";
          };
        };
      };
  };
}
