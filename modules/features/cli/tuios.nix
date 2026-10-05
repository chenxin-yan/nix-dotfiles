# tuios, on trial to replace herdr: herdr's Ctrl+s leader and Ctrl+hjkl nav,
# keys moved off what niri and AeroSpace take, and a project/agent workflow on
# built-ins (sessions, worktrees, scratch groups, the Inbox, [hosts]).
{
  inputs,
  config,
  lib,
  ...
}:
let
  # Always-on machines running tuios: every other machine links to these, so
  # their sessions and agents show in its rail, switcher and Inbox. Laptops
  # aren't linked to; asleep, they'd only show as unreachable.
  tuiosServers = lib.filter (
    name:
    lib.all (f: lib.elem f (map (s: s.name) config.hosts.${name}.selected)) [
      "server"
      "tuios"
    ]
  ) (lib.attrNames config.hosts);
in
{
  features.tuios.includes = with config.features; [ paths ];

  features.tuios.homeManager =
    {
      config,
      osConfig,
      pkgs,
      ...
    }:
    let
      tuios = inputs.tuios.packages.${pkgs.stdenv.hostPlatform.system}.default;
      hostName = osConfig.networking.hostName;

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
      # so this uses the new-session verb (docs/protocol.md) and the switch
      # behind herdr's workspace focus, which tuios answers itself through
      # $HERDR_BIN_PATH. Drop both once tuios ships them natively.
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
        # The socket tuios itself reaches (internal/session/manager_unix.go);
        # $TUIOS_SOCKET only reports it (socket_env.go).
        sock=''${XDG_RUNTIME_DIR:+$XDG_RUNTIME_DIR/tuios/tuios.sock}
        sock=''${sock:-/tmp/tuios-$(id -u)/tuios.sock}
        # `ls` exits 3 with no live daemon, a stale socket included.
        rc=0
        tuios ls >/dev/null 2>&1 || rc=$?
        [ "$rc" -ne 3 ] || tuios start-server >/dev/null
        dev=''${DEV_PATH:-${config.devPath}}
        rel=$(
          {
            fd -H -I -t d -d 4 '^\.git$' "$dev" -E local -x dirname {}
            [ ! -d "$dev/local" ] || fd -t d -d 1 . "$dev/local"
          } | sed -e 's|/$||' -e "s|^$dev/||" | sort -u | fzf --prompt 'project> '
        ) || exit 0
        case $rel in
          local/*) name=local.''${rel#local/} ;;
          */*/*) name=$(echo "$rel" | cut -d/ -f2).$(echo "$rel" | cut -d/ -f3) ;;
          *) name=$(basename "$rel") ;;
        esac
        res=$(jq -nc --arg n "$name" --arg c "$dev/$rel" \
          '{id: 1, verb: "new-session", params: {name: $n, cwd: $c}}' \
          | socat -t2 - "UNIX-CONNECT:$sock") || res=
        # session_exists is the reopen case; anything else is a real failure.
        err=$(printf '%s' "''${res:-{\}}" | jq -r \
          'if .result then empty elif .error.code == "session_exists" then empty
           else .error.message // "no answer from the tuios daemon" end')
        if [ -n "$err" ]; then
          printf '%s\nPress Enter to close.' "$err"
          read -r _
          exit 1
        fi
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

      # Keeps a server's sessions and agents alive with nobody logged in, for
      # the machines that link to it. keep-old: a switch must not restart it
      # and kill every pane. To run a new binary, `tuios kill-server` (or
      # `systemctl --user restart tuios-daemon`): sessions come back with their
      # layout, directories and scrollback, but every running program, editor
      # and agent process ends (docs/SESSIONS.md, What Survives).
      systemd.user.services.tuios-daemon = lib.mkIf (lib.elem hostName tuiosServers) {
        Unit = {
          Description = "tuios daemon";
          X-SwitchMethod = "keep-old";
        };
        Service = {
          ExecStart = "${tuios}/bin/tuios daemon";
          Restart = "always";
          RestartSec = 1;
          # Everything the daemon starts inherits these. Pane shells read the
          # rest from zshenv, but popups, scratch commands, agents and hooks
          # are exec'd without a shell, so they need them from here.
          Environment = [
            "PATH=/etc/profiles/per-user/${config.home.username}/bin:/run/current-system/sw/bin:/run/wrappers/bin"
            "SHELL=${config.programs.zsh.package}/bin/zsh"
            "DEV_PATH=${config.devPath}"
          ]
          ++ lib.optional (
            config.home.sessionVariables ? EDITOR
          ) "EDITOR=${config.home.sessionVariables.EDITOR}"
          ++ lib.optional config.services.ssh-agent.enable "SSH_AUTH_SOCK=%t/${config.services.ssh-agent.socket}";
        };
        Install.WantedBy = [ "default.target" ];
      };

      # tuios merges this over its defaults and leaves a read-only file alone,
      # but writers like `tuios hosts add` and the settings page can't persist,
      # so hosts come from the inventory below.
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
      ''
      + lib.concatMapStrings (name: ''

        [hosts.${name}]
        addr = "${name}"
      '') (lib.remove hostName tuiosServers);
    };
}
