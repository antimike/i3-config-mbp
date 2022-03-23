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
            ICON=notification-audio-volume
            ;;
    Capture)    # Mic
            ICON=notification-microphone-sensitivity
            ;;
esac

case "$STATUS" in
        off|mute)
                ICON="${ICON}-muted"
                ;;
        on)     # Control is on
                typeset -i vol=${VOLUME%%%}
                if [[ $vol -lt 33 ]]; then
                        ICON="${ICON}-low"
                elif [[ $vol -lt 67 ]]; then
                        ICON="${ICON}-medium"
                elif [[ $vol -le 100 ]]; then
                        ICON="${ICON}-high"
                else
                        # Should never occur
                        ICON=system-error
                fi

                # Clear icon if we just changed
                if [[ $vol -eq 33 || $vol -eq 67 ]]; then
                        dunstctl close
                fi
                ;;
        *)      # Status isn't "on", "off", or "mute"...
                echo "Unknown control status: ${STATUS}" >&2
                ICON="$STATUS"
                ;;
esac

msgTag="set-${ICON}"
msgID=1002
dunstify -a "$APPNAME" -u low -i "${ICON}" \
        -h string:x-dunst-stack-tag:$msgTag \
        -h int:value:"${VOLUME%%%}" \
        -r $msgID \
        "${VOLUME}"

# Play the volume changed sound
canberra-gtk-play -i audio-volume-change -d "changeVolume"
