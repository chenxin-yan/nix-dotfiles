{
  features.go.homeManager =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        # editor
        gopls
        gofumpt
        gotools
      ];

      programs.go.enable = true;
    };
}
