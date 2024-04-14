#!/bin/bash

while :; do
				#NETSTAT="$(nmcli -p | grep wlp9s0 | head -1 | awk '{ print $2 }')"
				#NETNAME="$(if [ $NETSTAT == "connected" ]; then echo "$(nmcli -p | grep wlp9s0 | head -1 | awk '{ print $4 }')"; else echo $NETSTAT; fi)"

				#VOLUME="$(pactl list sinks | grep '^[[:space:]]Volume:' | tail -n $(( $SINK + 1 )) | sed -e 's,.* \([0-9][0-9]*\)%.*,\1,')%"
				VOLUME="$(pactl get-sink-volume @DEFAULT_SINK@ | grep -Po '\d+(?=%)' | head -n 1)%"
				
				TODAY="$(date "+%d %B, %H:%M")"

				MOUSE="$(upower -i $(upower -e | grep 'hidpp') | grep -E "percentage" | awk -F "percentage:" '{ print $2 }' | awk '{ print $1 }')"

				echo "Mouse: ${MOUSE}    Volume: ${VOLUME}    Date: ${TODAY}"
				sleep 1
done