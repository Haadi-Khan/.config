for f in /etc/X11/xinit/xinitrc.d/?*.sh ; do
	[ -x "$f" ] && . "$f"
done
unset f

nitrogen --restore &
compton &
feh --bg-scale ~/Storage/Pictures/Wallpaper.jpg &
xrandr --output DVI-D-0 --off --output HDMI-0 --off --output DP-0 --primary --mode 1920x1080 --pos 0x0 --rate 144.00 --rotate normal --output DP-1 --off --output DP-2 --off --output DP-3 --mode 1920x1080 --pos 1920x0 --rotate normal --output DP-4 --off --output DP-5 --off &
exec i3
