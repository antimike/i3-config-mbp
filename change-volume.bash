#!/bin/bash
# changeVolume

APPNAME="i3-audio-adjust"
CONTROL_NAME="$1" && shift

case "$CONTROL_NAME" in
    Master) ICON=audio UNMUTE=volume-high MUTE=volume-muted ADJUST=volume-high ;;
    Capture) ICON=mic UNMUTE=on MUTE=off ADJUST=volume-high ;;
esac

# Arbitrary but unique message tag
msgTag="set-${ICON}-volume"

# Change the volume using alsa
amixer set "$CONTROL_NAME" "$@" > /dev/null

# Query amixer for the current volume and whether or not the speaker is muted
volume="$(amixer get "$CONTROL_NAME" | tail -1 | grep -o '[0-9]\+%')"
mute="$(amixer get "$CONTROL_NAME" | tail -1 | grep -o '\[\w\+\]')"

if [[ $volume == "0%" || "$mute" == "[off]" ]]; then
    # Show the sound muted notification
    dunstify -a "$APPNAME" -u low -i "${ICON}-${MUTE}" \
        -h string:x-dunst-stack-tag:$msgTag \
        "${ICON} muted"
else
    # Show the volume notification
    dunstify -a "$APPNAME" -u low -i "${ICON}-${ADJUST}" \
        -h string:x-dunst-stack-tag:$msgTag \
        -h int:value:"${volume%%%}" \
        "${volume}"
fi

# Play the volume changed sound
canberra-gtk-play -i audio-volume-change -d "changeVolume"
