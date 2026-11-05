{
  features.iina.homeManager =
    { pkgs, lib, ... }:
    lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
      home.packages = [ pkgs.iina ];

      # Sparkle would try to replace the read-only Nix store app.
      targets.darwin.defaults."com.colliderli.iina" = {
        SUEnableAutomaticChecks = false;
        SUAutomaticallyUpdate = false;
      };
    };
}
