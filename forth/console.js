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

    function createForthHooks(screenBuffer) {
        var forthConsole = {}
        forthConsole.createOutputHandler = function() { return(
            function(item) {
                if( screenBuffer.maxLines == screenBuffer.length ) {
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
                }
            } ) } ;

        forthConsole.createPrintHandler = function() { return(
            function(context) {
                item = context.stack.pop();
                if( screenBuffer.maxLines == screenBuffer.length ) {
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

        return( forthConsole );
    }

    function registerInputHandler(inputId, screenBuffer, commandHistory) {
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
            commandHistory.push( forthInput.value );
            newExecutionContext.execute( forthInput.value );
            forthInput.value = "";
            // objectViewer.update();
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
            domObject.clientHeight / ( fontHeight ) ) - 3

        console.log( "Terminal initialized with size:",
            screenBuffer.maxCols, screenBuffer.maxLines );
    }

    function registerTerminalContext(context, screenBuffer) {
        forthConsole = createForthHooks( screenBuffer );
        context.dictionary.registerWords( {
            "print": forthConsole.createPrintHandler(),
            "clearscreen": forthConsole.createClearScreenHandler(),
            ".": forthConsole.createPeekHandler() } );
        context.console = { 'output': forthConsole.createOutputHandler() };
    }

    this.createTerminal = function(context) {
        var terminalDiv = context.stack.pop();
        var screenBuffer = context.stack.pop();

        var terminalId = Math.floor((Math.random() * 65536));

        var commandHistory = [];

        // Register output Forth words in our context to the screenBuffer
        // in question.
        registerTerminalContext( context, screenBuffer );
        handlerId = registerInputHandler( terminalId, screenBuffer,
            commandHistory  );

        var ractiveParams = {};
        var ractiveData = {};
        ractiveParams[ 'el' ] = terminalDiv;
        ractiveParams[ 'template' ] =
            [ "<table border='0' cellspacing='2' cellpadding='2' ",
              "id='ConsoleContainer'>",
              "<tbody>",
              "{{#Console", terminalId, "}}",
              "<tr><td nowrap height='15' class='term' colspan='2'>",
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
        resizeTerminal( screenBuffer, terminalDiv );

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
