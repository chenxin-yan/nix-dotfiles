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
    home.packages = with pkgs; [
      claude-code
    ];

    programs.opencode = {
      enable = true;
      settings = {
        permission = {
          edit = "ask";
          bash = "ask";
        };
        plugin = [ "nia-opencode@latest" ];
        mcp = {
          nia = {
            type = "remote";
            url = "https://apigcp.trynia.ai/mcp";
            headers = {
              Authorization = "Bearer {env:NIA_API_KEY}";
            };
            enabled = true;
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
