#!/bin/bash

WAL_BACKGROUND=~/.cache/wal/background.jpg
WALLPAPERS="${WALLPAPERS:-${HOME}/.local/share/wallpapers/Wallpapers}"
declare -i NUM_BGS=2

declare -a BGS=( $(find "$WALLPAPERS" -type f | shuf -n $NUM_BGS) )
feh --bg-scale -- "${BGS[@]}"
convert -resize x500 -- "${BGS[@]}" +append "$WAL_BACKGROUND"
wal -n -i "$WAL_BACKGROUND"
