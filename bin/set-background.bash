#!/bin/bash

WAL_DIR="${HOME}/.cache/wal"
WAL_BACKGROUND="${WAL_DIR}/background.jpg"
WALLPAPERS="${WALLPAPERS:-${HOME}/.local/share/wallpapers/Wallpapers}"
declare -i NUM_BGS=2
declare -a BGS

make_vim_terminal_bg() {
	# "Translate" the first section of colors-wal.vim into vim stylesheet
	# Note that this depends on the specific output format of pywal
	sed '1,/^$/d' "${WAL_DIR}/colors-wal.vim" | sed 's/color\(.*\)/g:terminal_color_\1/g' >"${WAL_DIR}/terminal-colors-wal.vim"
}

BGS=($(find -L $WALLPAPERS \
	-name .git -prune -o -type f -exec bash -c \
	'path="$(realpath "$1")"; [[ "$(file -bi "$path")" = image/* ]]' bash {} \; \
	-print | shuf -n $NUM_BGS))

echo "${BGS[@]}" >&2

feh --bg-scale -- "${BGS[@]}"
convert -resize x500 -- "${BGS[@]}" +append "$WAL_BACKGROUND"
wal -n -i "$WAL_BACKGROUND"
make_vim_terminal_bg
