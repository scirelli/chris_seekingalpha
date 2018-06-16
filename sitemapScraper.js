const URL = require('url').URL,
      fs = require('fs'),
      axios = require('axios'),
      DOMParser = require('xmldom').DOMParser;

const ARCHILVE_FILE = './archive.txt',
      FAILED_REQUESTS = './failedRequets.txt',
      TIME_OUT_MS = 10*1000,
      MIN_SITEMAP_QUERY_TIME_MS = 1000,
      MAX_SITEMAP_QUERY_TIME_MS = 60 * 1000;

let siteMapQ = [],
    archiveQ = [];

switch(process.argv[2]){
    case '1':
    case 'failed':
        let failedList = process.argv[3] || './sitemapQ.txt';
        fillSitemapQFromFailedFile(failedList).then(siteMapQ => {
            drainSiteMapQ(siteMapQ);
        });
        break;
    default:
        fillSitemapQFromRobots_txt().then(siteMapQ => {
            drainSiteMapQ(siteMapQ);
        });
}

function fillSitemapQFromRobots_txt(url){
    url = url || 'https://seekingalpha.com/robots.txt';

    return axios({
        method:'GET',
        url:url,
        responseType:'text',
        timeout: TIME_OUT_MS,
        headers: {
            authority: 'seekingalpha.com',
            path: 'https://seekingalpha.com/robots.txt',
            'user-agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/61.0.3163.100 Safari/537.36',
            rand: Math.random()*1000
        }
    })
        .then(response => {
            parseRobotsTxtForSitemaps(response.data).map(v => {
                siteMapQ.push(v);
            });

            console.log('Sitemaps:\n\t' + siteMapQ.join('\n\t'));

            return siteMapQ;
        })
        .catch(error => {
            fs.writeFile(FAILED_REQUESTS, error.config.url + '\n', {flag: 'a'}, err => {
                if(err) console.log('Failed to write failed request url\n\t' + err);
            });
            console.log('Failed request:\n' + error);
        });
}

function fillSitemapQFromFailedFile(path) {
    path = path || FAILED_REQUESTS;
    return new Promise((resolve, reject) => { 
        fs.readFile(path, (err, data) => {
            if(err) {
                console.log(err);
                reject(err);
                return;
            }
            
            data.toString().split('\n').forEach(line => {
                siteMapQ.push(line.trim());
            });

            resolve(siteMapQ);
        });
    })
}

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
    let url,
        promises = [];

    while(url = siteMapQ.shift()){
        promises.push(new Promise((resolve, reject) => {
            setTimeout((url) => {
                resolve(gatherArticlesFromSiteMap(url));
            }, Math.randRange(MIN_SITEMAP_QUERY_TIME_MS, MAX_SITEMAP_QUERY_TIME_MS), url);
        }));
    }

    return Promise.all(promises);
}

function gatherArticlesFromSiteMap(siteMapUrl) {
    return axios({
        method:'GET',
        url:siteMapUrl,
        responseType:'document',
        timeout: TIME_OUT_MS,
        headers: {
            authority: 'seekingalpha.com',
            path: siteMapUrl,
            'user-agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/61.0.3163.100 Safari/537.36',
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
                console.log('Bad URL\n\t' + e);
            }
        });

        drainArchiveQ(archiveQ);
        return drainSiteMapQ(siteMapQ);
    })
    .catch(error => {
        fs.writeFile(FAILED_REQUESTS, error.config.url + '\n', {flag: 'a'}, err => {
            if(err) console.log('Fialed to write failed request url:\n\t' + err);
        });
        console.log('Failed request error:\n' + error);
    });
}

function drainArchiveQ(archiveQ) {
    let urls = archiveQ.join('\n');

    if(urls.length > 0){
        fs.writeFile(ARCHILVE_FILE, urls, {flag: 'a'}, err => {
            if(err) console.log('Failed to write archive file\n\t' + err);
        });
        archiveQ.splice(0);
    }
}

Math.randRange = function(min, max) {
    return ~~(Math.random() * ((max+1)-min) + min);
};
