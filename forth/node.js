process.stdin.resume();
process.stdin.setEncoding('utf8');

var forth = require( '../forth.js' );

initialContext = forth.createContext( { dictionary: forth.initialDictionary } );
executionContext = forth.createExecutionContext.apply( initialContext );

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
