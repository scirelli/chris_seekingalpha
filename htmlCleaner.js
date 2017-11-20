#!/usr/bin/node
//var sanitizeHtml = require('sanitize-html');
 
var content = [];
process.stdin.resume();
process.stdin.on('data', function(buf) { content.push(buf); });
process.stdin.on('end', function() {
    console.log(Buffer.concat(content).toString());
});

//var dirty = 'some really tacky HTML';
//var clean = sanitizeHtml(dirty);
