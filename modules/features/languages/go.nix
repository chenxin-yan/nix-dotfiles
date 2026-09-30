{
  features.go.homeManager =
    { pkgs, lib, ... }:
    {
      home.packages = with pkgs; [
        # editor
        gopls
        gofumpt
        (lib.meta.lowPrio gotools)
      ];

      programs.go.enable = true;
    };
}
