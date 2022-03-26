#!/bin/bash
# Sets background image for slick-greeter

LIGHTDM_BACKGROUND=/usr/share/wallpapers/background.jpg
BACKGROUNDS=/home/hactar/.local/share/wallpapers/Wallpapers

pick="${BACKGROUNDS}/$(ls "$BACKGROUNDS" | shuf -n 1)"
case "${pick##*.}" in
        jpg)
                cp "$pick" "$LIGHTDM_BACKGROUND"
                ;;
        *)
                convert "$pick" "$LIGHTDM_BACKGROUND"
                ;;
esac
