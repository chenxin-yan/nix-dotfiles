{
  features.wechat.homeManager =
    { pkgs, lib, ... }:
    {
      home.packages = [ pkgs.wechat ];

      # Sparkle would try to replace the read-only Nix store app.
      targets.darwin.defaults."com.tencent.xinWeChat" = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
        SUEnableAutomaticChecks = false;
        SUAutomaticallyUpdate = false;
      };
    };
}
