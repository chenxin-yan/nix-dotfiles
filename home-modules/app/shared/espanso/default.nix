{
  config,
  pkgs,
  lib,
  ...
}:

{
  options = {
    app.shared.espanso.enable = lib.mkEnableOption "enables espanso text expander";
  };

  config = lib.mkIf config.app.shared.espanso.enable {
    services.espanso = {
      enable = true;

      waylandSupport = pkgs.stdenv.isLinux;

      configs = {
        default = {
          search_trigger = "off";
          auto_restart = true;
          undo_backspace = true;
        };
      };

      matches = {
        base = {
          matches = [
            {
              trigger = ":espanso";
              replace = "Hi there!";
            }
            {
              trigger = ":date";
              replace = "{{mydate}}";
              vars = [
                {
                  name = "mydate";
                  type = "date";
                  params = {
                    format = "%Y-%m-%d";
                  };
                }
              ];
            }
          ];
        };
      };
    };
  };
}
