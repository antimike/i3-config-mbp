#!/bin/bash
# changeVolume

APPNAME="i3-audio-adjust"
CONTROL_NAME="$1" && shift

# Change the volume using alsa
amixer set "$CONTROL_NAME" "$@" > /dev/null

# Extract bracketed text in last line of `amixer get`
# VOLUME --> volume % after adjustment
# STATUS --> whether control is on or off
< <(amixer get "$CONTROL_NAME" | awk -F '[][]' -vORS=' ' '
        END {for (i=2; i<=NF; i+=2) print $i;}
        ') read VOLUME STATUS

case "$CONTROL_NAME" in
    Master)     # Audio
            ICON=audio
            ;;
    Capture)    # Mic
            ICON=mic
            ;;
esac

case "$STATUS" in
        off|mute)
                if [[ "$ICON" == "audio" ]]; then
                        ICON="audio-volume-muted"
                elif [[ "$ICON" == "mic" ]]; then
                        ICON="mic-off"
                fi
                ;;
        on)     # Control is on
                if [[ ${VOLUME%%%} -lt 33 ]]; then
                        ICON="${ICON}-volume-low"
                elif [[ ${VOLUME%%%} -lt 67 ]]; then
                        ICON="${ICON}-volume-medium"
                elif [[ ${VOLUME%%%} -le 100 ]]; then
                        ICON="${ICON}-volume-high"
                else
                        # Should never occur
                        ICON=system-error
                fi
                ;;
        *)      # Status isn't "on", "off", or "mute"...
                echo "Unknown control status: ${STATUS}" >&2
                ICON="$STATUS"
                ;;
esac

msgTag="set-${ICON}"
dunstify -a "$APPNAME" -u low -i "${ICON}" \
        -h string:x-dunst-stack-tag:$msgTag \
        -h int:value:"${VOLUME%%%}" \
        "${VOLUME}"

# Play the volume changed sound
canberra-gtk-play -i audio-volume-change -d "changeVolume"
