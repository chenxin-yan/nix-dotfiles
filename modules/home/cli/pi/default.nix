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

  config = let
    piNpm = pkgs.writeShellScriptBin "pi-npm" ''
      export PATH="${pkgs.nodejs}/bin:$PATH"
      export NPM_CONFIG_PREFIX="$HOME/.pi/agent/npm"
      exec ${pkgs.nodejs}/bin/npm "$@"
    '';
  in lib.mkIf config.cli.pi.enable {
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
      ".pi/agent/themes/catppuccin-mocha.json".source =
        "${inputs.pi-catppuccin.packages.${pkgs.stdenv.hostPlatform.system}.default}/share/pi/themes/catppuccin-mocha.json";

      # Override pi's default keybindings.
      # - tui.editor.undo: pi defaults to ctrl+- which most terminals don't
      #   actually send (terminals only encode ctrl+letter; ctrl+- requires
      #   the Kitty keyboard protocol which not every terminal/session has
      #   active). ctrl+r is unbound in the editor context (it's only used
      #   inside the session picker for app.session.rename), so we reuse it.
      # - app.session.resume: unbound upstream; bind ctrl+b ("browse") to
      #   open the session picker without typing /resume.
      ".pi/agent/keybindings.json".text = builtins.toJSON {
        "tui.editor.undo" = "ctrl+r";
        "app.session.resume" = "ctrl+b";
      };

      ".pi/agent/AGENTS.md".source = ./config/AGENTS.md;

      ".pi/agent/prompts" = {
        source = ./config/prompts;
        recursive = true;
      };
    };

    # Install pi-subagents extension on first home-manager switch.
    # pi uses the configured `npmCommand` from settings.json, which points at
    # a wrapper that keeps npm's global prefix writable under ~/.pi/agent/npm.
    home.activation.installPiSubagents = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      if [ ! -d "$HOME/.pi/agent/extensions/pi-subagents" ]; then
        $DRY_RUN_CMD ${pkgs.pi-coding-agent}/bin/pi install npm:pi-subagents
      fi
    '';

    programs.zsh.shellAliases = {
      p = "pi";
    };
  };
}
