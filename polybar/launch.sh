#!/usr/bin/env bash

# Terminate already running bar instances
killall -q polybar
# If all your bars have ipc enabled, you can also use 
# polybar-msg cmd quit

# Launch bar1 and bar2
#echo "---" | tee -a /tmp/polybar1.log /tmp/polybar2.log
#polybar haadibar 2>&1 | tee -a /tmp/polybar1.log & disown
#polybar bar2 2>&1 | tee -a /tmp/polybar2.log & disown

if type "xrandr"; then
  for m in $(xrandr --query | grep " connected" | cut -d" " -f1); do
    MONITOR=$m polybar --reload workspaces &
    sleep 1
    MONITOR=$m polybar --reload sidebar &
    sleep 1
  done
else
  polybar --reload workspaces &
  sleep 1
  polybar --reload sidebar &
  sleep 1
fi

echo "Bars launched..."
