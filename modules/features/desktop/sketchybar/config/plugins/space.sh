#!/bin/bash

# Like niri's bar: show the workspaces with windows and the one in view.
# Slot N is the focused display's Nth workspace; the query lists each
# display's workspaces in that order. Scratchpad windows stay hidden until
# summoned, so they don't count.
rows=()
while read -r row; do
  rows+=("$row")
done < <(omniwmctl query workspaces --fields display,is-current,window-counts 2>/dev/null | jq -r '
  (.result.payload.workspaces // []) as $ws
  | ($ws[] | select(.isCurrent) | .display.id) as $display
  | $ws[] | select(.display.id == $display)
  | "\(.isCurrent) \(.counts.total - .counts.scratchpad)"')

# OmniWM isn't answering: keep what the bar shows.
[ ${#rows[@]} -gt 0 ] || exit 0

args=()
for sid in {1..9}; do
  read -r active count <<< "${rows[sid - 1]:-false 0}"
  drawing=off
  if [ "$active" = true ] || [ "$count" -gt 0 ]; then
    drawing=on
  fi
  args+=(--set "space.$sid" drawing="$drawing" icon.highlight="$active")
done

sketchybar --animate tanh 10 "${args[@]}"
