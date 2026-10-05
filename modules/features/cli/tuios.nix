# Trial alongside herdr: same Ctrl+s leader, catppuccin and Ctrl+hjkl nav;
# everything else stays at tuios defaults to judge them as shipped, except
# keys the defaults can't have here (see the comments below).
{ inputs, ... }:
{
  features.tuios.homeManager =
    { pkgs, lib, ... }:
    let
      tuios = inputs.tuios.packages.${pkgs.stdenv.hostPlatform.system}.default;

      # What `tuios integration install pi` writes, rendered at build time so
      # it stays declarative and matches this tuios. The hook finds tuios on
      # PATH, as shipped: pinning --command makes `tuios integration status`
      # report the file out of date.
      piExtension = pkgs.runCommand "tuios-pi-agent-state.ts" { } ''
        export HOME=$TMPDIR
        mkdir -p $HOME/.pi/agent
        ${tuios}/bin/tuios integration install pi >/dev/null
        cp $HOME/.pi/agent/extensions/tuios-agent-state.ts $out
      '';

      # Ctrl+s A: a worktree session for a new branch with pi in it, the task
      # typed in once pi is ready. You stay where you are; the rail and the
      # Inbox say when it needs you.
      newAgentTask = pkgs.writeShellScript "tuios-new-agent-task" ''
        set -eu
        export PATH=${
          lib.makeBinPath [
            pkgs.jq
            tuios
          ]
        }:$PATH
        fail() {
          printf '%s\nPress Enter to close.' "$1"
          read -r _
          exit 1
        }
        printf 'branch> '
        read -r branch
        [ -n "$branch" ] || exit 0
        printf 'task (empty: start pi idle)> '
        read -r task
        out=$(tuios worktree new "$branch" --detach --json 2>&1) || fail "$out"
        session=$(printf '%s' "$out" | jq -r .session)
        set -- -s "$session" --name pi
        [ -z "$task" ] || set -- "$@" --prompt "$task"
        out=$(tuios start-agent pi "$@" 2>&1) || fail "$out"
      '';

      # Ctrl+s u and `ts`: fzf over $DEV_PATH repos, then the project's session
      # (owner.repo, local.name), created in the repo first. In a tuios pane
      # the client switches to it; in any other shell `tuios attach` opens it.
      # tuios 0.8.5's CLI can neither start a session in a given directory
      # (`tuios new` takes the daemon's cwd) nor switch the client from a pane,
      # so this uses the new-session verb (docs/protocol.md) and herdr's
      # workspace focus. Drop both once tuios ships them natively.
      pickProject = pkgs.writeShellScript "tuios-pick-project" ''
        set -eu
        export PATH=${
          lib.makeBinPath (
            with pkgs;
            [
              coreutils
              fd
              fzf
              gnused
              jq
              socat
              tuios
            ]
          )
        }:$PATH
        # Where tuios puts its socket (internal/session/manager_unix.go).
        sock=''${TUIOS_SOCKET:-''${XDG_RUNTIME_DIR:+$XDG_RUNTIME_DIR/tuios/tuios.sock}}
        sock=''${sock:-/tmp/tuios-$(id -u)/tuios.sock}
        [ -S "$sock" ] || tuios start-server >/dev/null
        dev=''${DEV_PATH:-$HOME/dev}
        rel=$(
          {
            fd -H -t d -d 4 '^\.git$' "$dev" -E local -x dirname {}
            [ ! -d "$dev/local" ] || fd -t d -d 1 . "$dev/local"
          } | sed -e 's|/$||' -e "s|^$dev/||" | sort -u | fzf --prompt 'project> '
        ) || exit 0
        case $rel in
          local/*) name=local.''${rel#local/} ;;
          */*/*) name=$(echo "$rel" | cut -d/ -f2).$(echo "$rel" | cut -d/ -f3) ;;
          *) name=$(basename "$rel") ;;
        esac
        # An existing session answers session_exists; the focus below still runs.
        jq -nc --arg n "$name" --arg c "$dev/$rel" \
          '{id: 1, verb: "new-session", params: {name: $n, cwd: $c}}' \
          | socat -t2 - "UNIX-CONNECT:$sock" >/dev/null
        [ "''${TUIOS_ENV:-}" = 1 ] || exec tuios attach "$name"
        id=$("$HERDR_BIN_PATH" workspace list | jq -r --arg n "$name" \
          'first(.result.workspaces[] | select(.label == $n) | .workspace_id) // empty')
        [ -n "$id" ] && "$HERDR_BIN_PATH" workspace focus "$id" >/dev/null
      '';
    in
    {
      home.packages = [ tuios ];

      # Agent state for pi panes (the rail, the Inbox, resume after a restart).
      home.file.".pi/agent/extensions/tuios-agent-state.ts".source = piExtension;

      # The skill agents read to drive tuios (`tuios --skill`), from the same
      # source as the binary: SKILL.md plus one file per topic.
      home.file.".agents/skills/tuios" = {
        source = "${inputs.tuios}/skills/tuios";
        recursive = true;
      };

      # The entry point: one fixed session, the same on every machine.
      programs.zsh.shellAliases = {
        t = "tuios attach main -c";
        ts = "${pickProject}";
      };

      # tuios merges this over its defaults and leaves a read-only file alone,
      # but writers like `tuios hosts add` and the settings page can't persist:
      # add hosts here as [hosts.<name>] addr = "...".
      xdg.configFile."tuios/config.toml".text = ''
        [appearance]
        theme = "catppuccin_mocha"
        # Hands Ctrl+hjkl to nvim when tuios-nvim-navigator is active there.
        nvim_navigation = true

        # Type straight into the shell, as in herdr; Alt+Esc reaches window mode.
        [startup]
        start_in_terminal_mode = true
        tiled = true
        daemon = true

        [keybindings]
        leader_key = "ctrl+s"

        [keybindings.terminal_mode]
        terminal_focus_left = ["ctrl+h"]
        terminal_focus_down = ["ctrl+j"]
        terminal_focus_up = ["ctrl+k"]
        terminal_focus_right = ["ctrl+l"]

        # niri's resize keys without Mod: -/= width, Shift for height. Splitting
        # stays on Ctrl+s _ |. A bare "+" fails tuios's key validation, hence
        # only the chord spelling for it.
        [keybindings.layout]
        resize_master_shrink = ["-"]
        resize_master_grow = ["="]
        resize_height_shrink = ["_", "shift+-"]
        resize_height_grow = ["shift+="]
        split_horizontal = []
        equalize_splits = ["0"]

        # herdr's split key.
        [keybindings.prefix_mode]
        prefix_split_horizontal = ["_"]

        # The palette stays on Ctrl+s P; Ctrl+p goes back to nvim, fzf and zsh.
        [keybindings.global]
        command_palette = []

        # niri's mod key and AeroSpace both take Alt+1..9 before tuios sees
        # them (and Alt+Shift+1..9); Ctrl+1..9 were herdr's tab keys.
        [keybindings.workspaces]
        switch_workspace_1 = ["ctrl+1"]
        switch_workspace_2 = ["ctrl+2"]
        switch_workspace_3 = ["ctrl+3"]
        switch_workspace_4 = ["ctrl+4"]
        switch_workspace_5 = ["ctrl+5"]
        switch_workspace_6 = ["ctrl+6"]
        switch_workspace_7 = ["ctrl+7"]
        switch_workspace_8 = ["ctrl+8"]
        switch_workspace_9 = ["ctrl+9"]
        move_and_follow_1 = ["ctrl+shift+1"]
        move_and_follow_2 = ["ctrl+shift+2"]
        move_and_follow_3 = ["ctrl+shift+3"]
        move_and_follow_4 = ["ctrl+shift+4"]
        move_and_follow_5 = ["ctrl+shift+5"]
        move_and_follow_6 = ["ctrl+shift+6"]
        move_and_follow_7 = ["ctrl+shift+7"]
        move_and_follow_8 = ["ctrl+shift+8"]
        move_and_follow_9 = ["ctrl+shift+9"]

        [[keybindings.command]]
        key = "prefix+u"
        type = "popup"
        command = "${pickProject}"
        description = "Open a project"
        width = "60%"
        height = "60%"

        [[keybindings.command]]
        key = "prefix+A"
        type = "popup"
        command = "${newAgentTask}"
        description = "New agent task (worktree + pi)"
        width = "70%"
        height = "20%"

        # Scratch groups: per session, hidden until toggled, splittable.
        [[keybindings.command]]
        key = "prefix+G"
        type = "scratch"
        name = "lazygit"
        command = "lazygit"
        description = "Lazygit"

        [[keybindings.command]]
        key = "prefix+E"
        type = "scratch"
        name = "notes"
        command = "mkdir -p ~/notes && ''${EDITOR:-nvim} ~/notes/$TUIOS_SESSION.md"
        description = "Session notes"

        # No command: a shell to split for dev servers and log tails.
        [[keybindings.command]]
        key = "prefix+U"
        type = "scratch"
        name = "servers"
        description = "Servers and logs"
      '';
    };
}
