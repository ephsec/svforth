process.stdin.resume();
process.stdin.setEncoding('utf8');

var forth = require( '../forth.js' );
var dsmodule = require('./ds.js');
var rssmodule = require('./rss.js');
var urlmodule = require('./url.js');
var binarymodule = require('./binary.js');

forthparser = forth.forthparser
tokenize = forth.tokenize
stack = forth.stack
dictionary = forth.dictionary
arithmetic = forth.arithmetic
search = forth.search
display = forth.display

ds = dsmodule.ds;
binary = binarymodule.binary;

var Word = function( name, fn ) {
  dictionary.register( name, fn );  
}

function executeCallback(callback)
{
  if( typeof callback != 'undefined' ) {
    callback();
  }
}

function parseInput(data) {
    forthparser.execute(data);
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
