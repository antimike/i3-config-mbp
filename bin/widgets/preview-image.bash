#!/bin/bash

case "$TERM" in
        *kitty*) pistol -c ~/.config/pistol/pistol-kitty.conf "$@" ;;
        *) pistol "$@" ;;
esac
