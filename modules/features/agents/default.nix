{ config, ... }:
let
  claudeToken = import ./_claude-token.nix;
in
{
  features.agents.includes = with config.features; [ pi ];
  features.agents.darwin = claudeToken.declareSecret;
  features.agents.nixos = claudeToken.declareSecret;

  features.agents.homeManager =
    {
      config,
      osConfig,
      pkgs,
      lib,
      ...
    }:
    let
      sources = import ./_sources.nix { inherit pkgs; };
      ponytailSkills = [
        "ponytail"
        "ponytail-review"
        "ponytail-audit"
        "ponytail-debt"
        "ponytail-gain"
        "ponytail-help"
      ];
      ponytailSkillFiles = lib.listToAttrs (
        map (
          s:
          lib.nameValuePair ".agents/skills/${s}" {
            source = "${sources.ponytail}/skills/${s}";
            recursive = true;
          }
        ) ponytailSkills
      );
      # Ponytail's always-on ruleset for Codex, which only gets its skills.
      # Pi and Claude Code get it from their plugin hooks, so it stays out of
      # the shared AGENTS.md.
      instructions = pkgs.concatText "AGENTS.md" [
        ./config/AGENTS.md
        "${sources.ponytail}/AGENTS.md"
      ];
    in
    {
      programs.claude-code = {
        enable = true;
        # Claude Code prefers this over its own /login.
        package = claudeToken.wrap { inherit pkgs osConfig; } "CLAUDE_CODE_OAUTH_TOKEN" pkgs.claude-code;
        context = ./config/AGENTS.md;
        # Claude Code writes settings.json itself (/config, /model, plugin
        # state), so declared keys are merged in at activation instead.
        mutableSettings = true;
        # Claude Code installs enabled plugins from this marketplace on launch,
        # reading them in place from the pinned store path.
        marketplaces.ponytail = sources.ponytail;
        settings = {
          model = "opus[1m]";
          effortLevel = "high";
          enabledPlugins."ponytail@ponytail" = true;
          # The plugin brings its hooks (levels, subagent rules, band); its
          # skills would duplicate the ~/.agents/skills copies shared with pi
          # and Codex. A bare name would turn off both copies. Cost: the band's
          # level/review/audit buttons call the plugin's copies and do nothing.
          skillOverrides = lib.genAttrs (map (s: "ponytail:${s}") ponytailSkills) (_: "off");
          env = {
            DISABLE_TELEMETRY = "1";
            DISABLE_ERROR_REPORTING = "1";
          };
          # herdr's Claude integration, pinned to the installed herdr instead
          # of `herdr integration install claude`.
          hooks.SessionStart = [
            {
              matcher = "^(startup|resume|clear|compact|fork)$";
              hooks = [
                {
                  type = "command";
                  command = "bash '${config.programs.claude-code.configDir}/hooks/herdr-agent-state.sh' session";
                  timeout = 10;
                }
              ];
            }
          ];
        };
        hooks."herdr-agent-state.sh" = "${pkgs.herdr}/share/herdr/integrations/claude/herdr-agent-state.sh";
        # Pi's researcher and evidence-auditor roles; Claude's built-in
        # Explore and general-purpose agents cover scout and worker.
        agentsDir = ./config/claude-agents;
      };

      # Codex reads skills from ~/.agents/skills natively. Auth: `codex login`.
      programs.codex.enable = true;

      home.file = ponytailSkillFiles // {
        # programs.codex.context would need an eval-time read of the pinned source.
        ".codex/AGENTS.md".source = instructions;

        ".agents/skills" = {
          source = ./config/skills;
          recursive = true;
        };
        ".claude/skills".source =
          config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.agents/skills";

        ".agents/skills/doc-coauthoring" = {
          source = "${sources.anthropicSkills}/skills/doc-coauthoring";
          recursive = true;
        };
        ".agents/skills/frontend-design" = {
          source = "${sources.anthropicSkills}/skills/frontend-design";
          recursive = true;
        };
        ".agents/skills/web-design-guidelines" = {
          source = "${sources.vercelSkills}/skills/web-design-guidelines";
          recursive = true;
        };
        ".agents/skills/writing-for-agents" = {
          source = "${sources.mattpocockSkills}/skills/productivity/writing-for-agents";
          recursive = true;
        };
        ".agents/skills/typescript-best-practices" = {
          source = "${sources.pstack}/skills/typescript-best-practices";
          recursive = true;
        };
        ".agents/skills/principle-type-system-discipline" = {
          source = "${sources.pstack}/skills/principle-type-system-discipline";
          recursive = true;
        };
        ".agents/skills/principle-boundary-discipline" = {
          source = "${sources.pstack}/skills/principle-boundary-discipline";
          recursive = true;
        };
        ".agents/skills/technical-writing" = {
          source = "${sources.pstack}/skills/technical-writing";
          recursive = true;
        };
        ".agents/skills/unslop" = {
          source = "${sources.pstack}/skills/unslop";
          recursive = true;
        };
        ".agents/skills/benchmark-checklist" = {
          source = "${sources.pstack}/skills/benchmark-checklist";
          recursive = true;
        };
        ".agents/skills/principle-explain-the-number" = {
          source = "${sources.pstack}/skills/principle-explain-the-number";
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
        ".agents/skills/skill-creator" = {
          source = "${sources.anthropicSkills}/skills/skill-creator";
          recursive = true;
        };
        ".agents/skills/herdr" = {
          source = "${pkgs.herdr}/share/skills/herdr/herdr";
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
        ".agents/skills/implement-spec" = {
          source = "${sources.mattpocockSkills}/skills/engineering/implement-spec";
          recursive = true;
        };
        ".agents/skills/improve-codebase-architecture" = {
          source = "${sources.mattpocockSkills}/skills/engineering/improve-codebase-architecture";
          recursive = true;
        };
        ".agents/skills/pr" = {
          source = "${sources.mattpocockSkills}/skills/engineering/pr";
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
        ".agents/skills/retro" = {
          source = "${sources.mattpocockSkills}/skills/engineering/retro";
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
        ".agents/skills/wizard" = {
          source = "${sources.mattpocockSkills}/skills/engineering/wizard";
          recursive = true;
        };
        ".agents/skills/teach" = {
          source = "${sources.mattpocockSkills}/skills/productivity/teach";
          recursive = true;
        };
        ".agents/skills/to-questionnaire" = {
          source = "${sources.mattpocockSkills}/skills/productivity/to-questionnaire";
          recursive = true;
        };
        ".agents/skills/wait-what" = {
          source = "${sources.mattpocockSkills}/skills/productivity/wait-what";
          recursive = true;
        };

        ".agents/skills/narrow-react-prop-types" = {
          source = "${sources.humanlayerSkills}/plugins/narrow-react-prop-types/skills/narrow-react-prop-types";
          recursive = true;
        };
        ".agents/skills/show-me" = {
          source = "${sources.humanlayerSkills}/plugins/show-me/skills/show-me";
          recursive = true;
        };

        ".agents/skills/untangle-codebase" = {
          source = "${sources.caldoSkills}/skills/untangle-codebase";
          recursive = true;
        };
        ".agents/skills/prune-tests" = {
          source = "${sources.caldoSkills}/skills/prune-tests";
          recursive = true;
        };

      };
    };
}
