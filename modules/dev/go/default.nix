{
  pkgs,
  lib,
  config,
  ...
}:

{
  options = {
    dev.go.enable = lib.mkEnableOption "enables Go development tools";
  };

  config = lib.mkIf config.dev.go.enable {
    home.packages = with pkgs; [
      # editor
      gopls
      gofumpt
      gotools
      delve
    ];

    programs.go.enable = true;
  };
}
