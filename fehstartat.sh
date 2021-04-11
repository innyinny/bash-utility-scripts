#!/bin/bash

# opens the whole directory in feh, and starts at the clicked one
# (set this script as the handler for images)

if [[ ! -f $1 ]]; then
    echo "$0: first argument is not a file" >&2
    exit 1
fi

file=$(basename -- "$1")
dir=$(dirname -- "$1")

cd -- "$dir"

feh --start-at "$file"

