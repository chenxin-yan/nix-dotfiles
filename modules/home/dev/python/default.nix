{
  pkgs,
  lib,
  config,
  ...
}:

{
  options = {
    dev.python.enable = lib.mkEnableOption "enables Python development tools";
  };

  config = lib.mkIf config.dev.python.enable {
    home.packages = with pkgs; [
      python313
      uv
      python313Packages.uvicorn

      # editor
      ruff
      basedpyright
      python313Packages.debugpy
    ];

    programs.uv.enable = true;

    home.sessionPath = [ "$HOME/.local/bin" ];
  };
}
