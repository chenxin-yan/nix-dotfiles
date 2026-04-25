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
    };

    home.file.".pi/agent/themes" = {
      source = ./config/themes;
      recursive = true;
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

    programs.zsh.shellAliases = {
      p = "pi";
    };
  };
}
