file=$1
sleepTime=$2

articleDirectory="/home/pi/Extended/seekingalpha/html/"
prvCount=0

if [ -z "$file" ]; then
    file="/home/pi/Extended/seekingalpha/articleCount.txt"
fi

if [ ! "$sleepTime" ]; then
    sleepTime=2
fi

while true; do
    count=`ls $articleDirectory | wc -l`

    if [ "$count" -ne "$prvCount" ]; then
        prvCount=$count
        echo $count | tee "$file"
    fi

    sleep 2
done
