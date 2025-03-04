#!/bin/bash

# Apply wallpaper using wal
wal -i ~/Wallpaper/claudio-testa-FrlCwXwbwkk-unsplash.jpg &&

# Start picom
picom --config ~/.config/picom/picom.conf &

# Start megasync
megasync &

# Start nordvpn
nordtray &

# Polkit
/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 &
