{
  features.vesktop.homeManager = {
    programs.vesktop = {
      enable = true;

      settings = {
        disableMinSize = true;
        staticTitle = true;
      };

      vencord = {
        settings = {
          autoUpdateNotification = false;
          disableMinSize = true;
          plugins = {
            MessageLogger = {
              enabled = true;
              ignoreSelf = true;
            };
            AlwaysTrust = {
              enabled = true;
            };
          };
        };
        # Discord updates independently of Nix; keep Vencord's compatibility fixes current.
        useSystem = false;
      };
    };
  };
}
