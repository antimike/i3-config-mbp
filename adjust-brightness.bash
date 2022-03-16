
#!/bin/bash

APPNAME="i3-brightness-adjust"
brightnessctl set "$@" >/dev/null

case "$*" in
    *kbd*)
        ICON=notification-keyboard-brightness
        LEVEL=$(brightnessctl -d "*kbd*" info | grep -o "[0-9]\+%")
        ;;
    *)
        ICON=notification-display-brightness
        LEVEL=$(brightnessctl info | grep -o "[0-9]\+%")
        if [[ ${LEVEL%%%} -eq 0 ]]; then
            ICON="${ICON}-off"
        elif [[ ${LEVEL%%%} -lt 33 ]]; then
            ICON="${ICON}-low"
        elif [[ ${LEVEL%%%} -lt 67 ]]; then
            ICON="${ICON}-medium"
        elif [[ ${LEVEL%%%} -lt 100 ]]; then
            ICON="${ICON}-high"
        elif [[ ${LEVEL%%%} -eq 100 ]]; then
            ICON="${ICON}-full"
        else
            # Should never occur
            ICON=system-error
        fi
        ;;
esac

msgTag="set-${ICON}"
dunstify -a "$APPNAME" -u low -i "$ICON" \
    -h string:x-dunst-stack-tag:$msgTag \
    -h int:value:"${LEVEL%%%}" \
    "$LEVEL"
