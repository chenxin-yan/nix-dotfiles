{
  config,
  pkgs,
  lib,
  ...
}:

let
  anthropicSkills = pkgs.fetchFromGitHub {
    owner = "anthropics";
    repo = "skills";
    rev = "1ed29a03dc852d30fa6ef2ca53a67dc2c2c2c563";
    hash = "sha256-9FGubcwHcGBJcKl02aJ+YsTMiwDOdgU/FHALjARG51c=";
  };
in
{
  options = {
    cli.opencode.enable = lib.mkEnableOption "enables opencode CLI tool";
  };

  config = lib.mkIf config.cli.opencode.enable {
    home.packages = with pkgs; [
    ];

    programs.opencode = {
      enable = true;
      settings = {
        permission = {
          edit = "ask";
          bash = "ask";
        };
        plugin = [
          "nia-opencode@latest"
        ];
        mode = {
          build = {
            prompt = "You are Claude Code, Anthropic's official CLI for Claude.";
          };
          plan = {
            prompt = "You are Claude Code, Anthropic's official CLI for Claude.";
          };
        };
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

    xdg.configFile."opencode/skills/frontend-design" = {
      source = "${anthropicSkills}/skills/frontend-design";
      recursive = true;
    };

    programs.zsh = {
      shellAliases = {
        oc = "opencode";
      };
    };
  };
}
