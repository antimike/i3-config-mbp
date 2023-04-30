#!/bin/bash
# Set volume using pactl

APPNAME="i3-pulseaudio-adjust-volume"
LOGFILE=~/.cache/i3-pulseaudio-adjust-volume.log
CONTROL_NAME="$1" PROPERTY="$2" && shift 2
exec &>>"$LOGFILE" && printf '\n%s\n' "[$(date +%c)]"

case "$CONTROL_NAME" in
*SINK* | *output*) # Audio
	TYPE=sink
	ICON=notification-audio-volume
	;;
*SOURCE* | *input*) # Mic
	TYPE=source
	ICON=notification-microphone-sensitivity
	;;
esac

echo pactl -- set-${TYPE}-${PROPERTY} "$CONTROL_NAME" "$@"
pactl -- set-${TYPE}-${PROPERTY} "$CONTROL_NAME" "$@"
VOLUME="$(pactl -- get-${TYPE}-volume "$CONTROL_NAME" | grep -o '[0-9]\+%' | head -1)"
MUTE="$(pactl -- get-${TYPE}-mute "$CONTROL_NAME")"

case "$MUTE" in
*yes*)
	ICON="${ICON}-muted"
	;;
*no*) # Control is on
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
	;;
*) # Status isn't "on", "off", or "mute"...
	echo "Unknown control status: ${STATUS}" >&2
	ICON="$STATUS"
	;;
esac

msgTag="set-${ICON}"
msgID=1004 # Allows Dunst to overlay redundant messages so they don't stack
dunstify -a "$APPNAME" -u low -i "${ICON}" \
	-h string:x-dunst-stack-tag:$msgTag \
	-h int:value:"${VOLUME%%%}" \
	-r $msgID \
	"${VOLUME}"

# Play the volume changed sound
canberra-gtk-play -i audio-volume-change -d "changeVolume"
