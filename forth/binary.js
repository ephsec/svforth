// To allow ourselves to work in node.js if we're not a browser.
//if (typeof XMLHttpRequest == 'undefined') {
//  var XMLHttpRequest = require("xmlhttprequest").XMLHttpRequest;
//}

var Word = function( name, fn ) {
  dictionary.register( name, fn );  
}

function Binary() {
  // RegExp to determine if the string we're looking at is base64 encoded
  var base64Matcher = new RegExp("^(?:[A-Za-z0-9+/]{4})*(?:[A-Za-z0-9+/]{2}" +
    "==|[A-Za-z0-9+/]{3}=|[A-Za-z0-9+/]{4})([=]{1,2})?$");

  // ***********************************************************************
  // JavaScript functions for Forth words
  // ***********************************************************************  

  // Fetch a binary via HTTP
  this.getBinary = function(callback) {
    var url = stack.pop();

    function responseIntoStack() {
      if (this.readyState == 4) {

        if ( typeof(binReq.response != "undefined") ) {
          arrayBuffer = binReq.response;
          stack.push( arrayBuffer );
        } else if ( typeof(binReq.responseText != "undefined" ) ) {
          // Sometimes the JavaScript environment we're in doesn't understand
          // how to work with ArrayBuffers, so we have to deal with it as a 
          // string object.
          arrayBuffer = binReq.responseText;
          stack.push( arrayBuffer );
        }
      }
      executeCallback(callback)
    }

    var binReq = new XMLHttpRequest()
    binReq.onload = responseIntoStack
    binReq.open("GET", url, true)
    binReq.responseType = "arraybuffer"
    binReq.send()
  }

  // RPC call to push our binary object to the server and do PE analysis on it
  this.getPEData = function(callback) {
    this.ensureBase64();
    var binary = stack.pop();
    stack.push( [ binary, "get-binary-peinfo" ] );
    stack.push( "@global" );
    forthparser.execute( [ "rpc" ], callback );
  }

  // ensure that we have a base64 string
  this.ensureBase64 = function(callback) {
    var toBeBase64 = stack.pop();

    if ( base64Matcher.test( toBeBase64 ) ) {
      // already base64, looks like, so ignore
      stack.push( toBeBase64 );
    } else {
      stack.push( window.btoa( toBeBase64 ) )
    }

    executeCallback( callback );
  }

  // ensure that we have a binary ArrayBuffer object
  this.ensureBinary = function(callback) {

    // the object to ensure is binary
    var toBeBinary = stack.pop()

    // we might have received a base64 encoded string, so we need to check
    // and convert to a base256 string if needed.
    if ( base64Matcher.test( toBeBinary ) ) {
      // looks like we've been passed a base64 string, so we convert it
      toBeBinary = window.atob( toBeBinary )
    }

    // takes a string and returns an UInt ArrayBuffer version
    function str2ab(str) {
      var buf = new ArrayBuffer(str.length); // 2 bytes for each char
      var bufView = new Uint8Array(buf);
      for (var i=0, strLen=str.length; i<strLen; i++) {
        bufView[i] = str.charCodeAt(i);
      }
      return buf;
    }

    // if we have a byteLength property, we're a binary object and can
    // just push it back onto the stack.
    if ( toBeBinary.hasOwnProperty('byteLength') ) {
      stack.push( toBeBinary );
    } else {
      // We have a string, so we need to convert it.
      stack.push( str2ab( toBeBinary ) );
    }

    executeCallback( callback );
  }

  // ***********************************************************************
  // Forth words for binary operations below
  // ***********************************************************************  

  // get-binary                                             ( url -- binary )
  //
  // given an URL, fetch it and add it to the stack as a binary object -- 
  // this only works in browsers if we are fetching from the server that we
  // ran forth.js from or in node.js
  Word("get-binary", this.getBinary)

  // ensure-base64                                       ( object -- base64 )
  //
  // given an object, whether a string or a binary array, we ensure that it's
  // encoded as a base64 string.
  Word("ensure-base64", this.ensureBase64)

  // ensure-binary                                       ( object -- binary )
  //
  // given an object, whether a base64 encoded string, a string, or a binary
  // array, we ensure that it's a TypedArray
  Word("ensure-binary", this.ensureBinary)

  // get-binary-peinfo [RPC]                             ( object -- peinfo )
  //
  // RPC call to the server to fetch PE information on the binary
  Word("get-binary-peinfo", this.getPEData)
}

if (typeof module != 'undefined' ) {
  module.exports.binary = Binary
} else {
  binary = Binary()
}
