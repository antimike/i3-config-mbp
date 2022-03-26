#!/bin/bash

APPNAME="i3-brightness-adjust"
brightnessctl set "$@" >/dev/null

case "$*" in
    *kbd*)
        ICON=keyboard-brightness-symbolic
        LEVEL=$(brightnessctl -d "*kbd*" info | grep -o "[0-9]\+%")
        ;;
    *)
        ICON=display-brightness
        LEVEL=$(brightnessctl info | grep -o "[0-9]\+%")
        typeset -i level=${LEVEL%%%}

        if [[ $level -eq 0 ]]; then
            ICON="${ICON}-off"
        elif [[ $level -lt 33 ]]; then
            ICON="${ICON}-low"
        elif [[ $level -lt 67 ]]; then
            ICON="${ICON}-medium"
        elif [[ $level -le 100 ]]; then
            ICON="${ICON}-high"
        else
            # Should never occur
            ICON=system-error
        fi
        ICON="${ICON}-symbolic"

        # Clear icon if we just changed
        if [[ $level -eq 0 || $level -eq 33 || $level -eq 67 || $level -eq 100 ]]; then
                dunstctl close
        fi
        ;;
esac

msgTag="set-${ICON}"
msgID=1001
dunstify -a "$APPNAME" -u low -i "$ICON" \
    -h string:x-dunst-stack-tag:$msgTag \
    -h int:value:"${LEVEL%%%}" \
    -r $msgID \
    "$LEVEL"
