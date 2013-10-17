var Word = function( name, fn ) {
  dictionary.register( name, fn );  
}

// TODO: Rewrite into a '.forth' file once we support loading source files
//       into our Forth environment.

function RSS() {
  // get-rss                                                 ( url -- RSS-DS )
  // 
  // given a RSS feed URL, we fetch the RSS XML into the stack and convert
  // into a Javascript DataStructure
  Word( "get-rss",
    "get-url          ( fetch our RSS XML feed into the stack ) \
     xml-to-ds        ( convert our RSS into JS DS ) " );

  // get-rss-links                                   ( url -- link1 link2 .. )
  //
  // given a RSS feed URL, we fetch and parse the links within onto the stack
  Word( "get-rss-links",
    "get-rss          ( get our RSS feed as a JS DS ) \
     channel ds-get   ( extract the 'channel' subelement ) \
     item ds-get      ( extract the 'item' subelement ) \
     link ds-get-all  ( extract all 'link' subelements ) " );
}

if (typeof module != 'undefined' ) {
  module.exports.rss = RSS;
} else {
  rss = RSS();
}