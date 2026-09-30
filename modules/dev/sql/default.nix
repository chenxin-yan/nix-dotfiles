{
  features.sql.homeManager =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        sqlit-tui

        # editor
        sqlfluff
      ];

      xdg.configFile."sqlit/settings.json".source = ./config/settings.json;
    };
}
