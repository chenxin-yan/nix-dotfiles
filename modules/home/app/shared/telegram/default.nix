{
  config,
  pkgs,
  lib,
  ...
}:

{
  options = {
    app.shared.telegram.enable = lib.mkEnableOption "enables Telegram Desktop app";
  };

  config = lib.mkIf config.app.shared.telegram.enable {
    home.packages = with pkgs; [
      telegram-desktop
    ];
  };
}
