#!/bin/bash

SPACE=(
  icon.padding_left=18
  icon.padding_right=18
  label.padding_right=33
  icon.color=$WHITE
  icon.font="$FONT:ExtraBold:14.0"
  icon.highlight_color=$SKY
  icon.background.drawing=on
  background.padding_left=-8
  background.padding_right=-8
  background.color=$BG_SEC_COLR
  background.corner_radius=10
  background.drawing=on
  label.drawing=off
  drawing=off
)

sketchybar --add event rift_workspaces_changed

# Numbered by position, like niri's workspaces; Rift counts from 0.
for sid in {1..9}
do
  sketchybar --add item space.$sid left \
             --set space.$sid "${SPACE[@]}" \
                  icon=$sid \
                  click_script="rift-cli execute workspace switch $((sid - 1))"
done

# One hidden item redraws all nine, so each event costs a single query.
# updates=on: a hidden item's script would otherwise not run.
sketchybar --add item spaces left \
           --set spaces drawing=off updates=on script="$PLUGIN_DIR/space.sh" \
           --subscribe spaces rift_workspaces_changed

sketchybar --add item space_separator_left left \
           --set space_separator_left icon= \
                                 icon.font="$FONT:Bold:16.0" \
                                 background.padding_left=16 \
                                 background.padding_right=10 \
                                 label.drawing=off \
                                 icon.color=$DARK_WHITE
