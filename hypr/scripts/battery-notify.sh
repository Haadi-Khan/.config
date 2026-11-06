#!/bin/sh
# Low-battery notifications: once at 15%, again at 5%, re-armed when plugged in.
bat=/sys/class/power_supply/BAT1
warned=100
while sleep 60; do
    status=$(cat "$bat/status"); cap=$(cat "$bat/capacity")
    if [ "$status" != Discharging ]; then warned=100; continue; fi
    if [ "$cap" -le 5 ] && [ "$warned" -gt 5 ]; then
        notify-send -u critical -i battery-caution "Battery critical" "$cap% left. Plug in now."
        warned=5
    elif [ "$cap" -le 15 ] && [ "$warned" -gt 15 ]; then
        notify-send -u normal -i battery-low "Battery low" "$cap% left"
        warned=15
    fi
done
