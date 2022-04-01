#!/bin/bash
# Calls i3lock-color with background image identical to Variety's current wallpaper
# Adds blur and lock icon / text
LOCK_ICON="${LOCK_ICON:-/home/hactar/Source/i3lock-fancy/icons/lock.png}"
LOCK_FONT="${LOCK_FONT:-"$(convert -list font | awk "{ a[NR] = \$2 } /family: $(fc-match sans -f "%{family}\n")/ {print a[NR-1]; exit}")"}"
LOCK_PROMPT="${LOCK_PROMPT:-Type Password to Unlock}"
LOCK_SCREEN=~/.cache/lock-screen.png

convert "$(variety --show-current)" -font "$LOCK_FONT" \
    -pointsize 26 -fill white -gravity center \
    -annotate +0+160 "$LOCK_PROMPT" "$LOCK_ICON" \
    -gravity center -composite "$LOCK_SCREEN"
