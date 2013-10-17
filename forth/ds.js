if ( typeof DOMParser === undefined ) {
  var DOMParser = require('xmldom').DOMParser;
}

// Given an XML DOM object, we convert it to a JavaScript data structure
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

  return( data );
}

function DataStructure() {
  // ***********************************************************************
  // JavaScript functions for Forth words
  // *********************************************************************** 

  // convert a string containing XML into JavaScript data structure
  this.xml2ds = function( callback ) {
    xml = new DOMParser().parseFromString( stack.pop() );
    ds = xml2js( xml.documentElement );
    stack.push( ds );
    executeCallback( callback );
  }

  // find how many elements are in our data structure
  this.dsLength = function( callback ) {
    item = stack.pop()
    stack.push( item.length )
    executeCallback( callback );
  }

  // get a subelement of our data structure
  this.dsGet = function( callback ) {
    index = stack.pop()
    item = stack.pop()
    stack.push( item[ index ] )
    executeCallback( callback );
  }

  // iteratively go through subelement of an element, fetching the value
  // contained in the key
  this.dsGetAll = function( callback ) {
    index = stack.pop();
    item = stack.pop();
    for (var i in item) {
      try {
        stack.push( item[i][index] );
      }
      catch(e) {
        // If we don't find the index, we just skip this error.
      }
    }
  }

  // ***********************************************************************
  // Forth words for data structure operations below
  // ***********************************************************************

  // xml-to-ds                                       ( xml-string -- js-ds )
  //
  // Given an XML string, convert it and push onto the stack a JavaScript
  // data structure representation.
  Word( "xml-to-ds", this.xml2ds );

  // ds-length                                           ( js-ds -- length )
  //
  // Given an DS, get the length of the element, whether it's an array, or
  // a string and push it onto the stack.
  Word( "ds-length", this.dsLength );

  // ds-get                                                ( js-ds -- item )
  //
  // Given a DS, get the item at index, and push it onto the stack.
  //
  // Examples:
  //    [ 'a' 'b' ] 1 ds-get --> 'b'
  //    { a: 0, b: 1 } a ds-get --> 0
  //
  Word( "ds-get", this.dsGet );

  // ds-get-all                                 ( js-ds -- item0 item1 ... )
  //
  // Given a DS, iterate through the DS and fetch the element contained
  // at each item.
  //
  // Examples:
  //    [ { a: 0, b: 1 } { a: 1, b: 2 } { a: 'x', b: 3 } ] 'a' ds-get-all -->
  //        0 1 'x'
  //
  Word( "ds-get-all", this.dsGetAll );

}

if (typeof module != 'undefined' ) {
  module.exports.ds = DataStructure;
} else {
  ds = DataStructure();
}