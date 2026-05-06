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
    rev = "d230a6dd6eb1a0dbee9fec55e2f00a96e28dff81";
    hash = "sha256-6GyoLtVWna20TrLg7Y2R6wCWD6C4GbDtIB0jbl5VESY=";
  };

  mattpocockSkills = pkgs.fetchFromGitHub {
    owner = "mattpocock";
    repo = "skills";
    rev = "b27a1a46f80419030e28404ffc8eefb995ea28a5";
    hash = "sha256-y7j1gScBl/dkmUTjw8xqaiHCwNTQdD43GIxumACiGwo=";
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
      source = "${mattpocockSkills}/skills/productivity/grill-me";
      recursive = true;
    };

    home.file.".agents/skills/diagnose" = {
      source = "${mattpocockSkills}/skills/engineering/diagnose";
      recursive = true;
    };

    home.file.".agents/skills/grill-with-docs" = {
      source = "${mattpocockSkills}/skills/engineering/grill-with-docs";
      recursive = true;
    };

    home.file.".agents/skills/improve-codebase-architecture" = {
      source = "${mattpocockSkills}/skills/engineering/improve-codebase-architecture";
      recursive = true;
    };

    home.file.".agents/skills/zoom-out" = {
      source = "${mattpocockSkills}/skills/engineering/zoom-out";
      recursive = true;
    };

    programs.zsh = {
      shellAliases = {
        oc = "opencode";
      };
    };
  };
}
