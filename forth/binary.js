// TODO: make this work in node.js

// RegExp to determine if the string we're looking at is base64 encoded
var base64Matcher = new RegExp("^(?:[A-Za-z0-9+/]{4})*(?:[A-Za-z0-9+/]{2}" +
  "==|[A-Za-z0-9+/]{3}=|[A-Za-z0-9+/]{4})([=]{1,2})?$");

BinaryFns = {
  "get-binary": function(context) {
    var url = context.stack.pop();

    function responseIntoStack() {
      if (this.readyState == 4) {
        if ( typeof(binReq.response !== "undefined") ) {
          arrayBuffer = binReq.response;
          context.stack.push( arrayBuffer );
        } else if ( typeof(binReq.responseText !== "undefined" ) ) {
          // Sometimes the JavaScript environment we're in doesn't understand
          // how to work with ArrayBuffers, so we have to deal with it as a 
          // string object.
          arrayBuffer = binReq.responseText;
          context.stack.push( arrayBuffer );
        }
      }
      context.executeCallback( context );
    }

    var binReq = new XMLHttpRequest();
    binReq.onload = responseIntoStack;
    binReq.open("GET", url, true);
    binReq.responseType = "arraybuffer";
    binReq.send();
  },

  "get-binary-peinfo": function(context) {
    this.ensureBase64();
    var binary = context.stack.pop();
    context.stack.push( [ binary, "get-binary-peinfo" ] );
    context.execute( [ "rpc" ] );
  },

  "ensure-base64": function(context) {
    var toBeBase64 = context.stack.pop();

    // Below functions are from https://developer.mozilla.org/en-US/docs/Web/JavaScript/Base64_encoding_and_decoding#Solution_.232_.E2.80.93_rewriting_atob()_and_btoa()_using_TypedArrays_and_UTF-8
    // We are forced to do this, as Safari's window.btoa uses the string
    // representation of the ByteArray object i.e. [object ByteArray] rather
    // than the actual contents themselves.
    function uint6ToB64 (nUint6) {
      return nUint6 < 26 ?
          nUint6 + 65
        : nUint6 < 52 ?
          nUint6 + 71
        : nUint6 < 62 ?
          nUint6 - 4
        : nUint6 === 62 ?
          43
        : nUint6 === 63 ?
          47
        :
          65;

    }

    function ab2base64(ba) {
      aBytes = new Uint8Array( ba );

      var nMod3, sB64Enc = "";

      for (var nLen=aBytes.length, nUint24 =0, nIdx=0; nIdx < nLen; nIdx++) {
        nMod3 = nIdx % 3;
        //if (nIdx > 0 && (nIdx * 4 / 3) % 76 === 0) { sB64Enc += "\r\n"; }
        nUint24 |= aBytes[nIdx] << (16 >>> nMod3 & 24);
        if (nMod3 === 2 || aBytes.length - nIdx === 1) {
          sB64Enc += String.fromCharCode(
            uint6ToB64(nUint24 >>> 18 & 63), 
            uint6ToB64(nUint24 >>> 12 & 63),
            uint6ToB64(nUint24 >>> 6 & 63),
            uint6ToB64(nUint24 & 63));
          nUint24 = 0;
        }
      }

      return( sB64Enc.replace(/A(?=A$|$)/g, "=") );
    }

    console.log( toBeBase64 );

    if ( base64Matcher.test( toBeBase64 ) ) {
      // already base64, looks like, so ignore
      context.stack.push( toBeBase64 );
    } else {
      // TODO: needs a node.js equivalent
      if ( toBeBase64.hasOwnProperty('byteLength') ) {
        context.stack.push( ab2base64( toBeBase64 ) );
      } else {
        context.stack.push( window.btoa( toConvert ) );
      }
    }
    context.executeCallback( context );
  },

  "ensure-binary": function(context) {
    // the object to ensure is binary
    var toBeBinary = context.stack.pop()

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
      context.stack.push( toBeBinary );
    } else {
      // We have a string, so we need to convert it.
      context.stack.push( str2ab( toBeBinary ) );
    }

    context.executeCallback( context );
  }
}

if (typeof initialDictionary !== 'undefined') {
  initialDictionary.registerWords( BinaryFns );
}
