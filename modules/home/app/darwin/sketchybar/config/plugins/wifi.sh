#!/usr/bin/env sh

INTERFACE="$(networksetup -listallhardwareports | awk '/Wi-Fi/{getline; print $2; exit}')"
LABEL="$(/usr/sbin/ipconfig getsummary "$INTERFACE" | awk '/^[[:space:]]*SSID[[:space:]]*:/{sub(/^[^:]*:[[:space:]]*/, ""); print; exit}')"

if [ "$LABEL" = "<redacted>" ]; then
  LABEL="$(networksetup -listpreferredwirelessnetworks "$INTERFACE" | awk 'NR == 2 { sub(/^[[:space:]]*/, ""); ssid=$0 } NR > 2 { ssid="" } END { print ssid }')"
  LABEL="${LABEL:-Connected}"
fi

sketchybar --set wifi label="${LABEL:-Disconnected}"
