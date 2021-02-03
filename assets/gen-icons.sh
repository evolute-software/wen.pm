#!/bin/bash

convert saturn.png -resize 180x180 -quality 100 icons/apple-touch-icon.png
convert saturn.png -resize 32x32 -quality 100 icons/favicon-32.png
convert saturn.png -resize 16x16 -quality 100 icons/favicon-16.png
cp saturn-2.svg icons/safari-pinned-tab.svg

