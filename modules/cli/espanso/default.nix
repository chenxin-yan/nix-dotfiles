{
  config,
  pkgs,
  lib,
  ...
}:

{
  options = {
    cli.espanso.enable = lib.mkEnableOption "enables espanso text expander";
  };

  config = lib.mkIf config.cli.espanso.enable {
    services.espanso = {
      enable = true;

      waylandSupport = lib.mkIf pkgs.stdenv.isLinux true;
      x11Support = lib.mkIf pkgs.stdenv.isLinux true;

      configs = {
        default = {
          toggle_key = "CTRL+SHIFT+E";
          search_shortcut = "off";
          show_notifications = true;
          backend = "auto";
          clipboard_threshold = 100;
          preserve_clipboard = true;
          undo_backspace = true;
        };
      };

      matches = {
        base = {
          matches = [
            {
              trigger = ";date";
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
            {
              trigger = ";time";
              replace = "{{mytime}}";
              vars = [
                {
                  name = "mytime";
                  type = "date";
                  params = {
                    format = "%H:%M";
                  };
                }
              ];
            }
            {
              trigger = ";now";
              replace = "{{mynow}}";
              vars = [
                {
                  name = "mynow";
                  type = "date";
                  params = {
                    format = "%Y-%m-%d %H:%M:%S";
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
