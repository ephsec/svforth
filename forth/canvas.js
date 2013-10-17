function Canvas() {
  var currCanvas = undefined
  var currContext = undefined

  // ************************************************************************
  // Internal helper functions for our canvas routines
  // ************************************************************************

  // given an object, we ensure that it is a TypedArray and do the neccessary
  // conversions
  // TODO: Implement detection and coercion of an Array of Integers
  var coerceByteArray = function(obj) {
    // converts string to a TypedArray, assuming that the values are 8-bit
    // which is actually a dangerous assumption as JavaScript has UTF-16
    // strings
    function str2ab(str) {
      var buf = new ArrayBuffer( str.length ); // 1 byte for each char
      var bufView = new Uint8Array( buf );
      for ( var i=0, strLen=str.length; i<strLen; i++ ) {
        bufView[i] = str.charCodeAt(i);
      }
      return( buf );
    }

    // TypedArrays typically have byteLength properties
    if ( obj.hasOwnProperty( 'byteLength' ) ) {
      // we're a Typed Array, so go ahead and use that
      return( obj );
    } else {
      // probably a string, so we convert it from a string into a TypedArray.
      return( str2ab( obj ) );
    }
  }

  // given the TypedArray and the canvas, we determine the maximum
  // length that we are painting -- if the canvas is larger, the maximum
  // length is the TypedArray, and if the TypedArray is larger, the canvas
  // is the maximum length.
  var getMaxLength = function(canv, plane) {
    console.log( canv.width, canv.height, plane.byteLength );
    // We only draw up to the length of the binary, or the total
    // size of the canvas.
    if ( plane.byteLength > ( canv.width * canv.height ) ) {
      limit=canv.width * canv.height;
    } else {
      limit=plane.byteLength;
    }
    return( limit )
  }

  // ***********************************************************************
  // JavaScript functions for Forth words
  // ***********************************************************************  

  // select our HTML canvas to draw on
  this.canvas = function(callback) {
    currCanvas = document.getElementById( stack.pop() )
    currContext = currCanvas.getContext("2d")
    executeCallback(callback)
  }

  // Set our fill color for shapes
  this.fillStyle = function(callback) {
    b = stack.pop()
    g = stack.pop()
    r = stack.pop()
    currContext.fillStyle = "rgb(" + [r,g,b].join(",") + ")"
    executeCallback(callback)
  }

  // Draw a rectangle
  this.fillRect = function(callback) {
    y2 = stack.pop()
    x2 = stack.pop()
    y1 = stack.pop()
    x1 = stack.pop()
    currContext.fillRect(x1, y1, x2, y2)
    executeCallback(callback)
  }

  // Convert HSV float values into UInt RGB values
  this.HSVtoRGB = function(callback) {
      v = stack.pop();
      s = stack.pop();
      h = stack.pop();

      console.log(h, s, v);

      var r, g, b, i, f, p, q, t;

      i = Math.floor(h * 6);
      f = h * 6 - i;
      p = v * (1 - s);
      q = v * (1 - f * s);
      t = v * (1 - (1 - f) * s);

      switch (i % 6) {
          case 0: r = v, g = t, b = p; break;
          case 1: r = q, g = v, b = p; break;
          case 2: r = p, g = v, b = t; break;
          case 3: r = p, g = q, b = v; break;
          case 4: r = t, g = p, b = v; break;
          case 5: r = v, g = p, b = q; break;
      }

      stack.push( Math.floor( r*255 ) );
      stack.push( Math.floor( g*255 ) );
      stack.push( Math.floor( b*255 ) );

      executeCallback( callback );
  }

  // given three Strings or TypedArray, we draw them onto the current canvas
  // as RGB values
  this.paintPlanes = function(callback) {
    b = coerceByteArray( stack.pop() );
    g = coerceByteArray( stack.pop() );
    r = coerceByteArray( stack.pop() );

    width = currCanvas.width;
    height = currCanvas.height;

    redUintArray = new Uint8Array( r );
    greenUintArray = new Uint8Array( g );
    blueUintArray = new Uint8Array( b );

    limit = getMaxLength( currCanvas, redUintArray );

    var imageData = currContext.getImageData( 0, 0, width, height );
    var data = imageData.data;

    // Note that we are treating the array as a 1D plane rather than
    // calculating the 1D location based on X and Y coordinates for speed.
    for (index=0, binIndex=0; index<=(limit * 4); index++) {
        data[index] = redUintArray[ binIndex ];     // red
        data[++index] = greenUintArray[ binIndex ]; // green
        data[++index] = blueUintArray[ binIndex ];  // blue
        data[++index] = 255;                        // alpha
        binIndex++;
    }

    currContext.putImageData(imageData, 0, 0);

    executeCallback(callback)

  }

  // A wrapper function that takes a single object and duplicates it onto
  // the stack three times for callout to paint-rgb for a grayscale image.
  this.paintBinary = function(callback) {
    input = stack.pop();

    // We push a *copy* of the input object, using slice() -- doing otherwise
    // yields some interesting side effects.
    stack.push(input.slice(0));
    stack.push(input.slice(0));
    stack.push(input.slice(0));

    // Directly call paint-rgb rather than injecting the object onto the 
    // Forth execution stack.
    this.paintPlanes( callback );
  }

  // ***********************************************************************
  // Forth words for canvas operations below
  // ***********************************************************************  

  // paint-canvas                                              ( canvas -- )
  //
  // given canvas, pick the current HTML canvas
  Word("set-canvas", this.canvas)

  // fillcolor                                         ( red green blue -- )
  //
  // given red green and blue as UInt values, select a color
  Word("set-fill-color", this.fillStyle)

  // draw-rect                                            ( x1 y1 x2 y2 -- )
  //
  // given two sets of coordinates, draw a rectangle with the current color
  Word("draw-rect", this.fillRect)

  // paint-grayscale                                           ( object -- )
  //
  // given a Static Array or String, paint values as grayscale onto canvas
  Word("paint-grayscale", this.paintBinary)

  // paint-rgb                                   ( object object object -- )
  //
  // given three Static Array or Strings on the stack, paint values as RGB
  Word("paint-rgb", this.paintPlanes)

  // hsv-to-rgb                   ( hue saturation value -- red green blue )
  //
  // given hue, saturation, and value, produce red, green, and blue UInt
  Word("hsv-to-rgb", this.HSVtoRGB)

  // If our HTML document has a 'canvas' element, we select it on
  // initialization to make things easier on us.
  if ( document.getElementById( 'canvas' ) ) {
    currCanvas = document.getElementById( 'canvas' )
    currContext = currCanvas.getContext( "2d" )
  }
}

