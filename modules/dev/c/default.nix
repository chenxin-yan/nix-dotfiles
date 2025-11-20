{
  pkgs,
  lib,
  config,
  ...
}:

{
  options = {
    dev.c.enable = lib.mkEnableOption "enables c development tools";
  };

  config = lib.mkIf config.dev.c.enable {
    home.packages = with pkgs; [
      clang-tools
      gcc
    ];
  };
}
