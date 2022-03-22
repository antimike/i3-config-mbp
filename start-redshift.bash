#!/bin/bash

LOGFILE=~/.cache/redshift.log
pgrep redshift >/dev/null 2>&1 | grep -v $$ || {
        echo "[`date -u`]" >>"$LOGFILE"
        echo "Starting geoclue-2.0 agent and redshift" >>"$LOGFILE"
        /usr/libexec/geoclue-2.0/demos/agent >>"$LOGFILE" 2>&1 &
        redshift >>"$LOGFILE" 2>&1 &
}
