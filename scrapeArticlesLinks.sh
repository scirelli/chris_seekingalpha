#!/bin/bash

#for i in {1..5112073}; do
MAX=5112073
i=1373; while [ $i -lt $MAX ]; do
    curl -s \
        --dump-header - \
        --user-agent "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/61.0.3163.100 Safari/537.36" \
        --header "authority:seekingalpha.com" \
        --header "method:GET" \
        --header "path:/article/$i" \
        --header "scheme:https" \
        https://seekingalpha.com/article/$i \
        -o /dev/null | grep -i location | cut -d' ' -f2 | tee -a ./articles.txt
    echo -n "$i, "
    i=$(( $i + 1 ))
#    sleep 1
done
# curl -s \
#     --dump-header - \
#     --user-agent "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/61.0.3163.100 Safari/537.36" \
#     --header "authority:seekingalpha.com" \
#     --header "method:GET" \
#     --header "path:/article/$i" \
#     --header "scheme:https" \
#     https://seekingalpha.com/article/$i \
#     -o /dev/null | grep -i location | cut -d' ' -f2 | tee -a /tmp/articles.txt
