#!/usr/bin/env bash

if [ -e listArticles.pid ]; then
    echo "Script is already running"
    cat listArticles.pid
    exit 0
fi

echo "PID=" $$
echo $$ > listArticles.pid

/home/pi/Projects/Chris/chris_seekingalpha/listArticles.sh > /home/pi/Extended/seekingalpha/listArticles.html

rm listArticles.pid
