var XMLHttpRequest = require("xmlhttprequest").XMLHttpRequest;
var DOMParser = require('xmldom').DOMParser;

var Word = function( name, fn ) {
  dictionary.register( name, fn );  
}

function executeCallback(callback)
{
  if( typeof callback != 'undefined' ) {
    callback();
  }
}

function xml2js(node) {

  var data = {};

  // append a value
  function Add(name, value) {
    if (data[name]) {
      if (data[name].constructor != Array) {
        data[name] = [data[name]];
      }
      data[name][data[name].length] = value;
    }
    else {
      data[name] = value;
    }
  };
  
  // element attributes
  var c, cn;
  for (c = 0; cn = node.attributes[c]; c++) {
    Add(cn.name, cn.value);
  }
  
  // child elements
  for (c = 0; cn = node.childNodes[c]; c++) {
    if (cn.nodeType == 1) {
      if (cn.childNodes.length == 1 && cn.firstChild.nodeType == 3) {
        // text value
        Add(cn.nodeName, cn.firstChild.nodeValue);
      }
      else {
        // sub-object
        Add(cn.nodeName, xml2js(cn));
      }
    }
  }

  return data;

}

function RSS() {
  this.xml2ds = function( callback ) {
    xml = new DOMParser().parseFromString( stack.pop() )
    ds = xml2js( xml.documentElement )
    stack.push(ds)
    executeCallback(callback)
  }

  // we have to do this remotely as Cross-Browser Origin Reference policies
  // do not let us fetch URLs ourselves.
  // this.getURL = function( callback ) {
  //  url = stack.pop()
  //  forthparser.execute( [ "[", url, "get-url", "]", "rpc" ], callback )
  //}

  this.getURL = function( callback ) {
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

  this.dsLength = function( callback ) {
    item = stack.pop()
    stack.push( item.length )
    executeCallback(callback)
  }

  this.dsGet = function( callback ) {
    index = stack.pop()
    item = stack.pop()
    stack.push( item[ index ] )
    executeCallback(callback)
  }

  this.dsGetAll = function( callback ) {
    index = stack.pop()
    item = stack.pop()
    console.log( index )
    for (var i in item) {
      console.log( i )
      try {
          stack.push( item[i][index] )
      }
      catch(e) {
        //
      }
    }
  }

  this.getRSS = "get-url \
                 xml-to-ds \
                 channel ds-get \
                 item ds-get \
                 link ds-get-all"
  
  Word( "get-url", this.getURL )
  Word( "get-rss", this.getRSS )
  Word( "xml-to-ds", this.xml2ds )
  Word( "ds-length", this.dsLength )
  Word( "ds-get", this.dsGet )
  Word( "ds-get-all", this.dsGetAll )
}

if (typeof module != 'undefined' ) {
  module.exports.rss = RSS
}
