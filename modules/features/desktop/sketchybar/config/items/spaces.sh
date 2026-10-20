#!/bin/bash

# No background or outer padding of their own: space_bracket draws one pill
# behind whichever of them are shown.
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

# Numbered by position on the focused display (OmniWM's workspace slots),
# like niri's workspaces and Option+1…9.
for sid in {1..9}
do
  sketchybar --add item space.$sid left \
             --set space.$sid "${SPACE[@]}" \
                  icon=$sid \
                  click_script="omniwmctl command switch-workspace slot $sid"
done

# One hidden item redraws all nine, so each event costs a single query.
# updates=on: a hidden item's script would otherwise not run.
sketchybar --add item spaces left \
           --set spaces drawing=off updates=on script="$PLUGIN_DIR/space.sh" \
           --subscribe spaces omniwm_workspaces_changed

sketchybar --add bracket space_bracket '/space\.[0-9]/' \
           --set space_bracket background.color=$BG_SEC_COLR \
                               background.drawing=on
