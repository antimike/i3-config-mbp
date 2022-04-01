#!/bin/bash
# Generates an image preview for FZF widgets

declare FZF_TERMINAL_LINES FZF_TERMINAL_COLUMNS CURSOR_X CURSOR_Y
if [[ -z "$FZF_TERMINAL_LINES" || -z "$FZF_TERMINAL_COLUMNS" ]]; then
        # Get overall terminal dimensions
        < <(</dev/tty stty size) \
                read TERMINAL_LINES TERMINAL_COLUMNS
fi

# Get cursor position using ANSI witchcraft
echo -ne '\033[6n' >/dev/tty &&
        IFS='[;' </dev/tty read -t 1 -s -d 'R' _ CURSOR_Y CURSOR_X _

declare -i BOT="$((CURSOR_Y + FZF_PREVIEW_LINES > FZF_TERMINAL_LINES ? FZF_TERMINAL_LINES : CURSOR_Y + FZF_PREVIEW_LINES))"
declare TOP="$((BOT - FZF_PREVIEW_LINES + 2))"
declare PREVIEW="${1:-${FZF_PREVIEW_FILE}}"
declare SIZE="${FZF_PREVIEW_SIZE:-$((FZF_PREVIEW_LINES * ))"

if [[ ! -e "$1" ]]; then
        convert -size "${FZF_PREVIEW_SIZE:-}" \
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
