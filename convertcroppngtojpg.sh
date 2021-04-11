#!/bin/bash

# useful for gax converted pngs to trim the extra space

for f in *.png; do echo convert "$f" -crop 1280x720+0+0 "${f/\.png/\.jpg}" ; done


