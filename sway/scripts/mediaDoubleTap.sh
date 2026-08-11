#!/bin/bash
# mediaDoubleTap.sh <action>
action="$1"
lockFile="/tmp/mediaTap_${action}.lock"
tapInterval=0.3
if [ -f "$lockFile" ]; then
  rm "$lockFile"
  case "$action" in
  play) playerctl next ;;
  esac
else
  touch "$lockFile"
  sleep "$tapInterval"
  if [ -f "$lockFile" ]; then
    rm "$lockFile"
    case "$action" in
    play) playerctl play-pause ;;
    esac
  fi
fi
