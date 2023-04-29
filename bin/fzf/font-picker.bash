#!/bin/bash
# @NOTE Not sure why, but the alignment is slightly off if /bin/zsh is used

# From fzf-ueberzug
# declare -r -x IMAGE_CACHE_PATH=~/img_preview.png
declare -r -x LOGFILE=~/.cache/logs/"$0".log
declare -r -x DEFAULT_PREVIEW_POSITION="right"

# Use --transfer-mode file to display icat image in FZF
declare -r -x ICAT='kitty +kitten icat --place=${FZF_PREVIEW_COLUMNS}x${FZF_PREVIEW_LINES}@$((TERMINAL_COLUMNS - FZF_PREVIEW_COLUMNS))x${TOP} --silent --transfer-mode file'
declare -x TERMINAL_LINES TERMINAL_COLUMNS
declare -x CURSOR_X CURSOR_Y

# From font-preview
declare -x SEARCH_PROMPT="❯ "
declare -x SIZE=532x365
declare -x POSITION="+0+0"
declare -x FONT_SIZE=38
declare -x BG_COLOR="#ffffff"
declare -x PREVIEW_TEXT="ABCDEFGHIJKLM\nNOPQRSTUVWXYZ\nabcdefghijklm\nnopqrstuvwxyz\n1234567890\n!@$\%()\{\}[]"

declare -r -x IMAGE_CACHE_DIR=~/.cache/fzf-previews/fonts
mkdir -p "$IMAGE_CACHE_DIR"

function main {
	# Get overall terminal dimensions
	read < <(stty </dev/tty size) TERMINAL_LINES TERMINAL_COLUMNS

	# TODO: Add support for Guake-friendly preview method
	trap "kitty +kitten icat --clear" EXIT SIGINT

	# Get cursor position using ANSI witchcraft
	echo -ne '\033[6n' >/dev/tty && IFS='[;' read </dev/tty -t 1 -s -d 'R' _ CURSOR_Y CURSOR_X _

	# List fonts with imagemagick and feed the list to FZF
	convert -list font | awk -F: '/^[ ]*Font: /{print substr($NF,2)}' |
		fzf --prompt="$SEARCH_PROMPT" --preview="
    BOT=\$((CURSOR_Y + FZF_PREVIEW_LINES > TERMINAL_LINES ? TERMINAL_LINES : CURSOR_Y + FZF_PREVIEW_LINES))
    TOP=\$((BOT - FZF_PREVIEW_LINES + 2))
    kitty +kitten icat --transfer-mode file --clear
    PREVIEW=${IMAGE_CACHE_DIR}/{}.png
    if [[ ! -e \"\$PREVIEW\" ]]; then
        convert -size \"$SIZE\" \
            xc:none \
            -background transparent \
            -gravity center \
            -pointsize \"$FONT_SIZE\" \
            -font {} \
            -fill \"$BG_COLOR\" \
            -annotate +0+0 \"$PREVIEW_TEXT\" \
            -flatten \"\$PREVIEW\" \
            >>\"$LOGFILE\" 2>&1 &
        wait
    fi
    ${ICAT} \"\$PREVIEW\""
}

main
