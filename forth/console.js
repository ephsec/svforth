if ( typeof(Ractive) == 'undefined') {
    importJSLibrary('lib/Ractive.min.js');
}

function sanitizeForJSON(toJSON) {
  var i = 0;

  return function(key, value) {
    if( i !== 0 && typeof( toJSON ) === 'object' && typeof( value ) == 'object'
        && toJSON == value ) {
      return '[Circular]'; 
    }

    ++i;

    return( value );  
  }
}

function wrapBuffer(outString, buffer) {
	wrapArray = [];

	while ( outString.length > buffer.maxWidth ) {
		wrapArray.push( outString.slice(0, buffer.maxWidth) );
		outString = outString.slice(buffer.maxWidth);
	}
	wrapArray.push( outString );
	return( wrapArray );

}

// Handy JavaScript to meature the size taken to render the supplied text;
// you can supply additional style information too if you have it to hand.

function measureText(pText, pFontSize, pStyle) {
    var lDiv = document.createElement('lDiv');

    document.body.appendChild(lDiv);

    if (pStyle != null) {
        lDiv.style = pStyle;
    }
    lDiv.style.fontSize = "" + pFontSize + "px";
    lDiv.style.position = "absolute";
    lDiv.style.left = -1000;
    lDiv.style.top = -1000;

    lDiv.innerHTML = pText;

    var lResult = {
        width: lDiv.clientWidth,
        height: lDiv.clientHeight
    };

    document.body.removeChild(lDiv);
    lDiv = null;

    return lResult;
}

