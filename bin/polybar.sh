#!/bin/sh

killall polybar
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

export DPI=$(xrdb -query | grep dpi | cut -f2)
export HEIGHT=$((18 * DPI / 96))
export BATTERY="$(find /sys/class/power_supply -name "BAT*" -printf '%f')"
export ADAPTER="$(find /sys/class/power_supply -name "ADP*" -printf '%f')"
export BACKLIGHT="$(ls -1 /sys/class/backlight | head -1)"
export WIFI_INTERFACE="$(ip link | grep -o 'wlp[^:]*')"

# Example of setup:
# xrandr --setmonitor '*'DisplayPort-3-left  1920/444x1440/334+0+0     DisplayPort-3
# xrandr --setmonitor    DisplayPort-3-right 1520/352x1440/334+1920+0  none

LOGFILE=~/.cache/polybar.log
MONITORS=$(xrandr --current --listactivemonitors | sed -nE 's/ *([0-9]+): [+*]*([^ ]*).*/\2/p' | tr '\n' ' ')
PRIMARY=$(xrandr --current --listactivemonitors | sed -nE 's/ *([0-9]+): [+]?[*]([^ ]*).*/\2/p')
NMONITORS=$(echo $MONITORS | wc -w)
PRIMARY=${PRIMARY:-${MONITORS%% *}}

touch "$LOGFILE"
echo "[`date -u`]: ${POLYBAR_THEME_DIR}" >>"$LOGFILE"
awk 'BEGIN { i=0 } ($4 == "/" && $3 !~ /^0:/) {print "mount-"i" = "$5; i++}' /proc/self/mountinfo \
    > $XDG_RUNTIME_DIR/i3/polybar-filesystems.conf

case $NMONITORS in
    1)
        MONITOR=$PRIMARY polybar --reload alone >"${LOGFILE}.${MONITOR}" 2>&1 &
        systemd-notify --status="Single polybar instance running on $PRIMARY"
        ;;
    *)
        MONITOR=$PRIMARY polybar --reload primary >"${LOGFILE}.${MONITOR}" 2>&1 &
        for MONITOR in ${MONITORS}; do
            [ $MONITOR != $PRIMARY ] || continue
            MONITOR=$MONITOR polybar --reload secondary >"${LOGFILE}.${MONITOR}" 2>&1 &
        done
        systemd-notify --status="$NMONITORS polybar instances running"
        ;;
esac

systemd-notify --ready
trap "systemd-notify WATCHDOG=trigger" CHLD
wait
