#!/bin/bash

declare -r -x IMAGE_CACHE_PATH=~/img_preview.png
declare -r -x DEFAULT_PREVIEW_POSITION="right"
declare -r -x UEBERZUG_FIFO="$(mktemp --dry-run --suffix "fzf-$$-ueberzug")"
declare -r -x PREVIEW_ID="preview"

# From fzf-ueberzug script
function calculate_position {
    # TODO costs: creating processes > reading files
    #      so.. maybe we should store the terminal size in a temporary file
    #      on receiving SIGWINCH
    #      (in this case we will also need to use perl or something else
    #      as bash won't execute traps if a command is running)
    < <(</dev/tty stty size) \
        read TERMINAL_LINES TERMINAL_COLUMNS

    case "${PREVIEW_POSITION:-${DEFAULT_PREVIEW_POSITION}}" in
        left|up|top)
            X=1
            Y=1
            ;;
        right)
            X=$((TERMINAL_COLUMNS - COLUMNS - 2))
            Y=1
            ;;
        down|bottom)
            X=1
            Y=$((TERMINAL_LINES - LINES - 1))
            ;;
    esac
}

generate_preview() {
        # Taken from Ranger's preview script `scope.sh`
        preview_png="/tmp/$(basename "${IMAGE_CACHE_PATH%.*}").png"
        if fontimage -o "${preview_png}" \
                 --pixelsize "120" \
                 --fontname \
                 --pixelsize "80" \
                 --text "  ABCDEFGHIJKLMNOPQRSTUVWXYZ  " \
                 --text "  abcdefghijklmnopqrstuvwxyz  " \
                 --text "  0123456789.:,;(*!?') ff fl fi ffi ffl  " \
                 --text "  The quick brown fox jumps over the lazy dog.  " \
                 "${1}";
        then
        convert -- "${preview_png}" "${IMAGE_CACHE_PATH}" \
            && rm "${preview_png}" \
            && return 0
        else
        return 1
        fi
}

icat --clear
generate_preview "$1"
icat --silent $IMAGE_CACHE_PATH
