{
  features.python.homeManager =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        python313
        uv
        python313Packages.uvicorn

        # editor
        ruff
        basedpyright
      ];

      programs.uv.enable = true;

      home.sessionPath = [ "$HOME/.local/bin" ];
    };
}
