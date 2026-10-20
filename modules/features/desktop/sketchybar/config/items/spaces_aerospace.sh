#!/bin/bash

# AeroSpace's fixed workspaces 0-6 (aerospace.nix), drawn as one pill like
# OmniWM's in spaces.sh.
SPACE_ICONS=("~" "1:DEV" "2:WEB" "3:TODO" "4:NOTE" "5:CHAT" "6:MEDIA")

SPACE=(
  icon.padding_left=10
  icon.padding_right=10
  icon.color=$WHITE
  icon.font="$FONT:ExtraBold:14.0"
  icon.highlight_color=$SKY
  background.padding_left=0
  background.padding_right=0
  label.drawing=off
)

# Triggered by AeroSpace's exec-on-workspace-change (aerospace.nix).
sketchybar --add event aerospace_workspace_change

for sid in "${!SPACE_ICONS[@]}"; do
  sketchybar --add item space.$sid left \
             --subscribe space.$sid aerospace_workspace_change \
             --set space.$sid "${SPACE[@]}" \
                  icon="${SPACE_ICONS[sid]}" \
                  script="$PLUGIN_DIR/space_aerospace.sh $sid" \
                  click_script="aerospace workspace $sid"
done

sketchybar --add bracket space_bracket '/space\.[0-9]/' \
           --set space_bracket background.color=$BG_SEC_COLR \
                               background.drawing=on
