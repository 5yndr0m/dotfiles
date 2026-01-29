#!/bin/bash

# If an instance is already running, kill it (toggle off)
if pgrep -f "systemd-inhibit.*Caffeine" > /dev/null; then
    pkill -f "systemd-inhibit.*Caffeine"
    notify-send "Caffeine" "Mode Disabled" -i coffee-off
    exit 0
fi

# Enable Caffeine (toggle on)
notify-send "Caffeine" "Mode Enabled" -i coffee
systemd-inhibit --why="Manual Caffeine Mode" \
                --what=idle \
                --mode=block \
                sleep infinity
