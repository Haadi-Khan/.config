#!/usr/bin/env bash
# Right Ctrl dictation trigger (keyd maps rightcontrol -> f13; Hyprland binds press/release here).
#   Hold            -> record while held, transcribe + paste on release
#   Double-tap      -> lock recording on; next press stops, transcribes + pastes
#   Single tap      -> discarded (cancels the recording it started)
# Usage: ptt.sh down|up

TAP_MAX_MS=250        # press shorter than this counts as a tap, not a hold
DOUBLE_TAP_MS=400     # max gap between releasing the first tap and pressing the second

dir="${XDG_RUNTIME_DIR:-/tmp}/voxtype-ptt"
mkdir -p "$dir"
now=$(( $(date +%s%N) / 1000000 ))
state=$(cat "$dir/state" 2>/dev/null || echo idle)

case "$1" in
down)
    if [[ $state == locked ]]; then
        voxtype record stop
        echo idle > "$dir/state"
        touch "$dir/ignore_up"
        exit 0
    fi
    voxtype record start
    # Screen context for cleanup: OCR the focused window while you talk (cleanup.py waits ≤1s for it)
    rm -f "$dir/context.json"
    : > "$dir/context.pending"
    setsid -f python3 -I "$HOME/.config/voxtype/screen_context.py" >/dev/null 2>&1
    echo "$now" > "$dir/press_t"
    echo holding > "$dir/state"
    ;;
up)
    if [[ -e $dir/ignore_up ]]; then rm -f "$dir/ignore_up"; exit 0; fi
    [[ $state == holding ]] || exit 0
    press_t=$(cat "$dir/press_t" 2>/dev/null || echo 0)
    last_tap=$(cat "$dir/last_tap" 2>/dev/null || echo 0)
    if (( now - press_t >= TAP_MAX_MS )); then
        # Normal hold: transcribe and paste
        voxtype record stop
        echo idle > "$dir/state"
        echo 0 > "$dir/last_tap"
    elif (( now - last_tap <= DOUBLE_TAP_MS + TAP_MAX_MS )); then
        # Second tap of a double-tap: keep recording, hands-free
        echo locked > "$dir/state"
        echo 0 > "$dir/last_tap"
    else
        # Lone tap: throw away the blip, remember it for double-tap detection
        voxtype record cancel
        echo idle > "$dir/state"
        echo "$now" > "$dir/last_tap"
    fi
    ;;
esac
