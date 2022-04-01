#!/bin/bash
# Run `maza` to update DNS blacklist, then copy the output to dnsmasq conf location

MAZA_OUTPUT="/home/${USER}/.maza/dnsmasq.conf"
DESTDIR="/home/dnsmasq/dnsmasq.d"

cat <<-NOTIFY >&2
Attempting to update DNS blacklist '${MAZA_OUTPUT}'
Updated blacklist will be installed to '${DESTDIR}'
NOTIFY

error() {
        local -i code=$1 && shift || local -i code=-1
        echo "$@" >&2
        exit $code
}

if ! command -v maza >/dev/null 2>&1; then
        error 1 "Command 'maza' not found"
elif ! mkdir -p "$DESTDIR"; then
        error 2 "Could not create target directory '$DESTDIR'"
elif ! maza update >/dev/null 2>&1; then
        error 3 "Could not update DNS blacklist"
else
        install -g dnsmasq -m 664 --backup=off -t "$DESTDIR" "$MAZA_OUTPUT" ||
        error 3 "Failed to install updated DNS blacklist"
fi
