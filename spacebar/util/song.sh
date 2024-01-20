#!/bin/bash

# Fetch title and artist
TITLE="$(~/.config/spacebar/util/nowplaying-cli get title)"
ARTIST="$(~/.config/spacebar/util/nowplaying-cli get artist)"

# Check if either title or artist is null
if [ "$TITLE" = "null" ] || [ "$ARTIST" = "null" ]; then
    echo "No Song Playing"
else
    concatenated="$TITLE$ARTIST"

    if [ ${#concatenated} -gt 70 ]; then
        echo "Now Playing"
    else
        echo "$TITLE - $ARTIST"
    fi
fi
