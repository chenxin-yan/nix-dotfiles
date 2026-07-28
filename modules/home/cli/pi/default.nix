{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:

{
  options = {
    cli.pi.enable = lib.mkEnableOption "enables pi coding agent CLI";
  };

  config =
    let
      piNpm = pkgs.writeShellScriptBin "pi-npm" ''
        export PATH="${pkgs.nodejs}/bin:$PATH"
        exec ${pkgs.nodejs}/bin/npm "$@"
      '';
      hypa = pkgs.writeShellScriptBin "hypa" ''
        exec "$HOME/.pi/agent/npm/node_modules/.bin/hypa" "$@"
      '';

      agentSources = import ../../agents/sources.nix { inherit pkgs; };
      inherit (agentSources) ponytail;

      # Single source of truth for declarative pi npm packages. Names are
      # bare here; the `npm:` prefix is added for settings.json below.
      piPackages = [
        # Multi-agent orchestration: subagent tool, builtin agents
        # (scout/planner/worker/reviewer/researcher/oracle/...), and
        # /run-chain. Per-role model overrides live in subagents.agentOverrides.
        "pi-subagents"
        # Direct messaging between independently running Pi sessions.
        "pi-intercom"
        # Web search and fetch with pluggable providers (Brave, Tavily,
        # Serper, Exa, Jina, Firecrawl, self-hosted SearXNG). Provides
        # `web_search` and `web_fetch` tools, plus `/web-search-config`
        # for interactive provider selection. The active provider is
        # persisted to ~/.config/rpiv-web-tools/config.json (chmod 0600);
        # API keys resolve env-var-first (`TAVILY_API_KEY`, `EXA_API_KEY`,
        # `BRAVE_SEARCH_API_KEY`, …) then config file. Run
        # `/web-search-config` once to pick `tavily` — default is `brave`.
        "@juicesharp/rpiv-web-tools"
        # WakaTime time tracking. Reads api_key from ~/.wakatime.cfg
        # (hand-managed plain file outside Nix). Uses the wakatime-cli
        # binary added to home.packages below.
        "pi-wakatime"
        # Todo list tracking with live overlay above the editor. Provides
        # the `todo` tool, `/todos` command, and `blockedBy` dependency
        # tracking with cycle detection.
        "@juicesharp/rpiv-todo"
        # Side conversation channel — /btw <question> opens a panel where a
        # tool-less clone of the primary model answers from a read-only
        # snapshot of the main transcript. Side answers never pollute the
        # main session.
        "@juicesharp/rpiv-btw"
        # Structured clarifying-question tool — `ask_user_question` presents
        # a tabbed dialog with single/multi-select questions, side-by-side
        # option previews, per-option notes, and a Submit-tab review step.
        "@juicesharp/rpiv-ask-user-question"
        # Background process manager — the `process` tool starts dev servers,
        # test watchers, builds, log tails and keeps the conversation going.
        # /ps panel, /ps:logs, logWatches for runtime stdout/stderr alerts.
        "@aliou/pi-processes"
        # Aggregated token/cost usage stats across all sessions.
        # /usage for table view, /usage --insights for dashboard.
        "@tmustier/pi-usage-extension"
        # Current-account usage across supported model providers.
        "@narumitw/pi-usage"
        # Priority service tier for configured OpenAI and Codex models.
        "@pi-plugins/fast-mode"
        # Vim-style modal editing for Pi's input box. Esc/Ctrl+[ to enter
        # normal mode; covers motions, operators, visual mode basics.
        "pi-vim"
        # Run interactive CLIs (vim, psql, ssh, dev servers, sub-agent CLIs)
        # in a TUI overlay with 4 modes: interactive, hands-free, dispatch,
        # monitor. Commands: /spawn, /attach, /dismiss. Ships an
        # `interactive-shell` skill auto-registered via pi.skills. Runtime
        # dep zigpty ships prebuilt PTY binaries (no node-gyp on install).
        "pi-interactive-shell"
        # MCP adapter: one proxy `mcp` tool plus /mcp setup; reads standard
        # .mcp.json and ~/.config/mcp/mcp.json lazily.
        "pi-mcp-adapter"
        # Local deterministic compression for noisy Pi tool output. Adds
        # /hypa diagnostics plus hypa_shell/read/grep/find/ls tools.
        "@hypabolic/pi-hypa"
        # /rewind checkpoint navigation and /checkpoint storage manager.
        "@ayulab/pi-rewind"
      ]
      ++ lib.optionals pkgs.stdenv.isDarwin [
        # Desktop app observation and control. The NixOS host is headless.
        "@injaneity/pi-computer-use"
      ];
    in
    lib.mkIf config.cli.pi.enable {
      home.packages = with pkgs; [
        pi-coding-agent
        hypa
        # Time-tracking daemon invoked by the npm:pi-wakatime extension
        # below. Reads ~/.wakatime.cfg for `api_key` (file is hand-managed
        # outside Nix; predates this dotfiles repo).
        wakatime-cli
        claude-code
        codex
      ];

      # Disable pi's startup "new version available" toast. The pi binary
      # itself is pinned by Nix, so the upstream npm-registry version check
      # at interactive-mode.js:checkForNewVersion() is pure noise and would
      # nudge us toward `npm i -g` updates that fight the read-only Nix
      # store. We deliberately do NOT set PI_OFFLINE here: that would also
      # silence checkForPackageUpdates() for the npm extensions in
      # `packages` below, and those updates are still useful as a signal
      # to bump our declarative list. Gate logic:
      # interactive-mode.js:528 `if (PI_SKIP_VERSION_CHECK || PI_OFFLINE)`.
      home.sessionVariables = {
        PI_SKIP_VERSION_CHECK = "1";
        # Ponytail default mode. `full` keeps the lazy-dev ruleset injected
        # every turn — it owns the YAGNI/minimal-code philosophy, which has
        # been trimmed out of ../../agents/config/AGENTS.md to avoid duplication
        # (AGENTS.md keeps the non-minimalism guidance: delegation,
        # planning, verification, error handling, single-source-of-truth).
        # Escalate/relax per session with `/ponytail lite|full|ultra` or
        # `stop ponytail`. The env var is ponytail's highest-priority
        # source (over ~/.config/ponytail/config.json), so
        # `/ponytail default <mode>` still writes the file but this wins;
        # the extension reports that override instead of silently ignoring
        # it. See ponytail/hooks/ponytail-config.js:getDefaultMode().
        PONYTAIL_DEFAULT_MODE = "full";
      };

      # Seed global pi settings. Only values that diverge from upstream
      # defaults are listed; everything else is left to pi's defaults.
      #
      # `enabledModels` is the ordered cycle list used by Ctrl+P (and the
      # default model picker on launch). Patterns resolve via
      # `resolveModelScope`: provider-qualified IDs match exactly and are
      # preferred over globs because they avoid pulling in dated variants
      # (e.g. claude-sonnet-4-6-20250929) and unrelated families.
      #
      # Shared agent instructions and ~/.agents/skills live in
      # modules/home/agents; this module only keeps Pi runtime settings.
      home.file = {
        ".pi/agent/settings.json".text = builtins.toJSON {
          defaultProvider = "openai-codex";
          defaultModel = "gpt-5.6-sol";
          # Keep `high` on the parent: it edits code directly most of the
          # time in this workflow rather than purely orchestrating. Subagents
          # pin their own thinking levels below.
          defaultThinkingLevel = "high";
          # Ctrl+P cycle list. Fable 5 is primary; GPT-5.6 Sol is the
          # cross-family alternative.
          enabledModels = [
            "anthropic/claude-fable-5"
            "openai-codex/gpt-5.6-sol"
          ];
          # Pi passes its managed ~/.pi/agent/npm install prefix explicitly;
          # this wrapper only supplies npm from the Nix-managed Node package.
          npmCommand = [ "${piNpm}/bin/pi-npm" ];
          # Pi installs missing entries into its managed npm directory and
          # loads extensions/skills/prompts/themes from each manifest. The
          # `npm:` prefix is required so parseSource() treats these as npm
          # packages rather than local paths.
          packages = map (p: "npm:${p}") piPackages;
          # As of pi-subagents (current), builtins inherit the user's default
          # model unless overridden — they no longer hardcode `openai-codex/*`.
          # We still pin per-role models declaratively so a future
          # pi-subagents update can't silently change cost/quality/latency.
          #
          # Subagents run on the GPT-5.6 family (launched 2026-07-09; Sol
          # tops the AA Coding Agent Index at 80). Mixing model families is
          # intentional: the parent stays on Fable 5, while GPT-5.6 handles
          # delegated work and cross-family review.
          #
          # Role → model mapping (tier matched to job):
          # - gpt-5.6-luna  → scout (fast/cheap recon; weak long-context —
          #                   MRCR 41.3% — fine for small scout contexts).
          # - gpt-5.6-terra → context-builder, researcher (long-context
          #                   MRCR 89.6%, BrowseComp 87.5%).
          # - gpt-5.6-sol   → planner, worker, reviewer, oracle, delegate
          #                   (frontier reasoning, best coding model).
          #
          # `thinking` is pinned per-role so a future pi-subagents update
          # can't silently change cost/latency. `fallbackModels` is
          # intentionally not set here: pi-subagents fallbacks fire only on
          # provider/auth/quota errors (not bad output), so they're not a
          # quality escape hatch — adding them would mainly muddy debugging.
          # Revisit if/when an outage actually bites.
          subagents.agentOverrides = {
            scout = {
              model = "openai-codex/gpt-5.6-luna";
            };
            "context-builder" = {
              model = "openai-codex/gpt-5.6-terra";
              thinking = "high";
            };
            planner = {
              model = "anthropic/claude-fable-5";
              thinking = "high";
            };
            worker = {
              model = "openai-codex/gpt-5.6-sol";
              thinking = "high";
            };
            reviewer = {
              model = "anthropic/claude-fable-5";
              thinking = "high";
            };
            researcher = {
              model = "openai-codex/gpt-5.6-terra";
              thinking = "high";
            };
            oracle = {
              model = "anthropic/claude-fable-5";
              thinking = "high";
            };
            delegate = {
              model = "openai-codex/gpt-5.6-sol";
              thinking = "high";
            };
            # `oracle-executor` was consolidated into `worker` upstream in
            # pi-subagents (see ~/.pi/agent/npm/node_modules/pi-subagents/
            # CHANGELOG.md and the absence of agents/oracle-executor.md).
            # No override needed — `worker` carries the role.
          };
          # Custom theme name (matches `name` field inside the JSON file).
          # Pi auto-discovers theme files from ~/.pi/agent/themes/.
          theme = "catppuccin-mocha";
          # Suppress the built-in logo + keybinding-hints block and the
          # "loaded resources" listing at session start
          # (interactive-mode.js:409, :979). The header container itself is
          # untouched, so the custom-header.ts extension below still renders
          # via setHeader. Net effect: a clean text-only startup header
          # without the wall of keybinding hints. `pi --verbose` overrides
          # this on demand; `/builtin-header` restores upstream header for
          # the current session.
          quietStartup = true;
          # Default tree filter mode. "user-only" mirrors Ctrl+U so you
          # see only your own messages in /tree without having to toggle it
          # every time. Other options: "default", "no-tools", "labeled-only", "all".
          treeFilterMode = "user-only";
          # Disable install telemetry. Pi otherwise sends a single GET to
          # https://pi.dev/install?version=X on the first run after a version
          # change (interactive-mode.js:631). We deliberately do NOT set
          # PI_OFFLINE (it would also silence the useful extension-update
          # checks), so this explicit flag is what actually suppresses the
          # ping.
          enableInstallTelemetry = false;
        };

        # Custom model registry overlay. Pi merges this into its built-in
        # registry on `/model` open (no restart needed) per docs/models.md.
        #
        # openai-codex / gpt-5.6-{sol,terra,luna} — the GPT-5.6 family
        # (GA 2026-07-09) is not in pi 0.80.3's built-in registry, so we add
        # it here. Entries added to a built-in provider inherit its api
        # (openai-codex-responses), baseUrl, and OAuth (see pi's
        # model-registry.js:432 built-in defaults caching), so only model
        # metadata is declared. Notes:
        # - thinkingLevelMap mirrors the built-in codex gpt-5.5 entry
        #   (xhigh→xhigh, minimal→low). GPT-5.6's new `max` effort is left
        #   unmapped — pi's levels stop at xhigh and we keep the mapping
        #   faithful; revisit if pi grows a `max` thinking level.
        # - OpenAI's API models have a 1.05M context window, but the Codex
        #   subscription backend uses 272k per pi 0.80.4's verified metadata.
        # - Input/output/cache-read costs are API-rate estimates for /usage;
        #   Codex itself is subscription-billed and reports no cache writes.
        #
        # openai / gpt-5.5 — context-window bump from the built-in 272k
        # to 1.05M (matching the Azure and Cloudflare-gateway variants,
        # which already use 1.05M upstream). Pure override: the rest of
        # the entry stays as the built-in default per docs/models.md
        # "Custom models are upserted by `id` within the provider. If a
        # custom model `id` matches a built-in model `id`, the custom
        # model replaces that built-in model." — we therefore restate
        # the fields we want to keep (api/reasoning/cost/thinkingLevelMap)
        # so the replace doesn't silently drop them.
        # ".pi/agent/models.json".text = builtins.toJSON {
        # };

        # Catppuccin themes from upstream flake
        # (github:otahontas/pi-coding-agent-catppuccin). We consume the
        # package output directly and skip its Home Manager module, because
        # that module mutates settings.json via an activation hook which
        # conflicts with our declaratively-managed settings.json symlink.
        ".pi/agent/themes/catppuccin-mocha.json".source = "${
          inputs.pi-catppuccin.packages.${pkgs.stdenv.hostPlatform.system}.default
        }/share/pi/themes/catppuccin-mocha.json";

        # Override pi's default keybindings. Pi's history model is
        # branch-on-edit (no destructive undo); these bindings make the
        # branching workflow ergonomic with letter-mnemonic chords.
        # - app.session.resume: ctrl+b ("browse") opens the session picker
        #   without typing /resume. (Unbound upstream.)
        # - app.session.fork: ctrl+f ("fork") branches from the current
        #   point — the pi equivalent of "undo my last message". This
        #   shadows tui.editor.cursorRight's ctrl+f chord, but the right
        #   arrow still works for that.
        # - app.session.tree: ctrl+t ("tree") opens the session tree
        #   navigator. ctrl+t was app.thinking.toggle upstream — we move
        #   that to shift+ctrl+t (capital T = "manage Thinking") so we
        #   keep both behaviors.
        # - app.message.followUp: keep upstream's alt+enter and add
        #   alt+j. Inside zellij, pressing alt+enter inserts a newline
        #   instead of queueing a follow-up. Mechanism: pi probes the
        #   Kitty keyboard protocol on startup; zellij forwards the probe
        #   to ghostty and forwards ghostty's positive reply back to pi,
        #   so pi sets _kittyProtocolActive = true. But zellij itself
        #   does NOT translate keys into Kitty CSI-u — keys arrive in
        #   legacy xterm form. Alt+enter then arrives as \x1b\r, which
        #   pi-tui (keys.ts:1266) maps to "shift+enter" because in real
        #   Kitty terminals \x1b\r is the conventional shift+enter
        #   encoding (alt+enter would arrive as CSI-u \x1b[13;3u). That
        #   matches tui.input.newLine and the editor inserts a newline.
        #   Same shape of bug as the reverted 295420d (zellij forwards a
        #   protocol response it can't honor for keys); pi has no env
        #   var to skip the kitty probe. alt+j survives both legacy
        #   (\x1bj inside zellij) and Kitty CSI-u (\x1b[106;3u in raw
        #   ghostty), and isn't claimed by anything else in pi or by
        #   zellij in its default locked mode. Keep alt+enter so the
        #   binding works in raw ghostty and lights up automatically
        #   once zellij fixes its kitty forwarding (zellij#4333, #5017).
        ".pi/agent/keybindings.json".text = builtins.toJSON {
          "app.session.resume" = "ctrl+b";
          "app.session.fork" = "ctrl+f";
          "app.session.tree" = "ctrl+t";
          "app.thinking.toggle" = "shift+ctrl+t";
          "app.message.followUp" = [
            "alt+enter"
            "alt+j"
          ];
        };

        # Custom startup header. Replaces pi's built-in logo + keybinding
        # hints with a theme-aware text subtitle via ctx.ui.setHeader() on
        # session_start. See the file's header
        # comment for the upstream reference and gotchas. Pairs with
        # `quietStartup = true;` above to give a minimal startup.
        ".pi/agent/extensions/custom-header.ts".source = ./config/extensions/custom-header.ts;

        # Live footer metrics: output throughput for the current assistant
        # message and wall-clock time spent in the current agent run.
        ".pi/agent/extensions/tps-status.ts".source = ./config/extensions/tps-status.ts;
        ".pi/agent/extensions/agent-time.ts".source = ./config/extensions/agent-time.ts;

        # Start each session with the fast-mode package enabled.
        ".pi/agent/extensions/fast-mode.json".text = builtins.toJSON {
          enabled = true;
        };

        # Ponytail pi extension (commands /ponytail, /ponytail-review,
        # /ponytail-audit, /ponytail-debt, /ponytail-gain, /ponytail-help;
        # injects the lazy-dev system prompt per turn when
        # mode != off). A re-export wrapper rather than a direct symlink:
        # ponytail/pi-extension/index.js does `require("../hooks/…")`, so it
        # must be loaded from its real store path for that relative resolve
        # to land on ponytail/hooks/. Symlinking the dir into extensions/
        # would resolve `../hooks` to ~/.pi/agent/extensions/hooks and also
        # tempt pi to load loose hook .js files as extensions. Importing the
        # absolute store path sidesteps both.
        ".pi/agent/extensions/ponytail.js".text = ''
          import ext from "${ponytail}/pi-extension/index.js";
          export default ext;
        '';

        ".pi/agent/AGENTS.md".source = ../../agents/config/AGENTS.md;

        ".pi/agent/prompts" = {
          source = ./config/prompts;
          recursive = true;
        };

        # Predefined chains. pi-subagents discovers user chains from
        # ~/.pi/agent/chains/**/*.chain.md (see
        # ~/.pi/agent/npm/node_modules/pi-subagents/src/agents/agents.ts:134).
        # NOT ~/.pi/agent/agents/ — that's the agent definitions dir, and the
        # loader at agents.ts:547 explicitly skips *.chain.md files there.
        # Run via `/run-chain <name> -- <task>` or natural language.
        ".pi/agent/chains" = {
          source = ./config/chains;
          recursive = true;
        };
      };

      programs.zsh.shellAliases = {
        p = "pi";
      };
    };
}
