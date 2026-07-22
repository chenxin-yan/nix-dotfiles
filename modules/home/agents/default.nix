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
      ".claude/skills".source =
        config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.agents/skills";

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
      ".agents/skills/grill-me" = {
        source = "${sources.mattpocockSkills}/skills/productivity/grill-me";
        recursive = true;
      };
      ".agents/skills/grilling" = {
        source = "${sources.mattpocockSkills}/skills/productivity/grilling";
        recursive = true;
      };
      ".agents/skills/handoff" = {
        source = "${sources.mattpocockSkills}/skills/productivity/handoff";
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
      ".agents/skills/ponytail-audit" = {
        source = "${sources.ponytail}/skills/ponytail-audit";
        recursive = true;
      };
      ".agents/skills/ponytail-debt" = {
        source = "${sources.ponytail}/skills/ponytail-debt";
        recursive = true;
      };
      ".agents/skills/ponytail-gain" = {
        source = "${sources.ponytail}/skills/ponytail-gain";
        recursive = true;
      };
      ".agents/skills/ponytail-help" = {
        source = "${sources.ponytail}/skills/ponytail-help";
        recursive = true;
      };

      ".agents/skills/ask-matt" = {
        source = "${sources.mattpocockSkills}/skills/engineering/ask-matt";
        recursive = true;
      };
      ".agents/skills/code-review" = {
        source = "${sources.mattpocockSkills}/skills/engineering/code-review";
        recursive = true;
      };
      ".agents/skills/codebase-design" = {
        source = "${sources.mattpocockSkills}/skills/engineering/codebase-design";
        recursive = true;
      };
      ".agents/skills/diagnosing-bugs" = {
        source = "${sources.mattpocockSkills}/skills/engineering/diagnosing-bugs";
        recursive = true;
      };
      ".agents/skills/domain-modeling" = {
        source = "${sources.mattpocockSkills}/skills/engineering/domain-modeling";
        recursive = true;
      };
      ".agents/skills/grill-with-docs" = {
        source = "${sources.mattpocockSkills}/skills/engineering/grill-with-docs";
        recursive = true;
      };
      ".agents/skills/implement" = {
        source = "${sources.mattpocockSkills}/skills/engineering/implement";
        recursive = true;
      };
      ".agents/skills/improve-codebase-architecture" = {
        source = "${sources.mattpocockSkills}/skills/engineering/improve-codebase-architecture";
        recursive = true;
      };
      ".agents/skills/prototype" = {
        source = "${sources.mattpocockSkills}/skills/engineering/prototype";
        recursive = true;
      };
      ".agents/skills/research" = {
        source = "${sources.mattpocockSkills}/skills/engineering/research";
        recursive = true;
      };
      ".agents/skills/resolving-merge-conflicts" = {
        source = "${sources.mattpocockSkills}/skills/engineering/resolving-merge-conflicts";
        recursive = true;
      };
      ".agents/skills/setup-matt-pocock-skills" = {
        source = "${sources.mattpocockSkills}/skills/engineering/setup-matt-pocock-skills";
        recursive = true;
      };
      ".agents/skills/tdd" = {
        source = "${sources.mattpocockSkills}/skills/engineering/tdd";
        recursive = true;
      };
      ".agents/skills/to-spec" = {
        source = "${sources.mattpocockSkills}/skills/engineering/to-spec";
        recursive = true;
      };
      ".agents/skills/to-tickets" = {
        source = "${sources.mattpocockSkills}/skills/engineering/to-tickets";
        recursive = true;
      };
      ".agents/skills/triage" = {
        source = "${sources.mattpocockSkills}/skills/engineering/triage";
        recursive = true;
      };
      ".agents/skills/wayfinder" = {
        source = "${sources.mattpocockSkills}/skills/engineering/wayfinder";
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
