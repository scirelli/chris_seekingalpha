#!/usr/bin/env bash

htmlDocBegin=$(cat <<END
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
    <head>
    </head>
    <body>
        <ol>
END
)

htmlDocEnd=$(cat <<END
        </ol>
    </body>
</html>
END
)
anchors=""

#printf  "Content-type: text/html\n\n"

printf "$htmlDocBegin"

for f in `find /home/pi/Projects/Chris/chris_seekingalpha/html/ -type f`; do
    url="/articlesHtml/"`echo "$f" | sed 's/\/home\/pi\/Projects\/Chris\/chris_seekingalpha\/html\///'`
    text=`echo $url | sed 's/\/articlesHtml\/[a-f]*[0-9]*\///'`
    printf "<li><a target=\"_blank\" href=\"$url\">$text</a></li>"
done

printf "$htmlDocEnd"
