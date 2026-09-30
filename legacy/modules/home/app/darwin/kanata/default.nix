{
  lib,
  config,
  pkgs,
  ...
}:

{
  options = {
    app.darwin.kanata.enable = lib.mkEnableOption "enables kanata keyboard remapper";
  };

  config = lib.mkIf config.app.darwin.kanata.enable {
    # Configure kanata keyboard config file
    xdg.configFile."kanata/kanata.kbd" = {
      source = ./config/kanata.kbd;
    };
  };
}
