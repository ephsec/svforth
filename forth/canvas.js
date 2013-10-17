function Canvas() {
  var currCanvas = undefined
  var currContext = undefined

  this.canvas = function(callback) {
    currCanvas = document.getElementById( stack.pop() )
    currContext = currCanvas.getContext("2d")
    executeCallback(callback)
  }

  this.fillStyle = function(callback) {
    b = stack.pop()
    g = stack.pop()
    r = stack.pop()
    currContext.fillStyle = "rgb(" + [r,g,b].join(",") + ")"
    executeCallback(callback)
  }

  this.fillRect = function(callback) {
    y2 = stack.pop()
    x2 = stack.pop()
    y1 = stack.pop()
    x1 = stack.pop()
    currContext.fillRect(x1, y1, x2, y2)
    executeCallback(callback)
  }

  var coerceByteArray = function(obj) {
    // the below function and conditionals ensure that what we have
    // is a Typed Array for optimization reasons
    function str2ab(str) {
      var buf = new ArrayBuffer( str.length ); // 2 bytes for each char
      var bufView = new Uint8Array( buf );
      for ( var i=0, strLen=str.length; i<strLen; i++ ) {
        bufView[i] = str.charCodeAt(i);
      }
      return buf;
    }

    // we're a Typed Array, so go ahead and use that
    if ( obj.hasOwnProperty( 'byteLength' ) ) {
      bin = input;
    } else {
      // We have a string, so we need to convert it.
      bin = str2ab( obj );
    }

    return( bin );
  }

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

  this.HSVtoRGB = function(callback) {
      v = stack.pop();
      s = stack.pop();
      h = stack.pop();

      console.log(h, s, v);

      var r, g, b, i, f, p, q, t;
      if (h && s === undefined && v === undefined) {
          s = h.s, v = h.v, h = h.h;
      }
      i = Math.floor(h * 6);
      f = h * 6 - i;
      p = v * (1 - s);
      q = v * (1 - f * s);
      t = v * (1 - (1 - f) * s);

      console.log("LOGGY:", i,f,p,q,t);
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

    console.log( redUintArray, greenUintArray, blueUintArray );

    var binIndex = 0;
    for (var index=0; index<=(limit * 4); index++) {
        data[index] = redUintArray[ binIndex ];     // red
        data[++index] = greenUintArray[ binIndex ];   // green
        data[++index] = blueUintArray[ binIndex ];   // blue
        data[++index] = 255;     // alpha
        binIndex++;
    }

    currContext.putImageData(imageData, 0, 0);

    executeCallback(callback)

  }

  this.paintBinary = function(callback) {
    input = stack.pop();

    stack.push(input.slice(0));
    stack.push(input.slice(0));
    stack.push(input.slice(0));

    this.paintPlanes(callback);
  }

  Word("pickcanvas", this.canvas)
  Word("fillcolor", this.fillStyle)
  Word("rect", this.fillRect)
  Word("paint-binary", this.paintBinary)
  Word("paint-rgb", this.paintPlanes)
  Word("hsv-to-rgb", this.HSVtoRGB)

  if ( document.getElementById( 'canvas' ) ) {
    currCanvas = document.getElementById( 'canvas' )
    currContext = currCanvas.getContext( "2d" )
  }
}

Word("red", "200 0 0")
Word("green", "0 200 0")
Word("blue", "0 0 200")

Word("cascade", 
  "canvas pickcanvas blue fillcolor   ( initial setup ) \
   0                                  ( we begin with 0 on the stack ) \
   begin \
    dup dup dup dup                   ( we duplicate our value four times ) \
    100 + rot 100 +                   ( we increment last two values by 100 ) \
    rect                              ( we now have four values to draw with ) \
    1 +                               ( the remaining value is incremented ) \
    dup dup dup fillcolor             ( duplicated three times for color set ) \
   again                              ( the loop is started again )")

Word("randrect",
  "canvas pickcanvas                  ( initial setup ) \
   200 tokenresolution                ( allow browser update every 200 token ) \
   begin \
    0 255 rand 0 255 rand 0 255 rand  ( pick a random RGB value ) \
    fillcolor                         ( set our color to the RGB value above ) \
    0 800 rand 0 600 rand             ( pick a corner of our rectangle ) \
    0 800 rand 0 600 rand             ( pick another corner of our rectangle ) \
    rect                              ( actually draw our rectangle ) \
   again")

canvas = Canvas()