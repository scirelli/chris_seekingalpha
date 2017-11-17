const URL = require('url').URL,
      fs = require('fs'),
      axios = require('axios'),
      DOMParser = require('xmldom').DOMParser;

const ARCHILVE_FILE = './archive.txt',
      FAILED_REQUESTS = './failedRequets.txt',
      TIME_OUT_MS = 10*1000;

let siteMapQ = [],
    archiveQ = [];

axios({
    method:'GET',
    url:'https://seekingalpha.com/robots.txt',
    responseType:'text',
    timeout: TIME_OUT_MS,
    headers: {
        authority: 'seekingalpha.com',
        path: 'https://seekingalpha.com/robots.txt',
        rand: Math.random()*1000
    }
})
    .then(response => {
        console.log('SiteMap: \n' + response.data);

        parseRobotsTxtForSitemaps(response.data).map(v => {
            siteMapQ.push(v);
        });

        console.log('Maps: ' + siteMapQ);

        return siteMapQ;
    })
    .then(siteMapQ => {
        drainSiteMapQ(siteMapQ);
    })
    .catch(error => {
        fs.writeFile(FAILED_REQUESTS, error.config.url + '\n', {flag: 'a'}, err => {
            if(err) console.log(err);
        });
        console.log(error);
    });


function parseRobotsTxtForSitemaps(str) {
    if(!str || typeof(str) !== 'string') return [];

    str = str.split('\n')
        .filter(line => {
            return line.toLowerCase().indexOf('sitemap') >= 0;
        }).map(line => {
            return line.split(/: *(?!\/\/)/);
        }).reduce((accum, v) => {
             accum.push(v[1]);
             return accum;
        }, []);

   return str;
}

function drainSiteMapQ(siteMapQ) {
    let url;

    while(url = siteMapQ.shift()){
        setTimeout((url) => {
            gatherArticlesFromSiteMap(url);
        }, 0, url);
    }
}

function gatherArticlesFromSiteMap(siteMapUrl) {
    axios({
        method:'GET',
        url:siteMapUrl,
        responseType:'document',
        timeout: TIME_OUT_MS,
        headers: {
            authority: 'seekingalpha.com',
            path: siteMapUrl,
            rand: Math.random()*1000
        }
    })
    .then(response => {
        var doc = new DOMParser().parseFromString(response.data),
            aLocNodes = doc.documentElement.getElementsByTagName('loc');

        Array.prototype.forEach.call(aLocNodes, node => {
            let url = node.textContent.trim();

            try{ 
                new URL(url);

                if( url.match(/\.xml$/) ){
                    siteMapQ.push(url);
                }else {
                    archiveQ.push(url);
                }
            }catch(e) {
                console.log(e);
            }
        });

        drainArchiveQ(archiveQ);
        drainSiteMapQ(siteMapQ);
    })
    .catch(error => {
        fs.writeFile(FAILED_REQUESTS, error.config.url + '\n', {flag: 'a'}, err => {
            if(err) console.log(err);
        });
        console.log(error);
    });
}

function drainArchiveQ(archiveQ) {
    let urls = archiveQ.join('\n');

    if(urls.length > 0){
        fs.writeFile(ARCHILVE_FILE, urls, {flag: 'a'}, err => {
            if(err) console.log(err);
        });
        archiveQ.splice(0);
    }
}
