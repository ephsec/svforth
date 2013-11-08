var http = require('http');
var jsonParse = require('../lib/json.js');
var forth = require('../forth.js');

function createPipeFunction(dest) {
  return( function(context) {
    dest.write( JSON.stringify( context.stack ) )
    dest.end()
  } );
};

ServerFns = { "start-server": function(context) {
  http.createServer(function (request, response) {
    response.writeHead(200, { 'Access-Control-Allow-Origin': '*'} )
    request.on('data', function(data) {
      console.log(jsonParse.jsonParse(data.toString()));

      newContext = forth.createContext( context );
      newExecutionContext = forth.applyExecutionContext.apply( newContext );

      pipeArtifacts = createPipeFunction( response );

      // Each RPC call starts with a new stack.
      newContext.stack = [];
      // We inject our callback into the token stream.
      newContext.tokens = [ pipeArtifacts ];

      newExecutionContext.execute( jsonParse.jsonParse( data.toString() ) );
      });
    if ( request.method === "GET" ) {
      if ( request.url === "/" ) {
        filePath = "index.html";
      } else {
        filePath = "./" + request.url;
      }
      content = fs.createReadStream( filePath );
      content.on( 'data', function (data) {
        response.write( data );
      });
      content.on( 'end', function () {
        response.end();
      });
    };
    console.log( request.url, request.method );
    } ).listen(8000, '127.0.0.1');
  console.log( "Server started." );
  context.executeCallback( context );
  }
}

if (typeof module != 'undefined' ) {
  module.exports.ServerFns = ServerFns; 
}