{
  config,
  pkgs,
  lib,
  ...
}:

{
  options = {
    cli.pi.enable = lib.mkEnableOption "enables pi coding agent CLI";
  };

  config = lib.mkIf config.cli.pi.enable {
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
    home.file.".pi/agent/settings.json".text = builtins.toJSON {
      defaultProvider = "anthropic";
      defaultModel = "claude-opus-4-7";
      defaultThinkingLevel = "high";
      enabledModels = [
        "anthropic/claude-opus-4-7"
        "anthropic/claude-sonnet-4-6"
        "openai/gpt-5.4"
      ];
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

    home.file.".pi/agent/themes" = {
      source = ./config/themes;
      recursive = true;
    };

    # Override pi's default keybindings.
    # - tui.editor.undo: pi defaults to ctrl+- which most terminals don't
    #   actually send (terminals only encode ctrl+letter; ctrl+- requires
    #   the Kitty keyboard protocol which not every terminal/session has
    #   active). ctrl+r is unbound in the editor context (it's only used
    #   inside the session picker for app.session.rename), so we reuse it.
    # - app.session.resume: unbound upstream; bind ctrl+b ("browse") to
    #   open the session picker without typing /resume.
    home.file.".pi/agent/keybindings.json".text = builtins.toJSON {
      "tui.editor.undo" = "ctrl+r";
      "app.session.resume" = "ctrl+b";
    };

    home.file.".pi/agent/AGENTS.md".source = ./config/AGENTS.md;

    home.file.".pi/agent/prompts" = {
      source = ./config/prompts;
      recursive = true;
    };

    # NOTE: ~/.agents/skills/{frontend-design,doc-coauthoring,refine-plan}
    # are already managed by the opencode module. Pi auto-discovers skills
    # from ~/.agents/skills/ via the agent-skills.io standard, so no
    # additional symlinks are needed here.

    # Install pi-subagents extension on first home-manager switch.
    # pi install fetches from npm and writes to ~/.pi/agent/extensions/.
    # The directory check makes this idempotent — safe to re-run.
    home.activation.installPiSubagents = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      if [ ! -d "$HOME/.pi/agent/extensions/pi-subagents" ]; then
        $DRY_RUN_CMD pi install npm:pi-subagents
      fi
    '';

    programs.zsh.shellAliases = {
      p = "pi";
    };
  };
}
