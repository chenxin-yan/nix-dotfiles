#!/bin/bash

SELECTED=false
[ "$1" = "$FOCUSED_WORKSPACE" ] && SELECTED=true

sketchybar --animate tanh 10 --set "$NAME" icon.highlight=$SELECTED
