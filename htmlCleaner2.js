#!/usr/bin/env node
const sanitizeHtml = require('sanitize-html'),
      util = require('util'),
      path = require('path'),
      os = require('os'),
      fs = require('fs'),
      argsv = process.argv,
      fs_lstat = util.promisify(fs.lstat);
 
const helpText = `
    node htmlCleaner2.js <input file> <output dir> [starting file name]

    <input file> containing a list of files to process.
    <output filder> the directory where the processed files will be saved.
    [starting file name] a file name to start with from <input file>.
`;

let inputFile = argsv[2],
    outputDir = argsv[3],
    startingPoint = argsv[4];

if(startingPoint) {
    startingPoint = startingPoint.trim();
    console.log('Starting at: ' + startingPoint);
}

Promise.all([
    fs_lstat(inputFile).then((stat)=>{
        if(!stat.isFile()){
            return Promise.reject(new Error('Input file must be a file.'));
        }
        
        inputFile = path.normalize(inputFile);
        
        console.log('Input file: ' + inputFile);
        return true;
    }),

    fs_lstat(outputDir).then((stat)=>{
        if(!stat.isDirectory()){
            return Promise.reject(new Error('Output directory must be a directory'));
        }
        
        outputDir = path.normalize(outputDir);
        
        console.log('Output dir: ' + outputDir);
        return true;
    })
]).then(()=>{
    fs.readFile(inputFile, function(err, files) {
        if(err) {
            throw err;
        }
        
        files = files.toString().split(os.EOL).filter(line => {return line.length !== 0;});
        
        console.log('Input file split');

        if(startingPoint) {
            let startingIndex = 0;

            startingIndex = files.findIndex((elem)=>{
                return elem.indexOf(startingPoint) !== -1
            });

            startingIndex = startingIndex === -1? 0 : startingIndex;
            files = files.slice(startingIndex);
            
            console.log('Starting at line number \'' + startingIndex + '\'');
        }

        for(let i=0,l=files.length,file; i<l; i++){
            file = files[i];
            let stats = fs.lstatSync(file);

            if(stats.isFile()) {
                let data = fs.readFileSync(file),
                    clean = sanitizeHtml(data.toString()),
                    fileName = path.basename(file),
                    outputFileName = path.join(outputDir, fileName);

                console.log(file);
                fs.writeFileSync(outputFileName, clean);
                console.log(outputFileName);
            }
        }
    });
});
