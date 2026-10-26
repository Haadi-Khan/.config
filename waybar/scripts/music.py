#!/usr/bin/env python3
# Scrolling now-playing text for Waybar (custom/music). Fixed width, marquee when too long.
import json
import subprocess
import sys
import time
from html import escape

PLAYER = "cider"
WIDTH = 25        # visible characters
TICK = 0.3        # seconds per scroll step
POLL_EVERY = 3    # ticks between playerctl polls
HOLD = 17         # ticks to pause at the start of each loop (~5s)
GAP = "     "       # separator between loops of scrolling text
ICONS = {"Playing": "", "Paused": ""}


def query():
    fmt = "{{status}}\t{{title}}\t{{artist}}\t{{album}}"
    try:
        out = subprocess.run(
            ["playerctl", "-p", PLAYER, "metadata", "--format", fmt],
            capture_output=True, text=True, timeout=2,
        ).stdout.rstrip("\n")
    except subprocess.TimeoutExpired:
        return None
    parts = out.split("\t")
    if len(parts) != 4 or parts[0] not in ICONS:
        return None
    return parts


def emit(obj):
    sys.stdout.write(json.dumps(obj) + "\n")
    sys.stdout.flush()


def main():
    info, offset, hold, tick, last = None, 0, 0, 0, None
    while True:
        if tick % POLL_EVERY == 0:
            new = query()
            if new != info:
                # restart the scroll when the song changes
                if not new or not info or new[1:] != info[1:]:
                    offset, hold = 0, 0
                info = new
        tick += 1

        if not info:
            out = {"text": "", "class": "stopped"}
        else:
            status, title, artist, album = info
            label = f"{title} — {artist}" if artist else title
            if len(label) <= WIDTH:
                visible = label.ljust(WIDTH)
            else:
                loop = label + GAP
                visible = (loop * 2)[offset:offset + WIDTH]
                if status != "Playing":
                    pass
                elif offset == 0 and hold < HOLD:
                    hold += 1
                else:
                    offset = (offset + 1) % len(loop)
                    if offset == 0:
                        hold = 0
            out = {
                "text": f"{ICONS[status]} {escape(visible)}",
                "class": status.lower(),
                "tooltip": escape(f"{title}\n{artist} — {album}"),
            }

        if out != last:
            emit(out)
            last = out
        time.sleep(TICK)


if __name__ == "__main__":
    main()
