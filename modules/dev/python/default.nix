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

      # editor
      ruff
      basedpyright
      python313Packages.debugpy
    ];
  };
}
