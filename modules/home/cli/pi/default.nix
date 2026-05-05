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
    in
    lib.mkIf config.cli.pi.enable {
      home.packages = with pkgs; [
        pi-coding-agent
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
      # NOTE: ~/.agents/skills/{frontend-design,doc-coauthoring,grill-me,
      # grill-with-docs,improve-codebase-architecture,zoom-out} are managed
      # by the opencode module. Pi auto-discovers skills from
      # ~/.agents/skills/ via the agent-skills.io standard.
      home.file = {
        ".pi/agent/settings.json".text = builtins.toJSON {
          defaultProvider = "anthropic";
          defaultModel = "claude-opus-4-7";
          defaultThinkingLevel = "high";
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
            # (already managed by opencode-wakatime; no separate config needed).
            # Uses the global wakatime-cli binary from the opencode module.
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
            # Long-running iterative agent loops with checklist tracking.
            # Pi sets up .ralph/<name>.md and iterates automatically.
            # /ralph start|resume|stop|status. --reflect-every N for self-check.
            "npm:@tmustier/pi-ralph-wiggum"
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
            # taskplane intentionally omitted from global packages — it runs
            # workspace detection on every session_start regardless of use.
            # Load per-project via .pi/AGENTS.md, or globally with:
            #   pi --package npm:taskplane  (alias: po)

          ];
          # pi-subagents builtins (scout, planner, worker, …) hardcode
          # `openai-codex/*` models, which is pi's ChatGPT-OAuth provider –
          # NOT the regular OpenAI API. Override them to providers we actually
          # have keys for (anthropic + openai).
          #
          # Mixing model families is intentional: the value of subagents comes
          # partly from getting a *different perspective* on the same problem.
          # `oracle` in particular exists to disagree with the parent, so it
          # runs on a different family than the default model.
          #
          # Mapping (see pi-subagents/README.md → "Builtin agents"):
          # - openai/gpt-5.5 → reasoning/advisory roles (oracle,
          #     oracle-executor, reviewer) where a non-Claude perspective
          #     adds real signal vs. the default Claude parent model.
          # - anthropic/claude-opus-4-7 → high-stakes roles (planner, worker,
          #     researcher) where Claude is reliably strong at edits,
          #     planning, and synthesis.
          # - anthropic/claude-sonnet-4-6 → handoff-writing role
          #     (context-builder) where output quality matters because it
          #     feeds planner/worker, but Opus is overkill.
          # - anthropic/claude-haiku-4-5 → pure throughput role (scout) doing
          #     grep/find/read/summarize. ~3x cheaper + ~2x faster than
          #     Sonnet, and Anthropic positions Haiku 4.5 at Sonnet-4 coding
          #     parity — fine for recon whose output is consumed by a
          #     stronger downstream agent. NOT used for context-builder
          #     (handoff synthesis) or worker (actual edits) where the
          #     ~4-point SWE-bench gap to Sonnet would surface as bad output.
          #
          # `fallbackModels` is consulted only on provider/auth/quota/timeout
          # errors (per pi-subagents README), so cross-provider fallbacks are
          # safe – they don't fire on "bad output".
          subagents.agentOverrides = {
            scout = {
              model = "anthropic/claude-haiku-4-5";
            };
            "context-builder" = {
              model = "anthropic/claude-sonnet-4-6";
            };
            planner = {
              model = "anthropic/claude-opus-4-7";
            };
            worker = {
              model = "anthropic/claude-opus-4-7";
            };
            reviewer = {
              model = "openai/gpt-5.5";
            };
            researcher = {
              model = "anthropic/claude-opus-4-7";
            };
            oracle = {
              model = "openai/gpt-5.5";
            };
            "oracle-executor" = {
              model = "openai/gpt-5.5";
            };
            # `delegate` intentionally has no model override – it inherits the
            # parent's model, which is the whole point of that builtin.
          };
          # Custom theme name (matches `name` field inside the JSON file).
          # Pi auto-discovers theme files from ~/.pi/agent/themes/.
          theme = "catppuccin-mocha";
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
        ".pi/agent/keybindings.json".text = builtins.toJSON {
          "app.session.resume" = "ctrl+b";
          "app.session.fork" = "ctrl+f";
          "app.session.tree" = "ctrl+t";
          "app.thinking.toggle" = "shift+ctrl+t";
        };

        ".pi/agent/AGENTS.md".source = ./config/AGENTS.md;

        ".pi/agent/prompts" = {
          source = ./config/prompts;
          recursive = true;
        };

        # Predefined agent chains. Stored alongside agent files so
        # pi-subagents discovers them at ~/.pi/agent/agents/{name}.chain.md.
        # Each chain is a multi-step pipeline invoked via /chain in the TUI.
        ".pi/agent/agents" = {
          source = ./config/agents;
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
      home.activation.cleanupPiPackages = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        node_modules="$HOME/.pi/agent/npm/lib/node_modules"
        if [ -d "$node_modules" ]; then
          # Remove undeclared unscoped packages
          for dir in "$node_modules"/*/; do
            [ -d "$dir" ] || continue
            pkg=$(basename "$dir")
            case "$pkg" in
              @*) continue ;;
              pi-subagents|pi-web-access|pi-wakatime|pi-show-diffs|pi-read-many|pi-vim|pi-interactive-shell|pi-studio|taskplane|glimpseui) ;; # taskplane kept so npm artifact isn't wiped; glimpseui is a peer dep of pi-web-access (see installGlimpseUi below)
              *)
                echo "pi-nix: removing stale npm package: $pkg"
                $DRY_RUN_CMD rm -rf "$dir"
                ;;
            esac
          done
          # Remove undeclared scoped packages (@scope/name)
          for scope_dir in "$node_modules"/@*/; do
            [ -d "$scope_dir" ] || continue
            scope=$(basename "$scope_dir")
            for pkg_dir in "$scope_dir"*/; do
              [ -d "$pkg_dir" ] || continue
              full="$scope/$(basename "$pkg_dir")"
              case "$full" in
                @tmustier/pi-usage-extension|@tmustier/pi-ralph-wiggum|@juicesharp/rpiv-btw|@juicesharp/rpiv-ask-user-question|@juicesharp/rpiv-todo|@aliou/pi-processes) ;;
                *)
                  echo "pi-nix: removing stale npm package: $full"
                  $DRY_RUN_CMD rm -rf "$pkg_dir"
                  ;;
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

      home.activation.installRpivTodo =
        lib.hm.dag.entryAfter [ "writeBoundary" "cleanupPiPackages" ]
          ''
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

      home.activation.installPiRalphWiggum =
        lib.hm.dag.entryAfter [ "writeBoundary" "cleanupPiPackages" ]
          ''
            if [ ! -d "$HOME/.pi/agent/npm/lib/node_modules/@tmustier/pi-ralph-wiggum" ]; then
              $DRY_RUN_CMD ${piNpm}/bin/pi-npm install -g @tmustier/pi-ralph-wiggum
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

      home.activation.installTaskplane = lib.hm.dag.entryAfter [ "writeBoundary" "cleanupPiPackages" ] ''
        if [ ! -d "$HOME/.pi/agent/npm/lib/node_modules/taskplane" ]; then
          $DRY_RUN_CMD ${piNpm}/bin/pi-npm install -g taskplane
        fi
      '';

      # Taskplane ships its CLI under the package's bin/ but pi installs
      # extensions with `npm install -g` into ~/.pi/agent/npm/, which is NOT
      # on $PATH. Symlink the CLI into ~/.local/bin (already on PATH via the
      # standard user-bin convention) so `taskplane` works from any shell —
      # not just zsh — and outside of pi sessions. Idempotent: replaces any
      # stale symlink each activation so the target tracks the npm install.
      home.activation.linkTaskplaneCli = lib.hm.dag.entryAfter [ "writeBoundary" "installTaskplane" ] ''
        $DRY_RUN_CMD mkdir -p "$HOME/.local/bin"
        $DRY_RUN_CMD ln -sfn \
          "$HOME/.pi/agent/npm/lib/node_modules/taskplane/bin/taskplane.mjs" \
          "$HOME/.local/bin/taskplane"
      '';

      # Symlink the Nix-store pi-coding-agent into the custom npm prefix so
      # taskplane's resolvePiCliPath() can find @mariozechner/pi-coding-agent/dist/cli.js.
      # taskplane resolves the Pi CLI via `npm root -g`; under Nix, pi lives in
      # the Nix store, not in any npm global root, so without this symlink
      # worker agent spawning fails with "Cannot find Pi CLI entrypoint".
      home.activation.linkPiForTaskplane = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        $DRY_RUN_CMD mkdir -p "$HOME/.pi/agent/npm/lib/node_modules/@mariozechner"
        $DRY_RUN_CMD ln -sfn \
          "${pkgs.pi-coding-agent}/lib/node_modules/@mariozechner/pi-coding-agent" \
          "$HOME/.pi/agent/npm/lib/node_modules/@mariozechner/pi-coding-agent"
      '';

      programs.zsh.shellAliases = {
        # NPM_CONFIG_PREFIX ensures `npm root -g` (called by taskplane's path
        # resolver) returns ~/.pi/agent/npm/lib/node_modules, where the
        # pi-coding-agent symlink above lives.
        p = "NPM_CONFIG_PREFIX=$HOME/.pi/agent/npm pi";
        po = "NPM_CONFIG_PREFIX=$HOME/.pi/agent/npm pi -e npm:taskplane";
      };
    };
}
