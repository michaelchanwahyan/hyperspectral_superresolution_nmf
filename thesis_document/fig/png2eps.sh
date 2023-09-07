#!/bin/sh
#ls *.png | sed s/\.png// | while read line ; do convert $line.png $line.eps ; done
find . -name "*.png" | sed s/\.png// | while read line ; do convert $line.png $line.eps ; done
