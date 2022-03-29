#!/bin/bash

[[ -z "$USER" ]] && exit 1
LOGSDIR=/home/${USER}/.cache/logs
find "$LOGSDIR" -type f -name "*.log" -execdir sed -i '1,$d' \{\} \;
