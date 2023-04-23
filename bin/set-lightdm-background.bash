#!/bin/bash
# Sets background image for slick-greeter

WALLPAPERS="${WALLPAPERS:-${XDG_GREETER_DATA_DIR}/wallpapers}"
LIGHTDM_BACKGROUND="${LIGHTDM_BACKGROUND:-${XDG_GREETER_DATA_DIR}/background.jpg}"
BACKGROUND_HISTORY="${LIGHTDM_BACKGROUND%.*}.history"

error() {
	(local -i code=$1 && shift) || local -i code=-1
	printf '%s\n' "$@" >&2
	exit $code
}

recover_backup() {
	if [[ -e "${LIGHTDM_BACKGROUND}.backup" ]]; then
		mv "${LIGHTDM_BACKGROUND}.backup" "${LIGHTDM_BACKGROUND}"
	fi
	error "$@"
}

if [[ ! -d "$WALLPAPERS" ]]; then
	error 1 "Could not find wallpaper dir '${WALLPAPERS}'"
fi

NEW_BACKGROUND="$(find -L $WALLPAPERS \
	-name .git -prune -o -type f -exec bash -c \
	'path="$(realpath "$1")"; [[ "$(file -bi "$path")" = image/* ]]' bash {} \; \
	-print | shuf -n 1)"

touch -- "$NEW_BACKGROUND" ||
	error 2 "Chosen background does not exist (is wallpaper dir '${WALLPAPERS}' empty?)"

if [[ -e "$LIGHTDM_BACKGROUND" ]]; then
	mv -- "$LIGHTDM_BACKGROUND" "${LIGHTDM_BACKGROUND}.backup"
fi

ln -s -- "$NEW_BACKGROUND" "$LIGHTDM_BACKGROUND" ||
	recover_backup 3 \
		"Failed to link LightDM background '${LIGHTDM_BACKGROUND}' to '${NEW_BACKGROUND}'" \
		"Attempting to recover backup"
printf '%s\t%s\n' "$(date -u +"%Y-%m-%dT%H:%M:%SZ")" "$NEW_BACKGROUND" >>"$BACKGROUND_HISTORY"
