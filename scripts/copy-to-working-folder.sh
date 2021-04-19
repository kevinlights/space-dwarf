#!/bin/bash


# https://www.aseprite.org/docs/cli/

s=$1
filename="${s##*/}"

GAME="space-dwarf"

spritedir=~/Development/love/$GAME/assets/sprites/
datadir=~/Development/love/$GAME/assets/data/

aseprite -b \
         --all-layers \
         --ignore-layer Background \
         --split-layers \
         $1 \
         --filename-format '{path}/{title}.{extension}' \
         --sheet $spritedir"${filename%.*}".png \
         --sheet-type rows \
         --data  $datadir"${filename%.*}".json \
         --format json-array \
         --list-tags \
         --list-slices
