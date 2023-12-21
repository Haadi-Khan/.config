#!/usr/bin/env bash

#
#
# Catppuccin Macchiato palette
#
#

export BASE=0xff282c34
export MANTLE=0xff1f2228
export CRUST=0xff1b1d23

export TEXT=0xffabb2bf
export SUBTEXT0=0xff5c6370
export SUBTEXT1=0xff4b5263

export SURFACE0=0xff363a4f
export SURFACE1=0xff494d64
export SURFACE2=0xff5b6078

export OVERLAY0=0xff6e738d
export OVERLAY1=0xff8087a2
export OVERLAY2=0xff939ab7

export BLUE=0xff6197ef
export LAVENDER=0xffc678dd
export SAPPHIRE=0xff8FCFAF
export SKY=0xff61afef
export TEAL=0xff56b6c2
export GREEN=0xff98ac379
export YELLOW=0xffe5c07b
export PEACH=0xffd19a66
export MAROON=0xffbe5046
export RED=0xffe06c75
export MAUVE=0xffa978dd
export PINK=0xffE399B1
export FLAMINGO=0xffD78B86
export ROSEWATER=0xffE2ADA6

export RANDOM_CAT_COLOR=("$BLUE" "$LAVENDER" "$SAPPHIRE" "$SKY" "$TEAL" "$GREEN" "$YELLOW" "$PEACH" "$MAROON" "$RED" "$MAUVE" "$PINK" "$FLAMINGO" "$ROSEWATER")

function getRandomCatColor() {
  echo "${RANDOM_CAT_COLOR[ $RANDOM % ${#RANDOM_CAT_COLOR[@]} ]}"
}

#
# LEGACY COLORS 
#
# Color Palette
export GREY=0xff5c6370
export TRANSPARENT=0x00000000

# General bar colors
export BAR_COLOR=$BASE
export ICON_COLOR=$TEXT # Color of all icons
export LABEL_COLOR=$TEXT # Color of all labels


