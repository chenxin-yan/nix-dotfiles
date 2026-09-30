{
  features.iina.homeManager =
    { pkgs, lib, ... }:
    {
      home.packages = lib.optionals pkgs.stdenv.hostPlatform.isDarwin [ pkgs.iina ];
    };
}
