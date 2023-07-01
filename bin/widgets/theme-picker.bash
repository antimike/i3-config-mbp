#!/bin/env bash
# FZF picker for kitty themes

declare -r -x DEFAULT_PREVIEW_POSITION="right"

declare -x TERMINAL_LINES TERMINAL_COLUMNS
declare -x CURSOR_X CURSOR_Y

# From font-preview
declare -x SEARCH_PROMPT="❯ "

declare -r -x THEME_DIR=~/Source/Theme/gogh/installs
declare -r -x PREVIEW_DIR=~/Source/Theme/gogh/images/themes
mkdir -p "$PREVIEW_DIR"

function main {
	# Get overall terminal dimensions
	read < <(stty </dev/tty size) TERMINAL_LINES TERMINAL_COLUMNS

	# TODO: Add support for Guake-friendly preview method
	trap "kitty +kitten icat --clear" EXIT SIGINT

	# Get cursor position using ANSI witchcraft
	echo -ne '\033[6n' >/dev/tty && IFS='[;' read </dev/tty -t 1 -s -d 'R' _ CURSOR_Y CURSOR_X _

	export SHELL=/bin/bash

	find "$THEME_DIR" -type f -name '*.sh' -print |
		fzf --prompt="$SEARCH_PROMPT" --with-nth=-1 --nth=-1 -d '/' --preview="
        VOFF=2
        HOFF=3
        BOT=\$((CURSOR_Y + FZF_PREVIEW_LINES > TERMINAL_LINES ? TERMINAL_LINES - VOFF : CURSOR_Y + FZF_PREVIEW_LINES - VOFF))
        TOP=\$((BOT - FZF_PREVIEW_LINES ))
        LEFT=\$((TERMINAL_COLUMNS - FZF_PREVIEW_COLUMNS - HOFF))
        ICAT=\"kitty +kitten icat --scale-up --place=\${FZF_PREVIEW_COLUMNS}x\${FZF_PREVIEW_LINES}@\${LEFT}x\${TOP} --silent --transfer-mode file\"
        kitty +kitten icat --transfer-mode file --clear
        install_script=\"\$(basename \"{}\")\"
        ps=( $PREVIEW_DIR/\${install_script%.*}.* )
        if [[ -e \"\${ps[0]}\" ]]; then
          \${ICAT} \"\${ps[0]}\"
        else
          echo \"\${ps[0]}\"
        fi
      " | while read file; do $file; done
}

main
