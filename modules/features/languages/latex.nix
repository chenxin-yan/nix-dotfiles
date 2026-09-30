{
  features.latex.homeManager =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        tectonic
      ];
    };
}
