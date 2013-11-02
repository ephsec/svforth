// TODO: Rewrite into a '.forth' file once we support loading source files
//       into our Forth environment.

RSSFns = {
  // get-rss                                                 ( url -- RSS-DS )
  // 
  // given a RSS feed URL, we fetch the RSS XML into the stack and convert
  // into a Javascript DataStructure
  "get-rss":
    "get-http         ( fetch our RSS XML feed into the stack ) \
     xml-to-ds        ( convert our RSS into JS DS ) ",

  // get-rss-links                                   ( url -- link1 link2 .. )
  //
  // given a RSS feed URL, we fetch and parse the links within onto the stack
  "get-rss-links":
    "get-rss          ( get our RSS feed as a JS DS ) \
     channel ds-get   ( extract the 'channel' subelement ) \
     item ds-get      ( extract the 'item' subelement ) \
     link ds-get-all  ( extract all 'link' subelements ) ",
}

if (typeof initialDictionary !== 'undefined') {
  initialDictionary.registerWords( RSSFns );
}

if (typeof module != 'undefined' ) {
  module.exports.RSSFns = RSSFns; 
}