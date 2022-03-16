#!/bin/zsh

# From fzf-ueberzug
declare -r -x IMAGE_CACHE_PATH=~/img_preview.png
declare -r -x DEFAULT_PREVIEW_POSITION="right"
# Use --transfer-mode file to display icat image in FZF
declare -r -x ICAT_CLEAR="kitty +kitten icat --transfer-mode file --clear"
declare -r -x ICAT='kitty +kitten icat --place=${FZF_PREVIEW_COLUMNS}x${FZF_PREVIEW_LINES}@$((TERMINAL_COLUMNS - FZF_PREVIEW_COLUMNS))x${TOP} --silent --transfer-mode file'
declare -x TERMINAL_LINES TERMINAL_COLUMNS
declare -x CURSOR_X CURSOR_Y

# From font-preview
declare -x SEARCH_PROMPT="❯ "
declare -x SIZE=532x365
declare -x POSITION="+0+0"
declare -x FONT_SIZE=38
declare -x BG_COLOR="#ffffff"
declare -x FG_COLOR="#000000"
declare -x PREVIEW_TEXT="ABCDEFGHIJKLM\nNOPQRSTUVWXYZ\nabcdefghijklm\nnopqrstuvwxyz\n1234567890\n!@$\%(){}[]"


function main {
        # Get overall terminal dimensions
        < <(</dev/tty stty size) \
                read TERMINAL_LINES TERMINAL_COLUMNS

        # Ensure graphics are cleared on completion, including interrupts
        trap 'kitty +kitten icat --clear' EXIT SIGINT

        # Get cursor position using ANSI witchcraft
        echo -ne '\033[6n' >/dev/tty && IFS='[;' </dev/tty read -t 1 -s -d 'R' _ CURSOR_Y CURSOR_X _

        # List fonts with imagemagick and feed the list to FZF
        convert -list font | awk -F: '/^[ ]*Font: /{print substr($NF,2)}' |
                fzf --prompt="$SEARCH_PROMPT" --preview="
                        BOT=\$((CURSOR_Y + FZF_PREVIEW_LINES > TERMINAL_LINES ? TERMINAL_LINES : CURSOR_Y + FZF_PREVIEW_LINES))
                        TOP=\$((BOT - FZF_PREVIEW_LINES + 2))
                        kitty +kitten icat --transfer-mode file --clear &&
                        convert -size '$SIZE' \
                                xc:none \
                                -background transparent \
                                -gravity center \
                                -pointsize '$FONT_SIZE' \
                                -font {} \
                                -fill '$BG_COLOR' \
                                -annotate +0+0 '$PREVIEW_TEXT' \
                                -flatten '$IMAGE_CACHE_PATH' &&
                        kitty +kitten icat \
                                --place=\${FZF_PREVIEW_COLUMNS}x\${FZF_PREVIEW_LINES}@\$((TERMINAL_COLUMNS - FZF_PREVIEW_COLUMNS - 4))x\${TOP} \
                                --silent --transfer-mode file '$IMAGE_CACHE_PATH'"
}

main
