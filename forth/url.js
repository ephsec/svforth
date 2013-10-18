if ( typeof XMLHttpRequest === undefined ) {
  var XMLHttpRequest = require("xmlhttprequest").XMLHttpRequest;
}

function URL() {
  this.localGetURL = function( callback ) {
    function responseIntoStack() {
      if (this.readyState == 4) {
          stack.push( req.responseText );
      }
      executeCallback(callback)
    }

    url = stack.pop()

    console.log( url )

    var req = new XMLHttpRequest()
    req.onload = responseIntoStack
    req.open("GET", url, true)
    req.send()
  }

  // we have to do this remotely as Cross-Browser Origin Reference policies
  // do not let us fetch URLs ourselves.
  this.rpcGetUrl = function( callback ) {
    url = stack.pop()

    rpcExecute = new Execution();
    rpcExecute.execute( [ "[", url, "get-http", "]",
                          "@global", "rpc" ], callback );
  }

  // get-http                                      ( url get-http -- object )
  //
  // This is where things get interesting -- we pick what function the Forth
  // word 'get-url' is associated with depending on if we're a browser
  // environment or a node.js environment.
  if ( typeof window === 'undefined' ) {
    Word( "get-http", this.localGetUrl )
  } else {
    Word( "get-http", this.rpcGetUrl )
  }

}

if (typeof module != 'undefined' ) {
  module.exports.url = URL;
} else {
  url = URL();
}