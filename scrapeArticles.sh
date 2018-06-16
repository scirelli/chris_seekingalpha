#!/bin/bash

FILE_SIZE_THRESHOLD=4325
DELAY_TIME_SECONDS=60
REQUEST_DELAY_SECONDS=10
MAX_REQUEST_DELAY_SECONDS=60
MIN_REQUEST_DELAY_SECONDS=10

htmlOutput="/home/pi/Extended/seekingalpha/html"
headerOutput="/home/pi/Extended/seekingalpha/headers"
logCurrentURL="./currentUrl.txt"
fullArticleTmpDir="/tmp/articles"

machine_cookie=2454333875227
bknx_fa=1510344728513
bknx_ss=1510344728513
cookie="bknx_fa=$bknx_fa; bknx_ss=$bknx_ss; machine_cookie=$machine_cookie; __sa_data__=%7B%22sessionReferrer%22%3A%22https%3A%2F%2Fseekingalpha.com%2Fclean%22%2C%22sessionExpiration%22%3A1510346861107%2C%22sessionID%22%3A%22033f58f7-fa66-462f-855a-706dfb3ddd21.0%22%7D; _pxCaptcha=03AHhf_50kYtSydAwi8MScGk4vJ6Zm9u4GxXUKZyN-XkfQMoVvVZIUjPkXpwOQdhOKArC_84lelJ0mqgaHltXvsA9Z77DPDrq7a2F127SCL5RBp3-TLfbn-LddTRHcBArhcJ8IcPuOHamDjJkdJvqhNqB3BmiIUPBpxD0CrVmH1Y2Nd5ngaN0bsp4ayar9RDMm0xVaQYbwbEVHFh3hABzQysa6qGnpyyg6yPzVVxwHw4X9MTKKahyBmJqpXzSkPXKUzASiNqzL9Oj1GdLFovuOa3nsuNAKyC89cHUrJ2NugwvUyxl4rZJt4MBIbTt0LGitZHPkMxs-ppWcCiEsobdosTa___e6BJigUVjxcD6ouSurtUp5D5Kp_TfasVOTtC6cr53LTFzRJuvd9eGeiX0BHxv2oMo7ouYiLZCo9mGbIdlG6TV0XPJLIOM::39ac5fc0-c654-11e7-ba7c-a3be0dcefa96"
cookie=""
exitCode=0

makeRequest(){
    url="$1"

    echo "Processing... "
    echo "$url" | tee "$logCurrentURL"

    path=`echo "$url" | sed 's/https\?:\/\///' | sed 's/seekingalpha.com//'`
    fileName=`echo "$url" | sed 's/https\?:\/\///' | sed 's/\//-/g'`
    fileName="$fileName.html"

    str=$(echo "$url" | openssl dgst -md5 -hex);
    d=${str:$((${#str}-1)):1}
    cleanedDirName="$htmlOutput/$d"
    tmpDirName="$fullArticleTmpDir/$d"
    mkdir -p "$cleanedDirName" 1> /dev/null 2>&1
    mkdir -p "$tmpDirName" 1> /dev/null 2>&1

    curl --silent \
        --verbose \
        --location \
        --user-agent "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/61.0.3163.100 Safari/537.36" \
        --header "authority:seekingalpha.com" \
        --header "method:GET" \
        --header "path:$path" \
        --header "scheme:https" \
        --header "rand:$RANDOM" \
        --cookie-jar "./cookies_out.txt" \
        --output "$tmpDirName/$fileName" \
        "$url" 1> /dev/null 2>&1

    fileSize=`stat -c %s "$tmpDirName"/"$fileName"`
    if [ $? -ne 0 ] || [ "$fileSize" -ge "0" ] && [ "$fileSize" -le "$FILE_SIZE_THRESHOLD" ]; then
        echo "To small"
        (1>&2 echo $url)

        exitCode=1
        return 1
    fi
    
    f="$tmpDirName/$fileName"
    ./htmlCleaner.js < "$f" > "$cleanedDirName/$fileName"
    rm "$f"

    return 0
}

echo $$ > scrapeArticles.pid
mkdir -p $fullArticleTmpDir 1> /dev/null 2>&1

while read url; do
    makeRequest "$url"

    let "rdelay = ($RANDOM % ($MAX_REQUEST_DELAY_SECONDS - $MIN_REQUEST_DELAY_SECONDS)) + 1"
    echo "Delaying: $rdelay seconds"
    sleep $rdelay
done

rm scrapeArticles.pid

exit $exitCode



# urlFileName="/home/pi/Extended/seekingalpha/articles.clean.txt"
#    xargs curl --silent \
#        --user-agent "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/61.0.3163.100 Safari/537.36" \
#        --header "authority:seekingalpha.com" \
#        --header "method:GET" \
#        --header "path:/article/$i" \
#        --header "scheme:https" \
#        --remote-name \
#        {} < $urlFileName
