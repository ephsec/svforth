URLFns = {
  "get-url": function( context ) {
    function responseIntoStack() {
      if (this.readyState == 4) {
          context.stack.push( req.responseText );
      }
      context.executeCallback( context );
    }

    url = context.stack.pop();

    var req = new XMLHttpRequest();
    req.onload = responseIntoStack;
    req.open( "GET", url, true );
    req.send();
  },

  // get-http                                      ( url get-http -- object )
  //
  // This is where things get interesting -- we pick what function the Forth
  // word 'get-url' is associated with depending on if we're a browser
  // environment or a node.js environment.
  // we have to do this remotely as Cross-Browser Origin Reference policies
  // do not let us fetch URLs ourselves.
  "get-http": function( context ) {
    url = context.stack.pop();

    // context.execute( [ "[", url, "get-http", "]", "#" ] );

    context.tokens = [ [ url, "get-http" ], "#" ].concat( context.tokens );
    context.executeCallback( context );

    //newContext = applyExecutionContext.apply( createContext( context ) );
    //newContext.execute( , context );
  }
}

// If we're node.js, we redefine our 'get-http' call to one that works with
// our environment which does not have XMLHttpRequest by default.
if ( typeof window === 'undefined' ) {
  var http = require('http');
  URLFns[ 'get-http' ] = function( context ) {
    url = context.stack.pop()
    var req = http.request(url, function(res) {
      var respBuffer = "";
      res.setEncoding('utf8');
      res.on('end', function() {
        context.stack.push( respBuffer );
        context.executeCallback( context );
      });
      res.on('data', function(data) {
        console.log( data );
        respBuffer += data;
      });
    });
    req.end();
  }
};

if (typeof initialDictionary !== 'undefined') {
  initialDictionary.registerWords( URLFns );
}

if (typeof module != 'undefined' ) {
  module.exports.URLFns = URLFns; 
}