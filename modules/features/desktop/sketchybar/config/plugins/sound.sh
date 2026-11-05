source "$HOME/.config/sketchybar/icons.sh"

# volume_change passes the new volume; the initial forced run has to ask.
if [ "$SENDER" = volume_change ]; then
    VOLUME=$INFO
else
    VOLUME=$(osascript -e "output volume of (get volume settings)")
fi
MUTED=$(osascript -e "output muted of (get volume settings)")

if [[ $MUTED != "false" ]]; then
    ICON="$SOUND_MUT_ICON"
    VOLUME=0
else
    case ${VOLUME} in
        100) ICON="$SOUND_FUL_ICON" ;;
        [7-9][0-9]) ICON="$SOUND_HIG_ICON" ;;
        [3-6][0-9]) ICON="$SOUND_MID_ICON" ;;
        [1-2][0-9]|[1-9]) ICON="$SOUND_LOW_ICON" ;;
        *) ICON="$SOUND_MUT_ICON"
    esac
fi

sketchybar -m \
    --set $NAME icon=$ICON \
    --set $NAME label="$VOLUME%"
