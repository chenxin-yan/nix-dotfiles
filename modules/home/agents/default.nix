{
  config,
  lib,
  pkgs,
  ...
}:

let
  sources = import ./sources.nix { inherit pkgs; };
in
{
  options = {
    agents.enable = lib.mkEnableOption "enables shared agent configuration";
  };

  config = lib.mkIf config.agents.enable {
    home.file = {
      ".agents/skills" = {
        source = ./config/skills;
        recursive = true;
      };

      ".agents/skills/frontend-design" = {
        source = "${sources.anthropicSkills}/skills/frontend-design";
        recursive = true;
      };
      ".agents/skills/doc-coauthoring" = {
        source = "${sources.anthropicSkills}/skills/doc-coauthoring";
        recursive = true;
      };
      ".agents/skills/writing-great-skills" = {
        source = "${sources.mattpocockSkills}/skills/productivity/writing-great-skills";
        recursive = true;
      };
      ".agents/skills/webapp-testing" = {
        source = "${sources.anthropicSkills}/skills/webapp-testing";
        recursive = true;
      };
      ".agents/skills/pdf" = {
        source = "${sources.anthropicSkills}/skills/pdf";
        recursive = true;
      };

      ".agents/skills/ponytail" = {
        source = "${sources.ponytail}/skills/ponytail";
        recursive = true;
      };
      ".agents/skills/ponytail-review" = {
        source = "${sources.ponytail}/skills/ponytail-review";
        recursive = true;
      };
      ".agents/skills/ponytail-help" = {
        source = "${sources.ponytail}/skills/ponytail-help";
        recursive = true;
      };

      ".agents/skills/diagnosing-bugs" = {
        source = "${sources.mattpocockSkills}/skills/engineering/diagnosing-bugs";
        recursive = true;
      };
      ".agents/skills/teach" = {
        source = "${sources.mattpocockSkills}/skills/productivity/teach";
        recursive = true;
      };

      ".agents/skills/raindrop-investigate" = {
        source = "${sources.raindropSkills}/raindrop-investigate";
        recursive = true;
      };
      ".agents/skills/raindrop-setup" = {
        source = "${sources.raindropSkills}/raindrop-setup";
        recursive = true;
      };
      ".agents/skills/instrument-agent" = {
        source = "${sources.raindropWorkshop}/skills/instrument-agent";
        recursive = true;
      };
      ".agents/skills/setup-agent-replay" = {
        source = "${sources.raindropWorkshop}/skills/setup-agent-replay";
        recursive = true;
      };
    };
  };
}
