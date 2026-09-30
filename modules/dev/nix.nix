{
  features.nix.homeManager =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        nil
        nixfmt
        nixfmt-tree
      ];
    };
}
