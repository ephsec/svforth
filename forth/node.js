process.stdin.resume();
process.stdin.setEncoding('utf8');

var forth = require( '../forth.js' );
var ds = require( './ds.js' );
var url = require( './url.js' );
var rss = require( './rss.js' );

forth.initialDictionary.registerWords( ds.DataStructureFns );
forth.initialDictionary.registerWords( url.URLFns );
forth.initialDictionary.registerWords( rss.RSSFns );

console.log( forth.initialDictionary.definitions );

initialContext = forth.createContext( { dictionary: forth.initialDictionary } );
executionContext = forth.applyExecutionContext.apply( initialContext );


function parseInput(data) {
    executionContext.execute(data);
    process.stdout.write(">> ");
}

function prompt(callback) {
    process.stdout.write(">> ");
    process.stdin.on('data', function(data) {
        data = data.toString().trim();
        callback(data);
    });
}

prompt(parseInput);
