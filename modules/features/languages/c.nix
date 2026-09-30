{
  features.c.homeManager =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        clang-tools
        gcc
      ];
    };
}
