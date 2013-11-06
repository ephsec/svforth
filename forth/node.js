process.stdin.resume();
process.stdin.setEncoding('utf8');

var forth = require( '../forth.js' );
var ds = require( './ds.js' );
var url = require( './url.js' );
var database = require( './database.js' );
var server = require( './server.js' );

forth.initialDictionary.registerWords( ds.DataStructureFns );
forth.initialDictionary.registerWords( url.URLFns );
forth.initialDictionary.registerWords( database.DatabaseFns );
forth.initialDictionary.registerWords( server.ServerFns );

console.log( forth.initialDictionary.definitions );

initialContext = forth.createContext( { dictionary: forth.initialDictionary } );
executionContext = forth.applyExecutionContext.apply( initialContext );
executionContext.load( 'forth/rss.f' );
executionContext.load( 'site.f' );

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