function ForthConsole() {
  // ***********************************************************************
  // JavaScript functions for Forth words
  // ***********************************************************************  

  	var that = this;

    function createForthHooks(screenBuffer, forthBuffer, terminalContainer) {
        var forthConsole = {};

        forthConsole.createOutputHandler = function() { return(
            function(item) {
                if( screenBuffer.maxLines == screenBuffer.length &&
                    ( screenBuffer.length > 1) ) {
                    screenBuffer.shift();
                }
                if (typeof item == "object") {
                    outputString = JSON.stringify( item, sanitizeForJSON(item) )
                } else {
                    outputString = item
                }

                wrappedLines = wrapBuffer( outputString, screenBuffer )
                for ( line in wrappedLines ) {
                    while ( screenBuffer.maxLines - 1 < screenBuffer.length ) {
                        screenBuffer.shift();
                    }
                    screenBuffer.push( wrappedLines[ line ] );
                    forthBuffer.push( wrappedLines[ line ] );
                }
            } ) } ;

        forthConsole.createPrintHandler = function() { return(
            function(context) {
                item = context.stack.pop();
                if( screenBuffer.maxLines == screenBuffer.length && ( screenBuffer.length > 1 ) ) {
                    screenBuffer.shift();
                }
                if (typeof item == "object") {
                    outputString = JSON.stringify( item, sanitizeForJSON(item) )
                } else {
                    outputString = item
                }

                wrappedLines = wrapBuffer( outputString, screenBuffer )
                for ( line in wrappedLines ) {
                    while ( screenBuffer.maxLines - 1 < screenBuffer.length && ( screenBuffer.length > 1 ) ) {
                        screenBuffer.shift();
                    }
                    screenBuffer.push( wrappedLines[ line ] );
                    forthBuffer.push( wrappedLines[ line ] );
                }
                context.executeCallback( context );
            } ) };

        forthConsole.createClearScreenHandler = function() { return(
            function(context) {
                while( consoleBuffer.length > 0 ) {
                    consoleBuffer.pop()
                }
                context.executeCallback( context );
            } ) };

        forthConsole.createPeekHandler = function() { return(
            function(context) {
                item = context.stack[context.stack.length-1]
                if (typeof screenBuffer != "undefined") {
                    if( screenBuffer.maxLines == screenBuffer.length ) {
                        screenBuffer.shift()
                    }
                    if (typeof item == "object") {
                        screenBuffer.push(JSON.stringify(item, censor(item)));
                    } else {
                        screenBuffer.push(item);
                    }
                } else {
                    console.log(item);
                }
                context.executeCallback( context );
            } ) };

        forthConsole.createTerminalResizer =
          function(forthBuffer, screenBuffer, terminalContainer) { return(
            function(context) {
                resizeTerminal(screenBuffer, terminalContainer);
                while ( screenBuffer.length != 0 ) {
                    screenBuffer.shift();
                }

                var beginForthBufferRange = ( forthBuffer.length -
                                              screenBuffer.maxLines - 1 );

                var lineNum = 0;
                for ( var lineIndex = beginForthBufferRange;
                           lineIndex < forthBuffer.length;
                           lineIndex++ ) {
                    if ( forthBuffer[ lineIndex ] != undefined ) {
                        screenBuffer.push( forthBuffer[ lineIndex ] );
                    }
                    lineNum += 1;
                }
                console.log( screenBuffer );
            })
        };

        return( forthConsole );
    }

    function registerInputHandler(inputId, screenBuffer, forthBuffer,
                                  commandHistory) {
        var handlerId = "Console" + inputId + "Handler"
        window[handlerId] = function() {
            forthInput = document.getElementById( "ConsoleInput" + inputId );

            // We create an execution handler based off our startup 
            // context, initialContext.
            newContext = createContext( initialContext );
            newExecutionContext = applyExecutionContext.apply( newContext );
            if ((screenBuffer.maxLines - 1 ) < screenBuffer.length) {
                screenBuffer.shift()
            }
            screenBuffer.push( '$ ' + forthInput.value );
            forthBuffer.push( '$ ' + forthInput.value );
            commandHistory.push( forthInput.value );
            newExecutionContext.execute( forthInput.value );
            forthInput.value = "";
        }
        return( handlerId );
    }

    function resizeTerminal(screenBuffer, terminalContainer) {
        domObject = document.getElementById( terminalContainer );
        fontSize = domObject.style.pFontSize;
        fontFamily = domObject.style.fontFamily;

        fontMeasurements = measureText( "x", fontSize, {
            'font-family': fontFamily } );
        fontWidth = fontMeasurements.width;
        fontHeight = fontMeasurements.height;

        screenBuffer.maxCols = Math.floor( 
            domObject.clientWidth / ( fontWidth ) ) - 1
        screenBuffer.maxLines = Math.floor( 
            domObject.clientHeight / ( fontHeight ) ) - 2

        console.log( "Terminal initialized with size:",
            screenBuffer.maxCols, screenBuffer.maxLines );
    }

    function registerTerminalContext(context, screenBuffer, forthBuffer,
                                     terminalContainer ) {
        forthConsole = createForthHooks( screenBuffer, forthBuffer,
                                         terminalContainer );
        context.dictionary.registerWords( {
            "print": forthConsole.createPrintHandler(),
            ".": forthConsole.createPeekHandler(),
            "clearscreen": forthConsole.createClearScreenHandler(),
            "resize-terminal": forthConsole.createTerminalResizer(forthBuffer,
                screenBuffer, terminalContainer ) } );
        context.console = { 'output': forthConsole.createOutputHandler() };
    }

    this.createTerminal = function(context) {
        var terminalContainer = context.stack.pop();
        var screenBuffer = context.stack.pop();
        var forthBuffer = [];

        var terminalId = Math.floor((Math.random() * 65536));

        var commandHistory = [];

        // Register output Forth words in our context to the screenBuffer
        // in question.
        registerTerminalContext( context, screenBuffer, forthBuffer,
                                 terminalContainer );
        handlerId = registerInputHandler( terminalId, screenBuffer, forthBuffer,
                                          commandHistory );

        var ractiveParams = {};
        var ractiveData = {};
        ractiveParams[ 'el' ] = terminalContainer;
        ractiveParams[ 'template' ] =
            [ "<table border='0' cellspacing='2' cellpadding='2' ",
              "style='border-spacing=0;' id='ConsoleContainer'>",
              "<tbody>",
              "{{#Console", terminalId, "}}",
              "<tr><td nowrap class='term' colspan='2'>",
              "{{{ . }}}",
              "</td></tr>",
              "{{/Console", terminalId, "}}",
              "<td><div class='prompt'>$&nbsp</div></td>",
              "<td><form action='javascript:", handlerId, "()'>",
              "<input class='prompt' type='text' id='ConsoleInput",
                terminalId, "'",
              " name='ConsoleInput", terminalId, "' style='width:1200px'></td>",
              "</form></td>",
              "</tbody>",
              "</table>" ].join("");
        ractiveData[ 'Console' + terminalId ] = screenBuffer;
        ractiveParams[ 'data' ] = ractiveData;

        console.log( ractiveParams );

        var terminalReactor = new Ractive(ractiveParams);

        // We figure out the size of our terminal container to determine 
        // the number of columns and rows.
        resizeTerminal( screenBuffer, terminalContainer );

        context.executeCallback( context );

    }
}

forthConsole = new ForthConsole();

ConsoleFns = {
    'create-terminal': forthConsole.createTerminal
}

if (typeof initialDictionary !== 'undefined') {
  initialDictionary.registerWords( ConsoleFns );
}
