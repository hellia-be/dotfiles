#!/bin/bash

# Apply wallpaper using wal
wal -i ~/Wallpaper/claudio-testa-FrlCwXwbwkk-unsplash.jpg &&

# Start picom
picom --config ~/.config/picom/picom.conf &

# Start megasync
megasync &

# Start nordvpn
nordtray &

# Flameshot
flameshot &

# Network Manager
nm-applet &

# Sound applet
pasystray &

# Bluetooth
blueman-applet &

# Battery
cbatticon -n -c 5 &

# xidle
xautolock -time 600 -locker "betterlockscreen -l" &

# Polkit
/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 &

# Rotating screen on GPD
if [ "$(hostname)" == "arch-gpd" ]; then
	xrandr --output eDP-1 --rotate right
fi
