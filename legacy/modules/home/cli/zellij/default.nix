{
  config,
  pkgs,
  lib,
  ...
}:

{
  options = {
    cli.zellij.enable = lib.mkEnableOption "enables zellij terminal multiplexer";
  };

  config = lib.mkIf config.cli.zellij.enable {
    home.packages = with pkgs; [
      zellij
    ];

    xdg.configFile."zellij" = {
      source = ./config;
      recursive = true;
    };

    # Helpers for diagnosing/fixing multi-client sizing issues.
    # When a smaller client (e.g. mosh from phone) attaches to a zellij
    # session, the session shrinks to the smallest viewport. These tools
    # surface the active clients and let you kick the smallest one off.
    programs.zsh.initContent = ''
      # List active zellij clients and pts sizes (smallest first).
      zellij-clients() {
        echo "=== Active zellij attach clients ==="
        ps -eo pid,tty,cmd | grep "zellij attach" | grep -v grep || echo "  (none)"
        echo
        echo "=== Active mosh-servers ==="
        ps -eo pid,cmd | grep "mosh-server" | grep -v grep || echo "  (none)"
        echo
        echo "=== TTY sizes (area  pts  rows cols, smallest first) ==="
        for p in /dev/pts/*; do
          local n s rows cols area
          n=''${p##*/}
          s=$(stty -F "$p" size 2>/dev/null) || continue
          rows=''${s%% *}
          cols=''${s##* }
          area=$(( rows * cols ))
          printf "%8d  pts/%-4s  %s\n" "$area" "$n" "$s"
        done | sort -n
      }

      # Kick the zellij attach client running on the smallest pts.
      # Usage: zellij-kick-smallest [--dry-run|-n]
      zellij-kick-smallest() {
        local dry=0
        [[ "$1" == "--dry-run" || "$1" == "-n" ]] && dry=1
        local smallest_pts="" smallest_area=999999999
        for p in /dev/pts/*; do
          local n s rows cols area
          n=''${p##*/}
          s=$(stty -F "$p" size 2>/dev/null) || continue
          rows=''${s%% *}
          cols=''${s##* }
          area=$(( rows * cols ))
          # Only consider pts that have a zellij attach process.
          if ps -t "$n" -o cmd= 2>/dev/null | grep -q "zellij attach"; then
            if (( area < smallest_area )); then
              smallest_area=$area
              smallest_pts=$n
            fi
          fi
        done
        if [[ -z "$smallest_pts" ]]; then
          echo "No zellij attach clients found."
          return 1
        fi
        local pid size
        pid=$(ps -t "$smallest_pts" -o pid=,cmd= | awk '/zellij attach/ {print $1; exit}')
        size=$(stty -F "/dev/pts/$smallest_pts" size 2>/dev/null)
        echo "Smallest zellij client: pts/$smallest_pts ($size) PID $pid"
        if (( dry )); then
          echo "(dry-run) would: kill $pid"
        else
          kill "$pid" && echo "Killed."
        fi
      }

      # Kill mosh-servers that have no child processes (stale sessions).
      zellij-clean-mosh() {
        local killed=0
        for pid in $(pgrep mosh-server); do
          if ! pgrep -P "$pid" >/dev/null; then
            echo "Killing stale mosh-server $pid"
            kill "$pid" && killed=$(( killed + 1 ))
          fi
        done
        echo "Cleaned $killed stale mosh-server(s)."
      }
    '';
  };
}
