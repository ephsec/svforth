( get-rss                                                        url -- ds
  given a RSS feed URL, we fetch and parse the XML dom into DS             )
: get-rss
  get-http         ( fetch our RSS XML feed into the stack )
  xml-to-ds        ( convert our RSS into JS DS )
  ;

( get-rss-links                                      url -- link1 link2 ..
  given a RSS feed URL, we fetch and parse the links within onto the stack )
: get-rss-links
  get-rss          ( get our RSS feed as a JS DS )
  channel ds-get   ( extract the 'channel' subelement )
  item ds-get      ( extract the 'item' subelement )
  link ds-get-all  ( extract all 'link' subelements )
  ;