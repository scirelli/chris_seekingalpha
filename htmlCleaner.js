#!/usr/bin/env node
const sanitizeHtml = require('sanitize-html');
 
let content = [];

process.stdin.resume();
process.stdin.on('data', function(buf) { content.push(buf); });
process.stdin.on('end', function() {
    let fileContent = Buffer.concat(content).toString(),
        clean = sanitizeHtml(fileContent);
        
    console.log(clean);
});

