#!/usr/bin/env bash

echo "PID=" $$
echo $$ > cleanedHtml.pid

while read f; do
    ./htmlCleaner.js < "$f" > `echo $f | sed s/html/cleaned/`;
    echo "Cleaned: " $f
done

rm cleanedHtml.pid
