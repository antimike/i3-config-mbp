#!/bin/bash
# Set volume using playerctl
# BUG: Becomes unresponsive at 57% (??)
# NOTE: This script is buggy but at least it sets the volume on the right control (unlike Alsa)

APPNAME="i3-audio-player-adjust"
ICON=notification-audio-volume

# Change the volume using playerctl
playerctl volume "$@"

# Get current volume
vol=$(printf '%.2f * 100\n' "$(playerctl volume)" | bc | cut -d. -f1)
if [[ $vol -eq 0 ]]; then
        ICON="${ICON}-muted"
elif [[ $vol -lt 33 ]]; then
        ICON="${ICON}-low"
elif [[ $vol -lt 67 ]]; then
        ICON="${ICON}-medium"
elif [[ $vol -le 100 ]]; then
        ICON="${ICON}-high"
else
        # Should never occur
        ICON=system-error
fi

if [[ $vol -eq 0 || $vol -eq 33 || $vol -eq 67 ]]; then
        dunstctl close
fi

msgTag="set-${ICON}"
msgID=1003
dunstify -a "$APPNAME" -u low -i "${ICON}" \
        -h string:x-dunst-stack-tag:$msgTag \
        -h int:value:"$vol" \
        -r $msgID \
        "${vol}%"

# Play the volume changed sound
canberra-gtk-play -i audio-volume-change -d "changeVolume"
