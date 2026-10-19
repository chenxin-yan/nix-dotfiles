#!/bin/bash

# Like niri's bar: show the workspaces with windows and the one in view.
# Rift's query covers the focused display.
args=()
while read -r index active count; do
  drawing=off
  if [ "$active" = true ] || [ "$count" -gt 0 ]; then
    drawing=on
  fi
  args+=(--set "space.$((index + 1))" drawing="$drawing" icon.highlight="$active")
done < <(rift-cli query workspaces 2>/dev/null | jq -r '.[] | "\(.index) \(.is_active) \(.window_count)"')

if [ ${#args[@]} -gt 0 ]; then
  sketchybar --animate tanh 10 "${args[@]}"
fi
