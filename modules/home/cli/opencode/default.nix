{
  config,
  pkgs,
  lib,
  ...
}:

{
  options = {
    cli.opencode.enable = lib.mkEnableOption "enables opencode CLI tool";
  };

  config = lib.mkIf config.cli.opencode.enable {
    programs.opencode = {
      enable = true;
      settings = {
        permission = {
          edit = "ask";
          bash = "ask";
        };
        mcp = {
          context7 = {
            "type" = "local";
            "command" = [
              "npx"
              "-y"
              "@upstash/context7-mcp"
            ];
            "enabled" = true;
          };
        };
      };
    };

    xdg.configFile."opencode" = {
      source = ./config;
      recursive = true;
    };

    programs.zsh = {
      shellAliases = {
        oc = "opencode";
      };
    };
  };
}
