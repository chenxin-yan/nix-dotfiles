{
  features.iina.homeManager =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.iina ];
    };
}
