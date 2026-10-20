#!/bin/bash

workspaces=$(omniwmctl query workspaces --fields number,display,is-visible,window-counts 2>/dev/null)
displays=$(sketchybar --query displays)

# OmniWM isn't answering: keep what the bar shows.
jq -e '(.result.payload.workspaces // []) | length > 0' <<< "$workspaces" >/dev/null || exit 0

args=()
while read -r name drawing active number; do
  args+=(--set "$name" drawing="$drawing" icon.highlight="$active"
    click_script="omniwmctl command switch-workspace $number")
done < <(jq -rn --argjson ws "$workspaces" --argjson ds "$displays" '
  $ws.result.payload.workspaces as $all
  | range(1; 4) as $d
  | ([$ds[] | select(."arrangement-id" == $d) | "display:\(.DirectDisplayID)"][0]) as $id
  | [$all[] | select(.display.id == $id)] as $mine
  | range(1; 10) as $n
  | $mine[$n - 1] as $w
  | if $w == null then "space.\($d).\($n) off false 0"
    else "space.\($d).\($n) \(if $w.isVisible or ($w.counts.total - $w.counts.scratchpad) > 0
      then "on" else "off" end) \($w.isVisible) \($w.number)"
    end')

sketchybar --animate tanh 10 "${args[@]}"
