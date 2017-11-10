#!/bin/bash

urlFileName="/home/pi/Extended/seekingalpha/articles.clean.txt"
htmlOutput="/home/pi/Extended/seekingalpha/html"

while read url; do
    echo $url
    id=`echo $url | grep -o "article/[0-9]\+" | cut -d/ -f2`
    echo "id= $id"

    curl --silent \
        --user-agent "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/61.0.3163.100 Safari/537.36" \
        --header "authority:seekingalpha.com" \
        --header "method:GET" \
        --header "path:/article/$i" \
        --header "scheme:https" \
        --cookie "bknx_fa=1507758213769; machine_cookie=2462209434638; __sa_data__=%7B%22sessionReferrer%22%3A%22https%3A%2F%2Fseekingalpha.com%2Fclean%22%2C%22sessionExpiration%22%3A1510336108140%2C%22sessionID%22%3A%226adec2b2-3ff1-4569-bd4f-982dfce7ff60.0%22%7D; bknx_ss=1510334308227" \
        --cookie-jar ./cookies_out.txt \
        --output $htmlOutput/$id.html \
        "$url"
done

#    xargs curl --silent \
#        --user-agent "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/61.0.3163.100 Safari/537.36" \
#        --header "authority:seekingalpha.com" \
#        --header "method:GET" \
#        --header "path:/article/$i" \
#        --header "scheme:https" \
#        --remote-name \
#        {} < $urlFileName
