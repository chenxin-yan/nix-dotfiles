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

  niaSkill = pkgs.fetchFromGitHub {
    owner = "nozomio-labs";
    repo = "nia-skill";
    rev = "ec0064441421838bf696cf529a056be4256be0e3";
    hash = "sha256-qZUgQOzojqCKzJ0SbC/azPC8fOEHIk8+mzZ9L4bf58Y=";
  };
in
{
  options = {
    cli.opencode.enable = lib.mkEnableOption "enables opencode CLI tool";
  };

  config = lib.mkIf config.cli.opencode.enable {
    home.packages = with pkgs; [
      opencode-desktop
    ];

    programs.opencode = {
      enable = true;
      settings = {
        permission = {
          edit = "ask";
          bash = "ask";
        };
        plugin = [
        ];
        agent = {
          explore = {
            model = "anthropic/claude-haiku-4-5";
          };
        };
        mode = {
          build = {
            prompt = "You are Claude Code, Anthropic's official CLI for Claude.";
          };
          plan = {
            prompt = "You are Claude Code, Anthropic's official CLI for Claude.";
          };
        };
        mcp = {
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

    xdg.configFile."opencode/skills/nia" = {
      source = "${niaSkill}";
      recursive = true;
    };

    programs.zsh = {
      shellAliases = {
        oc = "opencode";
      };
    };
  };
}
