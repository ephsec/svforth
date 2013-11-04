function Canvas() {
  this.currCanvas = undefined
  this.currContext = undefined

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
    // console.log( canv.width, canv.height, plane.byteLength );
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
  this.canvas = function(context) {
    this.currCanvas = document.getElementById( context.stack.pop() )
    this.currContext = currCanvas.getContext("2d")
    context.executeCallback( context )
  }

  // Set our fill color for shapes
  this.fillStyle = function(context) {
    b = context.stack.pop()
    g = context.stack.pop()
    r = context.stack.pop()
    this.currContext.fillStyle = "rgb(" + [r,g,b].join(",") + ")"
    // console.log( "COLOR SET TO:", r, g, b )
    context.executeCallback( context )
  }

  // Draw a rectangle
  this.fillRect = function(context) {
    y2 = context.stack.pop()
    x2 = context.stack.pop()
    y1 = context.stack.pop()
    x1 = context.stack.pop()
    this.currContext.fillRect(x1, y1, x2, y2);
    // console.log( "FILL RECT CALLED", this.currContext );
    context.executeCallback( context );
  }

  // Convert HSV float values into UInt RGB values
  this.HSVtoRGB = function(context) {
      v = context.stack.pop();
      s = context.stack.pop();
      h = context.stack.pop();

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

      context.stack.push( Math.floor( r*255 ) );
      context.stack.push( Math.floor( g*255 ) );
      context.stack.push( Math.floor( b*255 ) );

      context.executeCallback( context );
  }

  // given three Strings or TypedArray, we draw them onto the current canvas
  // as RGB values
  this.paintPlanes = function(context) {
    b = coerceByteArray( context.stack.pop() );
    g = coerceByteArray( context.stack.pop() );
    r = coerceByteArray( context.stack.pop() );

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

    this.currContext.putImageData(imageData, 0, 0);

    context.executeCallback(context);
  }

  // A wrapper function that takes a single object and duplicates it onto
  // the stack three times for callout to paint-rgb for a grayscale image.
  this.paintBinary = function(context) {
    input = context.stack.pop();

    // We push a *copy* of the input object, using slice() -- doing otherwise
    // yields some interesting side effects.
    context.stack.push(input.slice(0));
    context.stack.push(input.slice(0));
    context.stack.push(input.slice(0));

    // Directly call paint-rgb rather than injecting the object onto the 
    // Forth execution stack.
    this.paintPlanes( context );
  }

  // If our HTML document has a 'canvas' element, we select it on
  // initialization to make things easier on us.
  if ( document.getElementById( 'canvas' ) ) {
    currCanvas = document.getElementById( 'canvas' )
    currContext = currCanvas.getContext( "2d" )
  }
}

canvas = new Canvas();

CanvasFns = {
  "set-canvas": canvas.canvas,
  "set-fill-color": canvas.fillStyle,
  "draw-rect": canvas.fillRect,
  "paint-grayscale": canvas.paintBinary,
  "paint-rgb": canvas.paintPlanes,
  "hsv-to-rgb": canvas.HSVtoRGB,
  "red": "127 0 0",
  "green": "0 127 0",
  "blue": "0 0 127"
}

if (typeof initialDictionary !== 'undefined') {
  initialDictionary.registerWords( CanvasFns );
}