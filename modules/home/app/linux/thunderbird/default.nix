{
  config,
  pkgs,
  lib,
  ...
}:

{
  options = {
    app.linux.thunderbird.enable = lib.mkEnableOption "enables Thunderbird email client";
  };

  config = lib.mkIf config.app.linux.thunderbird.enable {
    programs.thunderbird = {
      enable = true;

      profiles = {
        default = {
          isDefault = true;

          settings = {
            "extensions.autoDisableScopes" = 0;

            "mailnews.message_display.disable_remote_image" = true;

            "mail.openpgp.allow_external_gnupg" = true;
          };
        };
      };
    };
  };
}
