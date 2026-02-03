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
          search_shortcut = "off";
          auto_restart = true;
          undo_backspace = true;
        };
      };

      matches = {
        base = {
          matches = [
            {
              trigger = ";gh";
              replace = "https://github.com/chenxin-yan";
            }
            {
              trigger = ";linkedin";
              replace = "https://www.linkedin.com/in/chenxin-yan";
            }
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
            # Email addresses
            {
              trigger = ";cy2";
              replace = "cy2558@nyu.edu";
            }
            {
              trigger = ";yanc";
              replace = "yanchenxin2004@gmail.com";
            }
            {
              trigger = ";cxy";
              replace = "cxyan04@gmail.com";
            }
            # ID
            {
              trigger = ";N1";
              replace = "N19351358";
            }
          ];
        };
      };
    };
  };
}
