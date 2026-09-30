{
  pkgs,
  lib,
  config,
  ...
}:

{
  options = {
    dev.java.enable = lib.mkEnableOption "enables Java development tools";
  };

  config = lib.mkIf config.dev.java.enable {
    home.packages = with pkgs; [
      jdt-language-server
    ];

    programs.java.enable = true;
  };
}
