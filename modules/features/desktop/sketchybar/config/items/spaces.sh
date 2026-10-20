#!/bin/bash

# No background or outer padding of their own: each display's space_bracket
# draws one pill behind whichever of them are shown.
SPACE=(
  icon.padding_left=10
  icon.padding_right=10
  icon.color=$WHITE
  icon.font="$FONT:ExtraBold:14.0"
  icon.highlight_color=$SKY
  background.padding_left=0
  background.padding_right=0
  label.drawing=off
  drawing=off
)

# Triggered by the sketchybar-omniwm agent (sketchybar/default.nix).
sketchybar --add event omniwm_workspaces_changed

# Each bar shows its own display's workspaces, like Noctalia's on niri
# (show_all_outputs = false): space.<d>.<n> is the nth workspace of the
# display sketchybar numbers d, i.e. Option+n there. Three sets cover
# OmniWM's Main, Secondary and Tertiary displays; a set without a display
# stays hidden.
for did in 1 2 3; do
  for sid in {1..9}; do
    sketchybar --add item space.$did.$sid left \
               --set space.$did.$sid "${SPACE[@]}" display=$did icon=$sid
  done
  sketchybar --add bracket space_bracket.$did "/space\.$did\.[0-9]/" \
             --set space_bracket.$did background.color=$BG_SEC_COLR \
                                      background.drawing=on
done

# One hidden item redraws every set, so each event costs a single query.
# updates=on: a hidden item's script would otherwise not run. display_change:
# adding, removing or rearranging displays renumbers sketchybar's displays.
sketchybar --add item spaces left \
           --set spaces drawing=off updates=on script="$PLUGIN_DIR/space.sh" \
           --subscribe spaces omniwm_workspaces_changed display_change
