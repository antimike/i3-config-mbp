#!/bin/bash

pick_wallpaper  # greeter, workspace, and lockscreen
cache_theme     # for later reuse
reload_services # i3 stuff

WAL_BACKGROUND=~/.cache/wal/background.jpg
WALLPAPERS="${WALLPAPERS:-${HOME}/.local/share/wallpapers/Wallpapers}"
declare -i NUM_BGS=2        # Two monitors

declare -a BGS="( $(find "$WALLPAPERS" \
                -name .git -prune -o -type f -o -type l -exec bash -c \
                '[[ "$(file -bi "$1")" == image/* ]]' bash {} \; -print \
        | shuf -n $NUM_BGS) )"
feh --bg-scale -- "${BGS[@]}"
convert -resize x500 -- "${BGS[@]}" +append "$WAL_BACKGROUND"
wal -n -i "$WAL_BACKGROUND"
