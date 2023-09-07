#!/bin/sh
find . -name "*.png" > pnglist
cat pnglist | sed s/.png/.eps/ > epslist
paste pnglist epslist | while IFS="$(printf '\t')" read -r f1 f2
do
  convert $f1 $f2
done