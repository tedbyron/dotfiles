#!/usr/bin/env bash

status=$(playerctl status 2>/dev/null)

if [[ $status ]]; then
  title=$(playerctl metadata xesam:title)
  artist=$(playerctl metadata xesam:artist)
  [[ $status == "Playing" ]] && status="播放" || { [[ $status == "Paused" ]] && status="暫停"; }
  echo " $status $title - $artist "
else
  echo
fi
