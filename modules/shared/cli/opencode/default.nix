{ config, pkgs, ... }:

{
  programs.opencode = {
    enable = true;
    settings = {
      theme = "catppuccin";
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

  home.file = {
    ".config/opencode" = {
      source = ./config;
      recursive = true;
    };
  };
  programs.zsh = {
    shellAliases = {
      oc = "opencode";
    };
  };
}
