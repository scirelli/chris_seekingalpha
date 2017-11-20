start=0

all:
	tail -n+$(start) uniqueArticles.txt | ./scrapeArticles.sh 2> ./failedUrls.txt

clean:
	rm /home/pi/Extended/seekingalpha/html/*
	rm /home/pi/Extended/seekingalpha/headers/*
	rm /home/pi/Projects/Chris/chris_seekingalpha/failedUrls.txt

counts:
	echo "htlm files:" `ls /home/pi/Extended/seekingalpha/html | wc -l`
	echo "header files:" `ls /home/pi/Extended/seekingalpha/headers | wc -l`