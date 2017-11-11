#!/bin/bash

FILE_SIZE_THRESHOLD=4325
DELAY_TIME_SECONDS=20

urlFileName="/home/pi/Extended/seekingalpha/articles.clean.txt"
htmlOutput="/home/pi/Extended/seekingalpha/html"
machine_cookie=2454333875227
bknx_fa=1510344728513
bknx_ss=1510344728513
cookie="bknx_fa=$bknx_fa; bknx_ss=$bknx_ss; machine_cookie=$machine_cookie; __sa_data__=%7B%22sessionReferrer%22%3A%22https%3A%2F%2Fseekingalpha.com%2Fclean%22%2C%22sessionExpiration%22%3A1510346861107%2C%22sessionID%22%3A%22033f58f7-fa66-462f-855a-706dfb3ddd21.0%22%7D; _pxCaptcha=03AHhf_50kYtSydAwi8MScGk4vJ6Zm9u4GxXUKZyN-XkfQMoVvVZIUjPkXpwOQdhOKArC_84lelJ0mqgaHltXvsA9Z77DPDrq7a2F127SCL5RBp3-TLfbn-LddTRHcBArhcJ8IcPuOHamDjJkdJvqhNqB3BmiIUPBpxD0CrVmH1Y2Nd5ngaN0bsp4ayar9RDMm0xVaQYbwbEVHFh3hABzQysa6qGnpyyg6yPzVVxwHw4X9MTKKahyBmJqpXzSkPXKUzASiNqzL9Oj1GdLFovuOa3nsuNAKyC89cHUrJ2NugwvUyxl4rZJt4MBIbTt0LGitZHPkMxs-ppWcCiEsobdosTa___e6BJigUVjxcD6ouSurtUp5D5Kp_TfasVOTtC6cr53LTFzRJuvd9eGeiX0BHxv2oMo7ouYiLZCo9mGbIdlG6TV0XPJLIOM::39ac5fc0-c654-11e7-ba7c-a3be0dcefa96"

cookie=""

makeRequest(){
    url=$1
    echo $url
    id=`echo $url | grep -o "article/[0-9]\+" | cut -d/ -f2`
    echo "id= $id"

    # --cookie "$cookie" \
    # --verbose \
    curl --silent \
        --user-agent "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/61.0.3163.100 Safari/537.36" \
        --header "authority:seekingalpha.com" \
        --header "method:GET" \
        --header "path:/article/$i" \
        --header "scheme:https" \
        --dump-header $htmlOutput/${id}_headers.txt \
        --cookie-jar "./cookies_out.txt" \
        --output $htmlOutput/$id.html \
        "$url"

    fileSize=`stat -c %s $htmlOutput/$id.html`
    if [ $fileSize -gt 0 ] && [ $fileSize -le $FILE_SIZE_THRESHOLD ]; then
        echo "To small"
        return 1
    fi

    return 0
}

while read url; do
    makeRequest $url
    while [ $? -gt 0 ]; do
        echo "Sleeping for $DELAY_TIME_SECONDS seconds."
        sleep $DELAY_TIME_SECONDS
        makeRequest $url
    done
done

exit 0
#    xargs curl --silent \
#        --user-agent "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/61.0.3163.100 Safari/537.36" \
#        --header "authority:seekingalpha.com" \
#        --header "method:GET" \
#        --header "path:/article/$i" \
#        --header "scheme:https" \
#        --remote-name \
#        {} < $urlFileName
