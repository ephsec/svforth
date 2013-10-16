if (typeof XMLHttpRequest == 'undefined') {
  var XMLHttpRequest = require("xmlhttprequest").XMLHttpRequest;
}

var Word = function( name, fn ) {
  dictionary.register( name, fn );  
}

function Binary() {
  this.getBinary = function(callback) {

    var url = stack.pop();

    function responseIntoStack() {
      if (this.readyState == 4) {
        if ( typeof(binReq.response != "undefined") ) {
          arrayBuffer = binReq.response;
          stack.push( arrayBuffer );
        } else if ( typeof(binReq.responseText != "undefined" ) ) {
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

  this.getPEData = function(callback) {
    this.ensureBase64();
    var binary = stack.pop();
    stack.push( [ binary, "get-binary-peinfo" ] );
    stack.push( "@global" );
    forthparser.execute( [ "rpc" ], callback );
  }

  this.ensureBase64 = function(callback) {
    var toBeBase64 = stack.pop();
    var base64Matcher = new RegExp("^(?:[A-Za-z0-9+/]{4})*(?:[A-Za-z0-9+/]{2}==|[A-Za-z0-9+/]{3}=|[A-Za-z0-9+/]{4})([=]{1,2})?$");

    if ( base64Matcher.test( toBeBase64 ) ) {
      // already base64, looks like, so ignore
      stack.push( toBeBase64 );
    } else {
      stack.push( window.btoa( toBeBase64 ) )
    }

    executeCallback();

  }

  this.ensureBinary = function(callback) {

    // the object to ensure is binary
    var toBeBinary = stack.pop()

    // we might have received a base64 encoded string, so we need to check
    // and convert to a base256 string if needed.
    var base64Matcher = new RegExp("^(?:[A-Za-z0-9+/]{4})*(?:[A-Za-z0-9+/]{2}" +
      "==|[A-Za-z0-9+/]{3}=|[A-Za-z0-9+/]{4})([=]{1,2})?$");
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

  Word("get-binary", this.getBinary)
  Word("ensure-base64", this.ensureBase64)
  Word("ensure-binary", this.ensureBinary)
  Word("get-binary-peinfo", this.getPEData)
}

if (typeof module != 'undefined' ) {
  module.exports.binary = Binary
} else {
  binary = Binary()
}
