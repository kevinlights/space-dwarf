#!/bin/bash

directory=$1
ls $directory/*.aseprite | entr -s './copy-to-working-folder.sh $0'
