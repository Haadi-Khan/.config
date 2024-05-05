# Add event
sketchybar -m --add event song_update com.apple.Music.playerInfo

# Add Music Item
sketchybar -m --add item music center                         \
    --set music script="~/.config/sketchybar/plugins/now-playing/scripts/media-ctrl.sh"  \
    click_script="~/.config/sketchybar/plugins/now-playing/scripts/music_click"  \
    label.padding_right=10                                   \
    drawing=off                                              \
    --subscribe music song_update