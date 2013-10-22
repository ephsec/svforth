process.stdin.resume();
process.stdin.setEncoding('utf8');

var forth = require( '../forth.js' );

ExecutionContext = forth.ExecutionContext;
Context = forth.Context;
Dictionary = forth.Dictionary;
initialDictionary = forth.initialDictionary;

context = new Context(initialDictionary);

console.log( context.dictionary );


function parseInput(data) {
    execution = new ExecutionContext( context );
    execution.execute(data);
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
