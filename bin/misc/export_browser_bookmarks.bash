#!/bin/bash
# Export Vivaldi bookmarks to JSON for processing by archivebox

BOOKMARKS="${BOOKMARKS:-${HOME}/.config/vivaldi/Default/Bookmarks}"
DEST="${ARCHIVE_INBOX:-/home/archivebox/inbox}/${USER}/bookmarks.json"

mkdir -p "$DEST" &&
        jq --compact-output '
        [ ..| objects| select(has("url")) | {
                href: .url,
                description: .name,
                timestamp: (.date_added|tonumber)
        }]' "$BOOKMARKS" >"$DEST"
