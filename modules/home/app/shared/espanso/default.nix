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
              trigger = ";td";
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

    xdg.configFile."espanso/match/sensitive.yml" = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.dotfiles-private}/espanso/sensitive.yml";
    };
  };
}
