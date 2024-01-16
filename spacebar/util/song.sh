#!/bin/bash

TITLE="$(~/.config/spacebar/util/nowplaying-cli get title)"
ARTIST="$(~/.config/spacebar/util/nowplaying-cli get artist)"

if [ "$TITLE" = "null" ] || [ "$ARTIST" = "null" ]; then
    echo "No Song Playing"
else
    echo "$TITLE - $ARTIST"
fi
