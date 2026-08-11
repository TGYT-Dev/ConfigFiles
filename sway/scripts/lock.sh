#!/bin/bash
IMAGE=/tmp/swaylock.png
grim $IMAGE
magick $IMAGE -scale 50% -blur 0x2 -resize 200% $IMAGE
swaylock -i $IMAGE
