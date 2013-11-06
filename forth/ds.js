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

DataStructureFns = {
  // xml-to-ds                                       ( xml-string -- js-ds )
  //
  // Given an XML string, convert it and push onto the stack a JavaScript
  // data structure representation.
  "xml-to-ds": function( context ) {
    xml = new DOMParser().parseFromString( context.stack.pop(), 'text/xml' );
    ds = xml2js( xml.documentElement );
    context.stack.push( ds );
    context.executeCallback( context );
  },

  // ds-length                                           ( js-ds -- length )
  //
  // Given an DS, get the length of the element, whether it's an array, or
  // a string and push it onto the stack.
  "ds-length": function( context ) {
    item = context.stack.pop()
    context.stack.push( item.length )
    context.executeCallback( context );
  },

  // ds-get                                                ( js-ds -- item )
  //
  // Given a DS, get the item at index, and push it onto the stack.
  //
  // Examples:
  //    [ 'a' 'b' ] 1 ds-get --> 'b'
  //    { a: 0, b: 1 } a ds-get --> 0
  //
  "ds-get": function( context ) {
    index = context.stack.pop()
    item = context.stack.pop()
    context.stack.push( item[ index ] )
    context.executeCallback( context );
  },

  // ds-get-all                                 ( js-ds -- item0 item1 ... )
  //
  // Given a DS, iterate through the DS and fetch the element contained
  // at each item.
  //
  // Examples:
  //    [ { a: 0, b: 1 } { a: 1, b: 2 } { a: 'x', b: 3 } ] 'a' ds-get-all -->
  //        0 1 'x'
  //
  "ds-get-all": function( context ) {
    index = context.stack.pop();
    item = context.stack.pop();
    for (var i in item) {
      try {
        context.stack.push( item[i][index] );
      }
      catch(e) {
        // If we don't find the index, we just skip this error.
      }
    }
    context.executeCallback( context );
  },

  // push-array                                   ( array item -- array )
  //
  // Given a DS, push the item off the stack onto the array
  "push-array": function( context ) {
    item = context.stack.pop();
    arr = context.stack.pop();
    arr.push( item );
    context.stack.push( arr );
    context.executeCallback( context );
  }
}

if (typeof initialDictionary !== 'undefined') {
  initialDictionary.registerWords( DataStructureFns );
}

if (typeof module != 'undefined' ) {
  module.exports.DataStructureFns = DataStructureFns; 
}