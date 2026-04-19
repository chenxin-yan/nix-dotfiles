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
      wakatime-cli
      opencode-desktop
    ];

    programs.opencode = {
      enable = true;
      tui = {
        theme = "catppuccin";
      };
      settings = {
        permission = {
          edit = "ask";
          bash = {
            "*" = "ask";
            "git *" = "allow";
            "cd *" = "allow";
            "ls *" = "allow";
            "find *" = "allow";
            "head *" = "allow";
            "tail *" = "allow";
            "echo *" = "allow";
            "cat *" = "allow";
            "npm *" = "allow";
            "bun *" = "allow";
            "pnpm *" = "allow";
            "grep *" = "allow";
            "rg *" = "allow";
            "nia *" = "allow";
          };
        };
        plugin = [
          "opencode-wakatime"
        ];
        agent = {
          explore = {
            model = "anthropic/claude-sonnet-4-5";
          };
          general = {
            model = "anthropic/claude-sonnet-4-5";
          };
        };
        provider = {
          concentrate = {
            npm = "@ai-sdk/openai-compatible";
            name = "Concentrate AI";
            options = {
              baseURL = "https://api.concentrate.ai/v1";
            };
            models = {
              kimi-k2-5 = {
                name = "Kimi K2.5";
              };
            };
          };
          cursor = {
            name = "Cursor";
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

    home.file.".agents/skills/frontend-design" = {
      source = "${anthropicSkills}/skills/frontend-design";
      recursive = true;
    };

    home.file.".agents/skills/doc-coauthoring" = {
      source = "${anthropicSkills}/skills/doc-coauthoring";
      recursive = true;
    };

    home.file.".agents/skills/refine-plan" = {
      source = ./config/skills/refine-plan;
      recursive = true;
    };

    home.file.".claude/skills/frontend-design" = {
      source = "${anthropicSkills}/skills/frontend-design";
      recursive = true;
    };

    home.file.".claude/skills/doc-coauthoring" = {
      source = "${anthropicSkills}/skills/doc-coauthoring";
      recursive = true;
    };

    home.file.".claude/skills/refine-plan" = {
      source = ./config/skills/refine-plan;
      recursive = true;
    };

    programs.zsh = {
      shellAliases = {
        oc = "opencode";
      };
    };
  };
}
