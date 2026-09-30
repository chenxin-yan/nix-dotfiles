{
  features.iina.homeManager =
    { pkgs, lib, ... }:
    {
      # macOS-only app; selecting it elsewhere is a no-op.
      home.packages = lib.optionals pkgs.stdenv.hostPlatform.isDarwin [ pkgs.iina ];
    };
}
