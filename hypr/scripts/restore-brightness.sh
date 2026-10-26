#!/bin/sh
# Restore the brightness systemd-backlight saved at last shutdown (GDM overrides it at login).
# Falls back to 80% on waybar's -e4 scale if the saved value is missing or bogus.
saved=$(cat /var/lib/systemd/backlight/*:backlight:intel_backlight 2>/dev/null)
max=$(cat /sys/class/backlight/intel_backlight/max_brightness)

# Treat anything under ~1% raw (e.g. a hypridle dim of 10) as invalid
if [ -n "$saved" ] && [ "$saved" -gt $((max / 100)) ] 2>/dev/null; then
    brightnessctl -d intel_backlight -q set "$saved" 2>/dev/null
else
    brightnessctl -d intel_backlight -e4 -q set 80% 2>/dev/null
fi
