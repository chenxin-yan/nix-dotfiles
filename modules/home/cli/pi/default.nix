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
        export NPM_CONFIG_PREFIX="$HOME/.pi/agent/npm"
        exec ${pkgs.nodejs}/bin/npm "$@"
      '';
      hypa = pkgs.writeShellScriptBin "hypa" ''
        exec ${pkgs.nodejs}/bin/node "$HOME/.pi/agent/npm/lib/node_modules/@hypabolic/pi-hypa/node_modules/@hypabolic/hypa/bin.js" "$@"
      '';

      agentSources = import ../../agents/sources.nix { inherit pkgs; };
      inherit (agentSources) ponytail;

      # Single source of truth for declarative pi npm packages. The
      # settings.json `packages` list, the cleanup allowlist, and the
      # install activation hook are all derived from this one list — add or
      # remove a package here and nowhere else. Names are bare (no `npm:`
      # prefix); the prefix is added for the settings.json `packages` field.
      piPackages = [
        # Multi-agent orchestration: subagent tool, builtin agents
        # (scout/planner/worker/reviewer/researcher/oracle/...), and
        # /run-chain. Per-role model overrides live in subagents.agentOverrides.
        "pi-subagents"
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
        # Codex ChatGPT subscription usage. /codex-status shows 5h/weekly
        # rate-limit bars; auto-refreshes a compact statusline item while
        # the selected model provider is openai-codex. No Codex CLI needed.
        "@narumitw/pi-codex-usage"
        # OpenAI fast-mode package from pi.dev. The gallery URL's
        # `name=fast mode` query is display metadata; the declarative source
        # is the npm package name here, with `npm:` added in settings.json.
        "@diegopetrucci/pi-openai-fast"
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
        # Autonomous goal mode. /goal <objective> drives guarded
        # continuation prompts each idle turn until the agent calls the
        # goal_complete tool, the budget is hit, or the user pauses. Goal
        # state lives in session entries (restored on /reload).
        "@narumitw/pi-goal"
        # /rewind checkpoint navigation and /checkpoint storage manager.
        "@ayulab/pi-rewind"
      ];
      piPackagesStr = lib.concatStringsSep " " piPackages;
    in
    lib.mkIf config.cli.pi.enable {
      home.packages = with pkgs; [
        pi-coding-agent
        hypa
        # Time-tracking daemon invoked by the npm:pi-wakatime extension
        # below. Reads ~/.wakatime.cfg for `api_key` (file is hand-managed
        # outside Nix; predates this dotfiles repo).
        wakatime-cli
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
          # GPT-5.5 (ChatGPT subscription path) is the primary model. It's
          # already in pi's built-in registry, so the openai-codex variant
          # needs no custom models.json overlay. Anthropic stays on the side
          # via enabledModels and the subagent overrides below.
          defaultModel = "gpt-5.5";
          # Keep `high` on the parent: it edits code directly most of the
          # time in this workflow rather than purely orchestrating. gpt-5.5
          # supports `xhigh` for difficult / long-running tasks — bump
          # per-session via Ctrl+T when warranted. Subagents pin their own
          # thinking levels below.
          defaultThinkingLevel = "high";
          # Ctrl+P cycle list. GPT first (primary), Anthropic on the side.
          enabledModels = [
            "openai-codex/gpt-5.5"
            "anthropic/claude-opus-4-8"
          ];
          # Pi shells out to npm for `pi install npm:...`. Under Nix, the
          # default global prefix points into the read-only Node store path, so
          # use a tiny wrapper that redirects npm's global prefix to a writable
          # location under ~/.pi/agent/.
          npmCommand = [ "${piNpm}/bin/pi-npm" ];
          # Declarative package list, derived from the let-bound
          # `piPackages` source of truth above. Pi loads
          # extensions/skills/prompts/themes from each entry's manifest.
          # settings.json is a read-only Nix store symlink, so
          # `pi install npm:...` can't write here; the install activation
          # hook below ensures the npm artifacts exist under
          # ~/.pi/agent/npm/. The `npm:` prefix is REQUIRED — without it
          # pi's parseSource() falls through to the local-path branch and
          # silently drops the package.
          packages = map (p: "npm:${p}") piPackages;
          # As of pi-subagents (current), builtins inherit the user's default
          # model unless overridden — they no longer hardcode `openai-codex/*`.
          # We still pin per-role models declaratively so a future
          # pi-subagents update can't silently change cost/quality/latency.
          #
          # Mixing model families is intentional: the value of subagents comes
          # partly from getting a *different perspective* on the same problem.
          # `oracle` in particular exists to disagree with the parent, so it
          # runs on a different family than the default model.
          #
          # Role → model mapping. Each model is the cheapest tier whose
          # known strengths match the role's failure cost.
          #
          # - gpt-5.5   → planner, worker. Primary code-writing family;
          #               strong at long-context retrieval and abstract
          #               reasoning.
          # - opus-4-8  → oracle, reviewer. Cross-family second opinion;
          #               edit-quality leader with the lowest hallucination
          #               rate, kept on the review/disagreement roles so a
          #               different family checks the GPT-written code.
          # - sonnet-4-6 → researcher, context-builder, scout. 1M context
          #                window; read-heavy, handoff-synthesis, and recon
          #                over large files all fit. Scout was on haiku-4-5
          #                (cheaper pure-recon) but moved up to sonnet for
          #                higher-fidelity recon on the same family.
          #
          # `thinking` is pinned per-role so a future pi-subagents update
          # can't silently change cost/latency. `fallbackModels` is
          # intentionally not set here: pi-subagents fallbacks fire only on
          # provider/auth/quota errors (not bad output), so they're not a
          # quality escape hatch — adding them would mainly muddy debugging.
          # Revisit if/when an outage actually bites.
          subagents.agentOverrides = {
            scout = {
              model = "anthropic/claude-sonnet-4-6";
            };
            # context-builder writes the handoff that planner/worker consume;
            # bad context poisons the whole chain, so spend reasoning here.
            "context-builder" = {
              model = "anthropic/claude-sonnet-4-6";
              thinking = "high";
            };
            planner = {
              model = "openai-codex/gpt-5.5";
              thinking = "high";
            };
            worker = {
              model = "openai-codex/gpt-5.5";
              thinking = "high";
            };
            reviewer = {
              model = "anthropic/claude-opus-4-8";
              thinking = "high";
            };
            # researcher is read-heavy; Sonnet's 1M context does the lifting,
            # not reasoning depth. Start at medium and let hard research
            # tasks be explicitly escalated.
            researcher = {
              model = "anthropic/claude-sonnet-4-6";
              thinking = "high";
            };
            oracle = {
              model = "anthropic/claude-opus-4-8";
              thinking = "high";
            };
            # `oracle-executor` was consolidated into `worker` upstream in
            # pi-subagents (see ~/.pi/agent/npm/lib/node_modules/pi-subagents/
            # CHANGELOG.md and the absence of agents/oracle-executor.md).
            # No override needed — `worker` carries the role.
            #
            # `delegate` intentionally has no model override – it inherits the
            # parent's model, which is the whole point of that builtin.
          };
          # Custom theme name (matches `name` field inside the JSON file).
          # Pi auto-discovers theme files from ~/.pi/agent/themes/.
          theme = "catppuccin-mocha";
          # Suppress the built-in logo + keybinding-hints block and the
          # "loaded resources" listing at session start
          # (interactive-mode.js:409, :979). The header container itself is
          # untouched, so the custom-header.ts extension below still renders
          # via setHeader. Net effect: clean startup with our pi mascot,
          # without the wall of keybinding hints. `pi --verbose` overrides
          # this on demand; `/builtin-header` restores upstream header for
          # the current session.
          quietStartup = true;
          # Default tree filter mode. "user-only" mirrors Ctrl+U so you
          # see only your own messages in /tree without having to toggle it
          # every time. Other options: "default", "no-tools", "labeled-only" "labeled-only", "all".
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
        # openai / gpt-5.5 — context-window bump from the built-in 272k
        # to 1.05M (matching the Azure and Cloudflare-gateway variants,
        # which already use 1.05M upstream). Pure override: the rest of
        # the entry stays as the built-in default per docs/models.md
        # "Custom models are upserted by `id` within the provider. If a
        # custom model `id` matches a built-in model `id`, the custom
        # model replaces that built-in model." — we therefore restate
        # the fields we want to keep (api/reasoning/cost/thinkingLevelMap)
        # so the replace doesn't silently drop them.
        ".pi/agent/models.json".text = builtins.toJSON {
          providers = {
            openai = {
              models = [
                {
                  id = "gpt-5.5";
                  name = "GPT-5.5";
                  api = "openai-responses";
                  reasoning = true;
                  thinkingLevelMap = {
                    off = "none";
                    xhigh = "xhigh";
                  };
                  input = [
                    "text"
                    "image"
                  ];
                  cost = {
                    input = 5;
                    output = 30;
                    cacheRead = 0.5;
                    cacheWrite = 0;
                  };
                  contextWindow = 1050000;
                  maxTokens = 128000;
                }
              ];
            };
          };
        };

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
        # hints with a theme-aware pi-mascot banner via
        # ctx.ui.setHeader() on session_start. See the file's header
        # comment for the upstream reference and gotchas. Pairs with
        # `quietStartup = true;` above to give a minimal startup.
        ".pi/agent/extensions/custom-header.ts".source = ./config/extensions/custom-header.ts;

        # TPS + TTFT footer chip. Tracks message_start/message_update/
        # message_end to display time-to-first-token and live tokens/sec
        # for the active assistant turn (with the authoritative
        # `usage.output` value swapped in at message_end). See the file's
        # header comment for measurement details. Renders via
        # ctx.ui.setStatus("tps", ...), so it slots next to the existing
        # extension status chips in the footer without claiming a widget
        # row above the editor.
        ".pi/agent/extensions/tps.ts".source = ./config/extensions/tps.ts;

        # Ponytail pi extension (commands /ponytail, /ponytail-review,
        # /ponytail-help; injects the lazy-dev system prompt per turn when
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
        # ~/.pi/agent/npm/lib/node_modules/pi-subagents/src/agents/agents.ts:134).
        # NOT ~/.pi/agent/agents/ — that's the agent definitions dir, and the
        # loader at agents.ts:547 explicitly skips *.chain.md files there.
        # Run via `/run-chain <name> -- <task>` or natural language.
        ".pi/agent/chains" = {
          source = ./config/chains;
          recursive = true;
        };
      };

      # Bootstrap npm artifacts for the declarative `piPackages` list.
      #
      # Pi resolves global npm packages from
      # `<npmCommand> root -g`/lib/node_modules/<name>. We can't use
      # `pi install npm:...` here because that command also tries to mutate
      # settings.json, which is a read-only Nix store symlink under
      # home-manager. Instead we install via the same npm wrapper directly,
      # which writes only to ~/.pi/agent/npm/. The directory check makes the
      # install loop idempotent.
      #
      # Both the cleanup allowlist and the install loop derive from the single
      # let-bound `piPackages` list — add/remove a package there and
      # `nh os switch`; no manual `rm` and no per-package hook needed.
      #
      # Trailing-slash + symlink footgun: globs like `*/` yield paths with a
      # trailing slash, and `rm -rf foo/` on a symlink-to-dir dereferences the
      # link and tries to delete the target's contents (not the link). For
      # entries that point into the read-only Nix store, that surfaces as a
      # flood of "Permission denied" errors and fails the whole activation. We
      # strip the trailing slash and use `rm` (no `-rf`) for symlinks so we
      # delete the link itself, never its target.
      home.activation.cleanupPiPackages = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        declared="${piPackagesStr}"
        is_declared() {
          for d in $declared; do [ "$d" = "$1" ] && return 0; done
          return 1
        }
        remove_stale() {
          # $1: label for log line, $2: path (no trailing slash)
          local label="$1" path="$2"
          echo "pi-nix: removing stale npm package: $label"
          if [ -L "$path" ]; then
            $DRY_RUN_CMD rm -f "$path"
          else
            $DRY_RUN_CMD rm -rf "$path"
          fi
        }

        node_modules="$HOME/.pi/agent/npm/lib/node_modules"
        if [ -d "$node_modules" ]; then
          # Remove undeclared unscoped packages
          for dir in "$node_modules"/*/; do
            dir="''${dir%/}"
            [ -e "$dir" ] || continue
            pkg=$(basename "$dir")
            case "$pkg" in
              @*) continue ;;
            esac
            is_declared "$pkg" || remove_stale "$pkg" "$dir"
          done
          # Remove undeclared scoped packages (@scope/name), then prune any
          # now-empty @scope/ dir left behind.
          for scope_dir in "$node_modules"/@*/; do
            scope_dir="''${scope_dir%/}"
            [ -d "$scope_dir" ] || continue
            scope=$(basename "$scope_dir")
            for pkg_dir in "$scope_dir"/*/; do
              pkg_dir="''${pkg_dir%/}"
              [ -e "$pkg_dir" ] || continue
              full="$scope/$(basename "$pkg_dir")"
              is_declared "$full" || remove_stale "$full" "$pkg_dir"
            done
            $DRY_RUN_CMD rmdir "$scope_dir" 2>/dev/null || true
          done
        fi
      '';

      # Single install hook: install any declared package whose artifacts are
      # missing. Runs after cleanup so a rename (remove old + add new) settles
      # in one activation.
      home.activation.installPiPackages = lib.hm.dag.entryAfter [ "writeBoundary" "cleanupPiPackages" ] ''
        for pkg in ${piPackagesStr}; do
          if [ ! -d "$HOME/.pi/agent/npm/lib/node_modules/$pkg" ]; then
            $DRY_RUN_CMD ${piNpm}/bin/pi-npm install -g "$pkg"
          fi
        done
      '';

      programs.zsh.shellAliases = {
        p = "pi";
      };
    };
}
