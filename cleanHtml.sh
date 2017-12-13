#!/usr/bin/env bash

if [ -e cleanedHtml.pid ]; then
    exit 0
fi

echo "PID=" $$
echo $$ > cleanedHtml.pid

for f in ./html/*.html; do 
    ./htmlCleaner.js < "$f" > `echo $f | sed s/html/cleaned/`;
    echo "Cleaned: " $f
done

rm cleanedHtml.pid