// Helper definitions to make RGB colors easier
Word("red", "127 0 0")
Word("green", "0 127 0")
Word("blue", "0 0 127")



// infinitely cascade squares filled with progressive colors
Word("cascade", 
  "canvas set-canvas                  ( initial setup ) \
   blue set-fill-color                ( we like blue ) \
   0                                  ( we begin with 0 on the stack ) \
   begin \
    dup dup dup dup                   ( 4x dup for x1 y1 x2 y2 coords ) \
    100 + rot 100 +                   ( increment x2 and y2 by 100 for rect ) \
    draw-rect                         ( draw our rectangle ) \
    1 +                               ( our iterator value -- increment ) \
    dup dup dup set-fill-color        ( duplicated three times for color set ) \
   again")

// infinitely draw random rectangles on our canvas filled with random colors
Word("randrect",
  "canvas set-canvas                  ( initial setup ) \
   200 tokenresolution                ( allow browser update every 200 token ) \
   begin \
    0 255 rand 0 255 rand 0 255 rand  ( pick a random RGB value ) \
    set-fill-color                    ( set our color to the RGB value above ) \
    0 800 rand 0 600 rand             ( pick a corner of our rectangle ) \
    0 800 rand 0 600 rand             ( pick another corner of our rectangle ) \
    draw-rect                         ( actually draw our rectangle ) \
   again")

canvas = Canvas()