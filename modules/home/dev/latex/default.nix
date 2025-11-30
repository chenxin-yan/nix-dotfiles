{
  pkgs,
  config,
  lib,
  ...
}:

{
  options = {
    dev.latex.enable = lib.mkEnableOption "enables LaTeX document preparation tools";
  };

  config = lib.mkIf config.dev.latex.enable {
    home.packages = with pkgs; [
      tectonic
    ];
  };
}
