#!/bin/sh
# Launch stalonetray in background, then unmap
# Keybindings to map/unmap tray can then be configured in i3 config

stalonetray --window-type normal -bg "#111111" &
xdotool windowunmap "$(xdotool search --class stalonetray)"
