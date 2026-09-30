{
  features.iina.homeManager =
    { pkgs, ... }:
    {
      # The nixpkgs `iina` package fetches the official signed IINA.dmg and
      # unpacks it; home-manager's targets.darwin.linkApps default makes it
      # discoverable in Spotlight via ~/Applications/Home Manager Apps/.
      home.packages = [ pkgs.iina ];
    };
}
