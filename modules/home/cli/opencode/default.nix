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
      # opencode-desktop
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
            model = "anthropic/claude-sonnet-4-6";
          };
          general = {
            model = "anthropic/claude-sonnet-4-6";
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
              glm-5 = {
                name = "GLM-5";
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

    home.file.".agents/skills/skill-creator" = {
      source = "${anthropicSkills}/skills/skill-creator";
      recursive = true;
    };

    home.file.".agents/skills/webapp-testing" = {
      source = "${anthropicSkills}/skills/webapp-testing";
      recursive = true;
    };

    home.file.".agents/skills/pdf" = {
      source = "${anthropicSkills}/skills/pdf";
      recursive = true;
    };

    # Matt Pocock skills (https://github.com/mattpocock/skills)
    # `grill-me` replaces the previous local `refine-plan` skill.
    home.file.".agents/skills/grill-me" = {
      source = ./config/skills/grill-me;
      recursive = true;
    };

    home.file.".agents/skills/grill-with-docs" = {
      source = ./config/skills/grill-with-docs;
      recursive = true;
    };

    home.file.".agents/skills/improve-codebase-architecture" = {
      source = ./config/skills/improve-codebase-architecture;
      recursive = true;
    };

    home.file.".agents/skills/zoom-out" = {
      source = ./config/skills/zoom-out;
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

    home.file.".claude/skills/skill-creator" = {
      source = "${anthropicSkills}/skills/skill-creator";
      recursive = true;
    };

    home.file.".claude/skills/webapp-testing" = {
      source = "${anthropicSkills}/skills/webapp-testing";
      recursive = true;
    };

    home.file.".claude/skills/pdf" = {
      source = "${anthropicSkills}/skills/pdf";
      recursive = true;
    };

    home.file.".claude/skills/grill-me" = {
      source = ./config/skills/grill-me;
      recursive = true;
    };

    home.file.".claude/skills/grill-with-docs" = {
      source = ./config/skills/grill-with-docs;
      recursive = true;
    };

    home.file.".claude/skills/improve-codebase-architecture" = {
      source = ./config/skills/improve-codebase-architecture;
      recursive = true;
    };

    home.file.".claude/skills/zoom-out" = {
      source = ./config/skills/zoom-out;
      recursive = true;
    };

    programs.zsh = {
      shellAliases = {
        oc = "opencode";
      };
    };
  };
}
