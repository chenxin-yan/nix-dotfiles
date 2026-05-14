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

      # Upstream skill repos consumed via the agent-skills.io convention.
      # Each `home.file.".agents/skills/<name>"` entry below symlinks one
      # subdirectory of these snapshots into ~/.agents/skills/, where pi
      # auto-discovers them. Bumping the rev/hash refreshes every skill
      # sourced from that repo in lock-step.
      anthropicSkills = pkgs.fetchFromGitHub {
        owner = "anthropics";
        repo = "skills";
        rev = "d211d437443a7b2496a3dad9575e7dddd724c585";
        hash = "sha256-5NGI0gojBGoXXus8CPhIrigyWSEYJg8gnCzWYl6PsLA=";
      };

      mattpocockSkills = pkgs.fetchFromGitHub {
        owner = "mattpocock";
        repo = "skills";
        rev = "70141119e9fe47430b62b93bcf166a73e6580048";
        hash = "sha256-V7urzcmq2cJDwKP9dLirBAmKuXbVp2Jsyd+3jlzZ5+Y=";
      };
    in
    lib.mkIf config.cli.pi.enable {
      home.packages = with pkgs; [
        pi-coding-agent
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
      # Skills layout (~/.agents/skills/<name>) — pi auto-discovers any
      # SKILL.md under this tree via the agent-skills.io convention.
      #
      # Two sources, both wired up via `home.file` entries below:
      #   1. Upstream repos (anthropics/skills, mattpocock/skills) pinned
      #      via the let-bound `anthropicSkills` / `mattpocockSkills`
      #      fetchers above. Each `home.file` entry points at one
      #      subdirectory of those snapshots.
      #   2. Locally-authored skills owned by this module under
      #      ./config/skills/<name>/SKILL.md. Currently: commit, to-html.
      home.file = {
        ".pi/agent/settings.json".text = builtins.toJSON {
          defaultProvider = "anthropic";
          defaultModel = "claude-opus-4-7";
          # `xhigh` matches Anthropic's new Claude Code default for Opus 4.7
          # (claude.com/blog/best-practices-for-using-claude-opus-4-7-with-claude-code).
          # We keep this on the parent because the parent edits code directly
          # most of the time in this workflow rather than purely orchestrating;
          # subagents already pin their own thinking levels below.
          defaultThinkingLevel = "high";
          # Ctrl+P cycle list. Includes haiku-4-5 even though only `scout`
          # uses it programmatically — keeping it pickable in the TUI makes
          # ad-hoc cheap recon turns one keystroke away.
          enabledModels = [
            "anthropic/claude-opus-4-7"
            "anthropic/claude-sonnet-4-6"
            "openai/gpt-5.5"
          ];
          # Pi shells out to npm for `pi install npm:...`. Under Nix, the
          # default global prefix points into the read-only Node store path, so
          # use a tiny wrapper that redirects npm's global prefix to a writable
          # location under ~/.pi/agent/.
          npmCommand = [ "${piNpm}/bin/pi-npm" ];
          # Declarative package list. Pi loads extensions/skills/prompts/themes
          # from each entry's manifest. `pi install npm:...` would normally
          # write here, but settings.json is a read-only Nix store symlink, so
          # we declare packages here directly. The activation hook below
          # ensures the npm artifacts exist under ~/.pi/agent/npm/.
          packages = [
            # MUST use the `npm:` prefix. Without it, pi's `parseSource()` falls
            # through to the local-path branch and tries to resolve
            # `~/.pi/agent/pi-subagents`, silently dropping the package even
            # though the npm artifacts exist under ~/.pi/agent/npm/.
            "npm:pi-subagents"
            # Web search and content fetching (fetch_content, web_search,
            # code_search). Reads EXA_API_KEY from the environment — no config
            # file needed. Requires Pi v0.37.3+.
            "npm:pi-web-access"
            # WakaTime time tracking. Reads api_key from ~/.wakatime.cfg
            # (hand-managed plain file outside Nix — predates this repo;
            # would need a secrets backend to manage declaratively).
            # Uses the wakatime-cli binary added to home.packages above.
            "npm:pi-wakatime"
            # Diff approval viewer — blocks edit/write until approved/rejected
            # in an interactive split-diff modal. Toggle with /diff-approval.
            "npm:pi-show-diffs"
            # Batch file reads via read_many with adaptive packing and
            # output-budget awareness. No config needed.
            "npm:pi-read-many"
            # Todo list tracking with live overlay above the editor. Tasks
            # survive /reload and conversation compaction (replayed from the
            # branch, not disk). Provides the `todo` tool, `/todos` slash
            # command, and `blockedBy` dependency tracking with cycle
            # detection. Replaces the simpler `pi-manage-todo-list`
            # (different tool name: `todo` vs `manage_todo_list`; same
            # /todos command, so they cannot coexist). Optional companion
            # `@juicesharp/rpiv-i18n` localizes overlay chrome; not
            # installed because LANG=en here makes it a no-op.
            "npm:@juicesharp/rpiv-todo"
            # Side conversation channel — /btw <question> opens a panel
            # at the bottom of the terminal, where a tool-less clone of the
            # primary model answers using a read-only snapshot of the main
            # transcript. Side answers never pollute the main session.
            # Replaces the simpler `pi-btw` (same /btw command, less UX).
            "npm:@juicesharp/rpiv-btw"
            # Structured clarifying-question tool — agent calls
            # `ask_user_question` mid-run to present a tabbed dialog with
            # single/multi-select questions, side-by-side option previews,
            # per-option notes, and a Submit-tab review step.
            # Replaces the simpler `pi-ask-user` (different tool name:
            # `ask_user_question` vs `ask_user`). Optional companion
            # `@juicesharp/rpiv-i18n` adds /languages locale switcher; not
            # installed because LANG=en here makes it a no-op.
            "npm:@juicesharp/rpiv-ask-user-question"
            # Background process manager — Pi can start dev servers, test
            # watchers, builds, log tails via the `process` tool and keep
            # the conversation going. /ps panel, /ps:logs, /ps:pin,
            # /ps:dock, /ps:settings. Supports logWatches for runtime
            # alerts on stdout/stderr regex matches.
            "npm:@aliou/pi-processes"
            # Aggregated token/cost usage stats across all sessions.
            # /usage for table view, /usage --insights for dashboard.
            "npm:@tmustier/pi-usage-extension"
            # Vim-style modal editing for Pi's input box. Esc/Ctrl+[ to enter
            # normal mode; covers motions, operators, visual mode basics.
            "npm:pi-vim"
            # Run interactive CLIs (vim, psql, ssh, dev servers, sub-agent
            # CLIs) in a TUI overlay with 4 modes: interactive, hands-free,
            # dispatch, monitor. Commands: /spawn, /attach, /dismiss.
            # Ships an `interactive-shell` skill auto-registered via
            # the package's pi.skills field. Runtime dep zigpty ships
            # prebuilt PTY binaries (macOS arm64/x64 + Linux x64/arm64
            # supported — no node-gyp on first install).
            "npm:pi-interactive-shell"
            # Two-pane browser workspace: /studio opens an Editor + Preview
            # window (Markdown/LaTeX/Mermaid/code) backed by a local-only
            # 127.0.0.1 server with tokenized URLs. Adds critique workflow,
            # response history browsing, annotations, comments rail, and
            # PDF export via /studio-pdf. PDF export needs `pandoc` (+
            # MacTeX/TeX Live for LaTeX, `mmdc` for Mermaid in PDFs) on
            # PATH — not declared here; install ad-hoc if/when needed.
            "npm:pi-studio"
            # @runfusion/fusion is intentionally omitted from this list — it
            # is NOT a pi extension. Fusion ships as a standalone Node app
            # with its own CLI (`fn` / `fusion`) and web dashboard; pi is
            # one of the model integrations it can drive, not its host.
            # Installed via the `installFusion` activation hook below.
          ];
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
          # - opus-4-7  → planner, worker. Edit-quality and tool-orchestration
          #               leader; lowest hallucination rate of the three.
          # - gpt-5.5   → oracle, reviewer. Cross-family second opinion;
          #               strong at long-context retrieval and abstract
          #               reasoning. Hallucinates more — kept out of any
          #               role that writes code.
          # - sonnet-4-6 → researcher, context-builder. 1M context window;
          #                read-heavy and handoff-synthesis fits.
          # - haiku-4-5 → scout. Pure recon; output is consumed by a stronger
          #               downstream agent so model gap doesn't propagate.
          #
          # `thinking` is pinned per-role so a future pi-subagents update
          # can't silently change cost/latency. `fallbackModels` is
          # intentionally not set here: pi-subagents fallbacks fire only on
          # provider/auth/quota errors (not bad output), so they're not a
          # quality escape hatch — adding them would mainly muddy debugging.
          # Revisit if/when an outage actually bites.
          subagents.agentOverrides = {
            scout = {
              model = "anthropic/claude-haiku-4-5";
            };
            # context-builder writes the handoff that planner/worker consume;
            # bad context poisons the whole chain, so spend reasoning here.
            "context-builder" = {
              model = "anthropic/claude-sonnet-4-6";
              thinking = "high";
            };
            planner = {
              model = "anthropic/claude-opus-4-7";
              thinking = "high";
            };
            worker = {
              model = "anthropic/claude-opus-4-7";
              thinking = "high";
            };
            reviewer = {
              model = "openai/gpt-5.5";
              thinking = "high";
            };
            # researcher is read-heavy; Sonnet's 1M context does the lifting,
            # not reasoning depth. Start at medium and let hard research
            # tasks be explicitly escalated.
            researcher = {
              model = "anthropic/claude-sonnet-4-6";
              thinking = "medium";
            };
            oracle = {
              model = "openai/gpt-5.5";
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
          # Disable install telemetry. Pi otherwise sends a single GET to
          # https://pi.dev/install?version=X on the first run after a version
          # change (interactive-mode.js:631). PI_OFFLINE already short-circuits
          # this, but we set the explicit flag for defense-in-depth in case
          # PI_OFFLINE is ever unset.
          # Default tree filter mode. "user-only" mirrors Ctrl+U so you
          # see only your own messages in /tree without having to toggle it
          # every time. Other options: "default", "no-tools", "labeled-only", "all".
          treeFilterMode = "user-only";
          enableInstallTelemetry = false;
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

        ".pi/agent/AGENTS.md".source = ./config/AGENTS.md;

        ".pi/agent/prompts" = {
          source = ./config/prompts;
          recursive = true;
        };

        # Locally-authored skills, linked into the shared ~/.agents/skills/
        # tree so they're discoverable by every agent harness that follows
        # the agent-skills.io convention rather than just pi. The sources
        # of truth are ./config/skills/<name>/.
        ".agents/skills/commit" = {
          source = ./config/skills/commit;
          recursive = true;
        };
        ".agents/skills/to-html" = {
          source = ./config/skills/to-html;
          recursive = true;
        };

        # Anthropic skills (https://github.com/anthropics/skills).
        ".agents/skills/frontend-design" = {
          source = "${anthropicSkills}/skills/frontend-design";
          recursive = true;
        };
        ".agents/skills/doc-coauthoring" = {
          source = "${anthropicSkills}/skills/doc-coauthoring";
          recursive = true;
        };
        ".agents/skills/skill-creator" = {
          source = "${anthropicSkills}/skills/skill-creator";
          recursive = true;
        };
        ".agents/skills/webapp-testing" = {
          source = "${anthropicSkills}/skills/webapp-testing";
          recursive = true;
        };
        ".agents/skills/pdf" = {
          source = "${anthropicSkills}/skills/pdf";
          recursive = true;
        };

        # Matt Pocock skills (https://github.com/mattpocock/skills).
        # `grill-me` replaces an earlier local `refine-plan` skill.
        ".agents/skills/grill-me" = {
          source = "${mattpocockSkills}/skills/productivity/grill-me";
          recursive = true;
        };
        ".agents/skills/diagnose" = {
          source = "${mattpocockSkills}/skills/engineering/diagnose";
          recursive = true;
        };
        ".agents/skills/grill-with-docs" = {
          source = "${mattpocockSkills}/skills/engineering/grill-with-docs";
          recursive = true;
        };
        ".agents/skills/improve-codebase-architecture" = {
          source = "${mattpocockSkills}/skills/engineering/improve-codebase-architecture";
          recursive = true;
        };
        ".agents/skills/zoom-out" = {
          source = "${mattpocockSkills}/skills/engineering/zoom-out";
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

      # Bootstrap npm artifacts for declarative `packages` entries.
      #
      # Pi resolves global npm packages from
      # `<npmCommand> root -g`/lib/node_modules/<name>. We can't use
      # `pi install npm:...` here because that command also tries to mutate
      # settings.json, which is a read-only Nix store symlink under
      # home-manager. Instead we install via the same npm wrapper directly,
      # which writes only to ~/.pi/agent/npm/. The directory check makes
      # each install hook idempotent.
      #
      # Cleanup: cleanupPiPackages runs before all install hooks and removes
      # any directory in node_modules not present in the declared set below.
      # Removing a package from the list + `nh os switch` is enough — no
      # manual `rm` needed.
      #
      # Trailing-slash + symlink footgun: globs like `*/` yield paths with a
      # trailing slash, and `rm -rf foo/` on a symlink-to-dir dereferences the
      # link and tries to delete the target's contents (not the link). For
      # entries that point into the read-only Nix store (e.g. bootstrap
      # symlinks created by `linkPiForTaskplane` or by an old `pi install`),
      # that surfaces as a flood of "Permission denied" errors and fails the
      # whole activation. We strip the trailing slash and use `rm` (no `-rf`)
      # for symlinks so we delete the link itself, never its target.
      home.activation.cleanupPiPackages = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
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
              pi-subagents|pi-web-access|pi-wakatime|pi-show-diffs|pi-read-many|pi-vim|pi-interactive-shell|pi-studio|glimpseui) ;; # glimpseui is a peer dep of pi-web-access (see installGlimpseUi below)
              *) remove_stale "$pkg" "$dir" ;;
            esac
          done
          # Remove undeclared scoped packages (@scope/name)
          for scope_dir in "$node_modules"/@*/; do
            scope_dir="''${scope_dir%/}"
            [ -d "$scope_dir" ] || continue
            scope=$(basename "$scope_dir")
            for pkg_dir in "$scope_dir"/*/; do
              pkg_dir="''${pkg_dir%/}"
              [ -e "$pkg_dir" ] || continue
              full="$scope/$(basename "$pkg_dir")"
              case "$full" in
                @tmustier/pi-usage-extension|@juicesharp/rpiv-btw|@juicesharp/rpiv-ask-user-question|@juicesharp/rpiv-todo|@aliou/pi-processes|@runfusion/fusion) ;;
                # Fusion declares `@mariozechner/pi-coding-agent` as a direct
                # dependency, which npm hoists to the top-level node_modules
                # tree on global install. Keep it in the allowlist so the
                # cleanup pass doesn't race with `installFusion` and delete
                # Fusion's hoisted pi dep between activation phases.
                @mariozechner/pi-coding-agent) ;;
                *) remove_stale "$full" "$pkg_dir" ;;
              esac
            done
          done
        fi
      '';

      home.activation.installPiSubagents =
        lib.hm.dag.entryAfter [ "writeBoundary" "cleanupPiPackages" ]
          ''
            if [ ! -d "$HOME/.pi/agent/npm/lib/node_modules/pi-subagents" ]; then
              $DRY_RUN_CMD ${piNpm}/bin/pi-npm install -g pi-subagents
            fi
          '';

      home.activation.installPiWebAccess =
        lib.hm.dag.entryAfter [ "writeBoundary" "cleanupPiPackages" ]
          ''
            if [ ! -d "$HOME/.pi/agent/npm/lib/node_modules/pi-web-access" ]; then
              $DRY_RUN_CMD ${piNpm}/bin/pi-npm install -g pi-web-access
            fi
          '';

      home.activation.installPiWakatime = lib.hm.dag.entryAfter [ "writeBoundary" "cleanupPiPackages" ] ''
        if [ ! -d "$HOME/.pi/agent/npm/lib/node_modules/pi-wakatime" ]; then
          $DRY_RUN_CMD ${piNpm}/bin/pi-npm install -g pi-wakatime
        fi
      '';

      home.activation.installPiShowDiffs =
        lib.hm.dag.entryAfter [ "writeBoundary" "cleanupPiPackages" ]
          ''
            if [ ! -d "$HOME/.pi/agent/npm/lib/node_modules/pi-show-diffs" ]; then
              $DRY_RUN_CMD ${piNpm}/bin/pi-npm install -g pi-show-diffs
            fi
          '';

      home.activation.installPiReadMany = lib.hm.dag.entryAfter [ "writeBoundary" "cleanupPiPackages" ] ''
        if [ ! -d "$HOME/.pi/agent/npm/lib/node_modules/pi-read-many" ]; then
          $DRY_RUN_CMD ${piNpm}/bin/pi-npm install -g pi-read-many
        fi
      '';

      home.activation.installRpivTodo = lib.hm.dag.entryAfter [ "writeBoundary" "cleanupPiPackages" ] ''
        if [ ! -d "$HOME/.pi/agent/npm/lib/node_modules/@juicesharp/rpiv-todo" ]; then
          $DRY_RUN_CMD ${piNpm}/bin/pi-npm install -g @juicesharp/rpiv-todo
        fi
      '';

      home.activation.installRpivBtw = lib.hm.dag.entryAfter [ "writeBoundary" "cleanupPiPackages" ] ''
        if [ ! -d "$HOME/.pi/agent/npm/lib/node_modules/@juicesharp/rpiv-btw" ]; then
          $DRY_RUN_CMD ${piNpm}/bin/pi-npm install -g @juicesharp/rpiv-btw
        fi
      '';

      home.activation.installRpivAskUserQuestion =
        lib.hm.dag.entryAfter [ "writeBoundary" "cleanupPiPackages" ]
          ''
            if [ ! -d "$HOME/.pi/agent/npm/lib/node_modules/@juicesharp/rpiv-ask-user-question" ]; then
              $DRY_RUN_CMD ${piNpm}/bin/pi-npm install -g @juicesharp/rpiv-ask-user-question
            fi
          '';

      home.activation.installPiProcesses =
        lib.hm.dag.entryAfter [ "writeBoundary" "cleanupPiPackages" ]
          ''
            if [ ! -d "$HOME/.pi/agent/npm/lib/node_modules/@aliou/pi-processes" ]; then
              $DRY_RUN_CMD ${piNpm}/bin/pi-npm install -g @aliou/pi-processes
            fi
          '';

      home.activation.installPiUsageExtension =
        lib.hm.dag.entryAfter [ "writeBoundary" "cleanupPiPackages" ]
          ''
            if [ ! -d "$HOME/.pi/agent/npm/lib/node_modules/@tmustier/pi-usage-extension" ]; then
              $DRY_RUN_CMD ${piNpm}/bin/pi-npm install -g @tmustier/pi-usage-extension
            fi
          '';

      home.activation.installPiVim = lib.hm.dag.entryAfter [ "writeBoundary" "cleanupPiPackages" ] ''
        if [ ! -d "$HOME/.pi/agent/npm/lib/node_modules/pi-vim" ]; then
          $DRY_RUN_CMD ${piNpm}/bin/pi-npm install -g pi-vim
        fi
      '';

      home.activation.installPiInteractiveShell =
        lib.hm.dag.entryAfter [ "writeBoundary" "cleanupPiPackages" ]
          ''
            if [ ! -d "$HOME/.pi/agent/npm/lib/node_modules/pi-interactive-shell" ]; then
              $DRY_RUN_CMD ${piNpm}/bin/pi-npm install -g pi-interactive-shell
            fi
          '';

      home.activation.installPiStudio = lib.hm.dag.entryAfter [ "writeBoundary" "cleanupPiPackages" ] ''
        if [ ! -d "$HOME/.pi/agent/npm/lib/node_modules/pi-studio" ]; then
          $DRY_RUN_CMD ${piNpm}/bin/pi-npm install -g pi-studio
        fi
      '';

      # Glimpse: native WebView micro-UI used by pi-web-access to render the
      # search curator inside an OS-level overlay window attached to pi,
      # instead of launching the system browser. Without it, web_search →
      # `openInBrowser()` (pi-web-access/index.ts:295) shells out to `open
      # <url>` and your default browser steals focus.
      #
      # NOT a pi extension — it has no pi manifest, so it deliberately does
      # NOT go in the `packages` list above. pi-web-access discovers it via
      # `createRequire("glimpseui")` (index.ts:316) which succeeds because
      # both packages live under the same ~/.pi/agent/npm/lib/node_modules/
      # tree. The fallback path uses `npm root -g`, which our piNpm wrapper
      # also redirects to that prefix.
      #
      # The npm `postinstall` (glimpseui/scripts/postinstall.mjs) compiles
      # the Swift backend (src/glimpse, ~190KB arm64 Mach-O) using the
      # system swiftc from Xcode Command Line Tools. If swiftc is missing,
      # the install succeeds but writes a `.glimpse-build-skipped` marker
      # and the WebView won't launch — install Xcode CLT and re-run
      # `nh darwin switch` to retry.
      home.activation.installGlimpseUi = lib.hm.dag.entryAfter [ "writeBoundary" "cleanupPiPackages" ] ''
        if [ ! -d "$HOME/.pi/agent/npm/lib/node_modules/glimpseui" ]; then
          $DRY_RUN_CMD ${piNpm}/bin/pi-npm install -g glimpseui
        fi
      '';

      # @runfusion/fusion — standalone multi-node agent orchestrator (NOT a
      # pi extension; see comment in `packages` above). Installed via the
      # same pi-npm wrapper used for pi extensions so the npm artifact
      # lands in the writable ~/.pi/agent/npm prefix instead of the
      # read-only Nix store. The `linkFusionCli` hook below puts `fn` and
      # `fusion` on $PATH; outside of those two binaries this package is
      # not consumed by pi itself.
      home.activation.installFusion = lib.hm.dag.entryAfter [ "writeBoundary" "cleanupPiPackages" ] ''
        if [ ! -d "$HOME/.pi/agent/npm/lib/node_modules/@runfusion/fusion" ]; then
          $DRY_RUN_CMD ${piNpm}/bin/pi-npm install -g @runfusion/fusion
        fi
      '';

      # Fusion ships two CLI entrypoints (`fn` and `fusion`) under
      # dist/bin.js — same shape as taskplane's bin layout. npm's global
      # bin dir (~/.pi/agent/npm/bin/) is intentionally NOT on $PATH so
      # pi extensions don't leak as shell commands; we symlink Fusion's
      # entrypoint into ~/.local/bin (already on PATH) under both names.
      # Idempotent: `ln -sfn` replaces any stale symlink each activation.
      home.activation.linkFusionCli = lib.hm.dag.entryAfter [ "writeBoundary" "installFusion" ] ''
        $DRY_RUN_CMD mkdir -p "$HOME/.local/bin"
        $DRY_RUN_CMD ln -sfn \
          "$HOME/.pi/agent/npm/lib/node_modules/@runfusion/fusion/dist/bin.js" \
          "$HOME/.local/bin/fn"
        $DRY_RUN_CMD ln -sfn \
          "$HOME/.pi/agent/npm/lib/node_modules/@runfusion/fusion/dist/bin.js" \
          "$HOME/.local/bin/fusion"
      '';

      programs.zsh.shellAliases = {
        p = "pi";
      };
    };
}
