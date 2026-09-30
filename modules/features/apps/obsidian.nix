{
  features.obsidian.homeManager =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.obsidian ];
    };
}
