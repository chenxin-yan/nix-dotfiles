{
  features.sql.homeManager =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        sqlit-tui

        # editor
        sqlfluff
      ];

      xdg.configFile."sqlit/settings.json".text = builtins.toJSON {
        theme = "catppuccin-mocha";
      };
    };
}
