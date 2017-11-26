#!/usr/bin/env bash

echo "PID=" $$
echo $$ > cleanedHtml.pid

for f in ./html/*.html; do 
    ./htmlCleaner.js < "$f" > `echo $f | sed s/html/cleaned/`;
    echo "Cleaned: " $f
done
