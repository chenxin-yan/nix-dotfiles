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

      # Pi pulls its own version + package updates from npm on startup
      # (see interactive-mode.js: checkForNewVersion / checkForPackageUpdates).
      # Both flows are pointless under Nix - the binary version is pinned to
      # the Nix store path. PI_OFFLINE disables both checks and saves a
      # network round-trip per session.
      home.sessionVariables.PI_OFFLINE = "1";

      # Seed global pi settings. Only values that diverge from upstream
      # defaults are listed; everything else is left to pi's defaults.
      #
      # `enabledModels` is the ordered cycle list used by Ctrl+P (and the
      # default model picker on launch). Patterns resolve via
      # `resolveModelScope`: provider-qualified IDs match exactly and are
      # preferred over globs because they avoid pulling in dated variants
      # (e.g. claude-sonnet-4-6-20250929) and unrelated families.
      #
      # NOTE: ~/.agents/skills/{frontend-design,doc-coauthoring,refine-plan}
      # are already managed by the opencode module. Pi auto-discovers skills
      # from ~/.agents/skills/ via the agent-skills.io standard.
      home.file = {
        ".pi/agent/settings.json".text = builtins.toJSON {
          defaultProvider = "anthropic";
          defaultModel = "claude-opus-4-7";
          defaultThinkingLevel = "high";
          enabledModels = [
            "anthropic/claude-opus-4-7"
            "anthropic/claude-sonnet-4-6"
            "openai/gpt-5.4"
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
          # - openai/gpt-5.4 → reasoning/advisory roles (planner, oracle,
          #     oracle-executor) where a non-Claude perspective adds real
          #     signal vs. the default Claude parent model.
          # - anthropic/claude-opus-4-7 → high-stakes code review where Claude
          #     is reliably strong at edits + critique.
          # - anthropic/claude-sonnet-4-6 → throughput roles (scout,
          #     context-builder, worker) where latency/cost matter more than
          #     reasoning depth.
          #
          # `fallbackModels` is consulted only on provider/auth/quota/timeout
          # errors (per pi-subagents README), so cross-provider fallbacks are
          # safe – they don't fire on "bad output".
          subagents.agentOverrides = {
            scout = {
              model = "anthropic/claude-sonnet-4-6";
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
              model = "openai/gpt-5.4";
            };
            researcher = {
              model = "anthropic/claude-opus-4-6=7";
            };
            oracle = {
              model = "openai/gpt-5.4";
            };
            "oracle-executor" = {
              model = "openai/gpt-5.4";
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
      };

      # Bootstrap npm artifacts for declarative `packages` entries.
      #
      # Pi resolves global npm packages from
      # `<npmCommand> root -g`/lib/node_modules/<name>. We can't use
      # `pi install npm:pi-subagents` here because that command also tries to
      # mutate settings.json, which is a read-only Nix store symlink under
      # home-manager. Instead we install via the same npm wrapper directly,
      # which writes only to ~/.pi/agent/npm/. The directory check makes this
      # idempotent.
      home.activation.installPiSubagents = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        if [ ! -d "$HOME/.pi/agent/npm/lib/node_modules/pi-subagents" ]; then
          $DRY_RUN_CMD ${piNpm}/bin/pi-npm install -g pi-subagents
        fi
      '';

      home.activation.installPiWebAccess = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        if [ ! -d "$HOME/.pi/agent/npm/lib/node_modules/pi-web-access" ]; then
          $DRY_RUN_CMD ${piNpm}/bin/pi-npm install -g pi-web-access
        fi
      '';

      home.activation.installPiWakatime = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        if [ ! -d "$HOME/.pi/agent/npm/lib/node_modules/pi-wakatime" ]; then
          $DRY_RUN_CMD ${piNpm}/bin/pi-npm install -g pi-wakatime
        fi
      '';

      programs.zsh.shellAliases = {
        p = "pi";
      };
    };
}
