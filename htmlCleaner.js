var sanitizeHtml = require('sanitize-html');
 
var dirty = 'some really tacky HTML';
var clean = sanitizeHtml(dirty);
