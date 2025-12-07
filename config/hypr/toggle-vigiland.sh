#!/usr/bin/env bash
# ~/.config/hypr/scripts/toggle-vigiland.sh

if pgrep -x vigiland > /dev/null; then
    pkill vigiland
    notify-send -u low "Vigiland" "Inactive"
else
    vigiland &
    notify-send -u normal "Vigiland" "Active"
fi
