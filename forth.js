// Method to support various mechanisms to load a library depending on
// environment.
function importJSLibrary(library) {
  // If window is undefined, then it's probably a node.js instance which
  // imports using 'require'.
  if (typeof window == 'undefined') {
    require("./" + library)
  } else {
    // We're probably a browser, so we inject our script load into the DOM.
    var body = document.body;
    var script = document.createElement('script');
    script.type = 'text/javascript';
    script.src = library;
    body.appendChild(script);
  }
}

// We have a much more secure and sane way to deal with JSON parsing that
// doesn't use eval().
importJSLibrary( 'lib/json.js' )

// Make object creation in JavaScript much more sane by adding a create
// function.
if (typeof Object.create !== 'function') {
  Object.create = function(o) {
    var F = function() {};
    F.prototype = o;
    return new F();
  }
}

// Various methods to obtain a file and put it onto the stack, depending on the
// JavaScript environment.
if ( typeof window === 'undefined' ) {
  fs = require( 'fs' );
  var getFile = function( path, context, loadCallback ) {
    fs.readFile( path, function ( err, data ) {
      if (err) throw err;
      context.stack.push( new String( data ) );
      loadCallback( context );
    } );
  }
} else {
  var getFile = function( path, context, loadCallback ) {
    function responseIntoStack() {
      if (this.readyState == 4) {
        context.stack.push( req.responseText );
        loadCallback( context );
      }
    }

    var req = new XMLHttpRequest();
    req.onload = responseIntoStack;
    req.open( "GET", path, true );
    req.send();
  }
}

// Allows us to call Forth functions from JavaScript space, and to
// bind Forth functions from JavaScript.
function call(symbol, inputContext) {
  // If we were not passed an input context, we obtain our context
  // from the current JavaScript scope.
  if ( typeof( inputContext ) !== 'undefined' ) {
    context = inputContext;
  }

  // We obtain out function by a symbol lookup against our current context.
  fn = context.dictionary.getWord( symbol );

  // Make sure our return value is undefined.
  context.returnValue = undefined;

  // Then finally, we call out function on our current context.
  fn( context );
}

// Our context object contains the current context, with the dictionary, tokens,
// and stack state.  We can have multiple contexts running, sharing any or none
// of the states between contexts.
//
// For example, we can have separate contexts that share the same stack, and
// have different token states for an implementation of coroutines.
//
// Our spec can be another context object, if we want to clone it and then
// replace some or all of the elements of the context.
var createContext = function( spec ) {
  if ( typeof spec === 'undefined' ) { spec = {} };
  if ( 'dictionary' in spec ) { var dictionary = spec.dictionary }
    else { var dictionary = createDictionary() };
  if ( 'coros' in spec ) { var coros = spec.coros }
    else { var coros = [] };
  if ( 'stacks' in spec ) { var stacks = spec.stacks }
    else { var stacks = { "@global": createStack( "@global" ) } };
  if ( 'stack' in spec ) { var stack = spec.stack }
    else { var stack = stacks[ "@global" ] };
  if ( 'writeStack' in spec ) { var writeStack = spec.writeStack }
    else { var writeStack = stacks[ "@global" ] };
  if ( 'tokens' in spec ) { var tokens = spec.tokens }
    else { var tokens = [] };
  var returnValue = spec.returnValue;
  var callback = spec.callback;

  context = {};

  context.dictionary = dictionary
  context.stack = stack
  context.writeStack = writeStack
  context.stacks = stacks
  context.tokens = tokens
  context.returnValue = returnValue
  context.callback = callback

  return( context );
}

// Our Dictionary object creator function.
var createDictionary = function( spec ) {
  if ( typeof spec === 'undefined' ) { spec = {} };
  if ( 'dictionary' in spec ) { var dictionary = spec.dictionary }
    else { var dictionary = {} };
  // Sets of dictionaries containing Forth words to integrate into this
  // dictionary.
  if ( 'forthWords' in spec ) { var forthWordSets = spec.forthWords }
    else { var forthWordSets = [] };
  // if we were passed definitions, because we were passed a dictionary
  // as a spec object rather than a spec, we set this accordingly.
  if ( 'definitions' in spec ) { dictionary.definitions = spec.definitions };
  // we still don't have a definitions, so we set an empty definitions.
  if ( !( 'definitions' in dictionary) ) { dictionary.definitions = {} };

  // Add a new word to our dictionary.
  dictionary.register = function( tokenString, fn ) {
      this.definitions[ tokenString ] = fn;
    }

  // Given a JS dictionary, register all the words in it onto ourself.
  dictionary.registerWords = function( functionDict ) {
    for (var word in functionDict) {
        this.register( word, functionDict[ word ] );
      };
    }

  // Remove our dictionary definition.
  dictionary.remove = function( tokenString ) {
      delete( this.definitions[ tokenString ] );
    }

  // The heart of soul, definition retrieval from our dictionary.
  dictionary.getWord = function( tokenString ) {
    word = this.definitions[ tokenString ];

    // if we have a precompiled word, we return the tokens as a new array,
    // to ensure that the original precompiled word isn't sliced away
    if ( Object.prototype.toString.call( word ) === '[object Array]' ) {
      return( word.slice(0) );
    } else {
      return( word );
    };
  }

  // Now that we've defined our dictionary methods, we recurse through the
  // word sets provided as part of the specs and register them.
  for ( var forthWordSet in forthWordSets ) {
    dictionary.registerWords( forthWordSets[ forthWordSet ] );
  }

  // Finally, our new dictionary object.
  return( dictionary );

}

// Our Forth parser and execution routines; given a context object, we add
// the execution and parser routines to this.  In a future refactor, this
// should be functions used with apply() rather than being re-passed context
// to itself.
var applyExecutionContext = function( context ) {

  this.preprocessInput = function( input, context ) {
    if ( typeof input === 'undefined' ) {
      // We were not passed any input to execute, so we execute the tokens that
      // are already set in the current context.
      input = context.tokens;
    };

    // console.log( input );

    if ( typeof( input ) === "string" ) {
      // If we're a string, we split along a whitespace delimiter, for crude
      // 'tokenization'.
      tokens = input.split( /\s/ );
    } else if ( typeof( input ) == "object" ) {
      // We were passed an array, so we want to make a copy of the array rather
      // than operate directly on the array.  Operating on a definition would
      // be very bad, and break us.
      if ( 'slice' in input ) {
        tokens = input.slice(0);
      } else {
        tokens = [ input ];
      }
    } else {
      // We don't know what the hell we were passed.
      throw( "Invalid input to execution parser." );
    }

    return( tokens );
  }

  this.execute = function( input, returnContext ) {
    // This is the only function that doesn't take context as an argument,
    // instead leveraging the fact that we're a context object ourself; this
    // segues into apply() very well.

    var context = this;

    tokens = this.preprocessInput( input );

    // Rather than replace the tokens, we inject our execution *before* the
    // currently existing tokens in the stream.
    this.tokens = tokens.concat( this.tokens );

    // If we reach the end of execution of this context, we can return to a
    // different context.
    if ( typeof( returnContext ) !== 'undefined' ) {
      this.returnContext = returnContext;
    }

    // Kick off our execution parser on our current context.
    this.nextToken();
  }

  // Advance to the next token in our input stream.  This is really a wrapper
  // for parseNextToken which is a counter, and calls out to setTimeout() 
  // as appropriate to allow the browser to actually breathe.
  this.nextToken = function() {
    if ( typeof currTokenCount !== 'undefined' ) {
      currTokenCount = currTokenCount + 1
    } else {
      currTokenCount = 1
    }

    if ( ( currTokenCount % tokenresolution ) === 0 ) {
      // We've hit our speedbump, so call setTimeout.
      var nextCall = function(context) { return( function() {
          context.parseNextToken();
        } ) };
      setTimeout( nextCall( this ), 0 );
    } else {
      // Full speed ahead.
      this.parseNextToken();
    }
  }

  this.parseNextToken = function() {
    // Nothing more to parse, so we're done and return.
    if ( this.tokens.length == 0 ) {
      // if ( this.stack.coros.length !== 0 ) {
      //  this.tokens = context.stack.coros.shift();
      //  this.nextToken.apply( this );
      //} else {
      //  this.stack.running = false;
      //}
      if ( typeof this.returnContext !== 'undefined' ) {
        // We have another context to return to, so we execute the callback
        // on the old context to return control to it.
        returnContext = this.returnContext;
        this.executeCallback( returnContext );
      } else {
        // Ensure that we're not called again, ending the token execution
        // loop.
        this.callback = undefined;
        return;
      }
    }

    var context = this;

    // Before we do anything, set our callback on the current context to 
    // advance to the next token.  All Forth functions should be calling the
    // callback to complete, allowing the parser state to advance.
    context.callback = this.nextToken;

    // We move onto the next token by assigning the new token to currToken
    // and dropping it from the current token stream.
    var currToken = context.tokens.shift();

    // We're a string, so we need to evaluate it.
    if ( typeof( currToken ) == 'string' ) {
      // Null string due to extra whitespace, ignore it.
      if ( currToken == "" ) {
        context.nextToken.apply( this );
      } else if (currToken in context.dictionary.definitions) {
        // We're in the dictionary, so we do a lookup and retrieve the
        // definition.
        word = context.dictionary.getWord( currToken );
        if ( typeof( word ) == 'function' ) {
          // We found a JavaScript function or closure stored in the definition,
          // so we execute it, with the callback to move onto the next token.
          word( context );
        } else if ( typeof( word ) === 'string' ) {
          // We found a definition that only contains a string, so we need
          // to execute it as an input stream.
          word = context.compile( word.split(/\s/) );
          context.tokens = word.concat( context.tokens );
          context.nextToken.apply( this );
        } else {
          // The definition contained an array, so we insert this definition
          // into our current stream at the beginning.

          // We splice to copy the word to ensure that the original definition
          // do not get tampered with.
          copyWord = word.splice(0);
          context.tokens = copyWord.concat( context.tokens );
          context.nextToken.apply( this );
        }
      // Check if our token is a number so that we properly push it onto the
      // stack as an int or a float.
      } else if ( !isNaN( currToken ) ) {
          context.stack.push( parseFloat( currToken) );
          context.nextToken.apply( this );
      } else {
        // We don't appear to be anything that we need to execute, so we 
        // push ourself as a string onto the stack.
        context.stack.push( currToken );
        context.nextToken.apply( this );
      }
    } else if ( typeof( currToken ) == 'function' ) {
      // We're a closure, so invoke it directly.
      currToken( context );
    } else if ( typeof( currToken ) !== 'undefined' ) {
      // We're not a string or a function, so push ourself onto the stack.
      context.stack.push( currToken );
      context.nextToken.apply( this );
    }
  }

  // We are called at the end of every Forth function; this is usually
  // a callback to advance to the next token state, but can be a different
  // function or closure as needed.
  this.executeCallback = function( context ) {
    if( typeof context.callback != 'undefined' ) {
      context.callback( context );
    }
  }

  this.scanUntil = function( token, context ) {
    next = context.tokens.indexOf( token );
    if ( next != -1 ) {
      context.tokens.splice( next, 1 );
      return( context.tokens.splice( 0, next ) );
    } else {
      // We don't fail here, but undefined should be handled by whoever
      // called this as a failure, or to handle appropriately.
      return( undefined );
    }
  }

  this.compile = function( tokens ) {
    var tokenIndex = 0;

    // Check if we've been compiled in the past.
    if ( 'compiled' in tokens ) {
      return( tokens );
    }

    while ( tokenIndex <= tokens.length-1 ) {
      // We found a string in our token stream, so let's examine it.
      if ( typeof( tokens[ tokenIndex ] ) == 'string' ) {
        var token = tokens[ tokenIndex ];
        // We are a begin comment; we don't want comments in our compiled
        // output, so we discard them.
        if ( token == "(" ) {
          tokens.splice( tokenIndex, tokens.indexOf( ")" ) - tokenIndex + 1 );
        // We skip blocks.
        } else if ( token == "[" ) {
          endBlock = tokens.indexOf( "]", tokenIndex )
          if ( !( endBlock ) ) {
            throw( "COMPILE ERROR: No terminating ] found for [ block." );
          };
          var wordLookup = this.dictionary.getWord( "[" );
          tokens[ tokenIndex ] = wordLookup;
          tokenIndex = tokens.indexOf( "]", tokenIndex ) + 1;
        // We do a lookup in our dictionary for the token string.
        } else if ( token == '."' ) {
          var endString = tokens.indexOf( '"' );
          // We insert our entire string as an object in the token stream.
          if ( endString ) {
            // Convert our stream of tokens into a string.
            tokens[ tokenIndex ] = tokens.splice(
              tokenIndex + 1,                              // ."
              endString - tokenIndex - 1 )                 // "
              .join( " " );                                // finally, string
            tokens.splice( tokenIndex + 1, 1 );            // remove trailing "
          } else {
            throw( 'COMPILE ERROR: No terminating " found for ." string.' );
          }
        } else if ( tokens[tokenIndex] in this.dictionary.definitions ) {
          // We found it, so insert the definition directly into the token
          // stream in place of the word.  This can be a JavaScript function,
          // or it can be a compiled array of tokens obtained from a definition
          // written in Forth.
          var wordLookup = this.dictionary.getWord( token );
          // If we're a string, we want to keep the string lookup rather than
          // attempt to inject the string directly into the stream.
          if ( typeof( wordLookup ) === 'function' ) {
            wordLookup.tokenName = token;
            tokens[ tokenIndex ] = wordLookup;
          } else {
            wordLookup.tokenName = token;
            tokens[ tokenIndex ] = token;
          }
          tokenIndex += 1;
        } else if ( tokens[tokenIndex] == "" ) {
          // Null token to discard, caused by extra whitespaces.
          tokens.splice( tokenIndex, 1 );
        } else if ( !isNaN(tokens[tokenIndex]) ) {
          tokens[ tokenIndex ] = parseFloat( tokens[ tokenIndex ] );
          tokenIndex += 1;
        } else {
          // We were a string, but we're not anything, so we skip over this
          // token untouched.
          tokenIndex += 1;
        }
      } else {
        // We're not a string, so this token is already compiled or a
        // non-string object.
        tokenIndex += 1;
      }
    }
    // Set our compiled flag to true, so that we don't attempt to recompile.
    tokens.compiled = true;
    return( tokens );
  }

  this.showTokens = function( context ) {
    var tokenOutput = "";
    for (tokenIndex in context.tokens) {
      token = context.tokens[ tokenIndex ];
      if ( typeof( token ) === 'undefined' ) {
        tokenRep = 'undefined';
      } else if ( token.hasOwnProperty( 'tokenName' ) ) {
        tokenRep = "[ " + token.tokenName + " ]";
      } else {
        tokenRep = token;
      }
      tokenOutput = tokenOutput + tokenRep + " "; 
    }
    console.log( tokenOutput );
  };

  // Load a Forth file into our current execution context.
  this.load = function( path ) {
    loadCallback = function( context ) {
      var fileContents = context.stack.pop();
      var tokenizedContents = fileContents.split( /\s/ );
      context.tokens = tokenizedContents.concat( this.tokens );
      context.nextToken.apply( context );
    }
    getFile( path, this, loadCallback );
  }

  // We return our context object enhanced with our execution functions.
  return( this );
}

ForthFns = {
  // : word ... ; -- our Forth word definitions.
  ":": function( context ) {
    var defineBlock = context.scanUntil( ";", context )

    if ( defineBlock != undefined ) {
      // Our new word to define and put in the Dictionary.
      var newWord = defineBlock[0];
      // Our definition for the word is the rest of the statement up to ';'
      var definition = defineBlock.splice( 1, defineBlock.length );
      // We compile our definition before storing it -- this speeds up
      // execution by replacing strings with function references in the
      // token array where appropriate.
      var definition = context.compile( definition );
      // Actually define our word, just like JavaScript and Python does.
      context.dictionary.register( newWord, definition )
      context.executeCallback( context )
    } else {
      raise( "No terminating ';' found for word definition." );
    } },

  // Comments.
  '(': function( context ) {
    context.scanUntil( ")", context );
    context.executeCallback( context );
    },

  // Forth loader exposed into Forth space.
  'load-forth': function( context ) {
    var path = context.stack.pop( context );
    context.load( path );
    },
  };

// Core stack functions in Forth

createStack = function(name) {
  var channelFired = false;
  var stack = [];
  stack.name = name;
  stack.channels = [];
  stack.coros = [];
  stack.running = false;
  stack.ignoreRedirect = false;
  stack.push = function() {
    if ( arguments.length > 1 ) {
      var args = Array.prototype.slice.call(arguments);
    } else {
      var args = [ arguments[0] ];
    }

    if ( context.hasOwnProperty( 'writeStack' ) && !( stack.ignoreRedirect ) ) {
      if ( context.writeStack.name !== this.name ) {
        context.writeStack.push.apply( context.writeStack, args );
        return
      }
    }

    if ( this.channels.length ) {
      for ( channel in this.channels ) {
        // We create a new context each time we call a channel on a stack,
        // with a temporary local stack.
        var channelContext = Object.create( context );
        channelContext.tokens = [];
        channelStackId = '#'+Math.floor(Math.random()*16777215).toString(16)
        channelContext.stacks[ channelStackId ] = [];
        channelContext.stack = channelContext.stacks[ channelStackId ];
        channelContext.writeStack = channelContext.stack;
        channelContext.stack.name = channelStackId;

        // Insert our items to work upon onto our temporary channel stack.
        [].push.apply( channelContext.stack, args );

        // We execute our channel code on our channelContext.
        channelContext.execute( this.channels[ channel ].slice(0) );

        // We then copy the temporary stack contents into the stack that the
        // channel was associated with.
        [].push.apply( this, channelContext.stack );
      };

      return;
    };

    [].push.apply( this, args );

  };

  return( stack );
}

StackFns = {
  'channel': function( context ) {
    blockToExecute = context.stack.pop();
    stackToWatch = context.stack.pop();

    if ( !( stackToWatch in context.stacks ) ) {
      context.stacks[ stackToWatch ] = createStack( stackToWatch );
    };
    stackToWatch = context.stacks[ stackToWatch ];
    stackToWatch.channels.push( context.compile( blockToExecute ) );
    context.executeCallback( context );
  },

  'pipe': function( context ) {
    desiredStack = context.stack.pop();
    if ( !( desiredStack in context.stacks ) ) {
      context.stacks[ desiredStack ] = createStack( desiredStack );
    };
    context.writeStack = context.stacks[ desiredStack ];
    context.executeCallback( context );
  },

  'cancel-pipe': function( context ) {
    context.writeStack = context.stacks[ '@global' ];
  },

  'switch-stack': function( context ) {
    desiredStack = context.stack.pop();
    if ( !( desiredStack in context.stacks ) ) {
      context.stacks[ desiredStack ] = createStack( desiredStack );
    }
    context.stack = context.stacks[ desiredStack ];
    context.executeCallback( context );
  },

  // pop - ( a b c ) -> ( a b ), [ c ]
  'pop': function( context ) {
      context.returnValue = context.stack.pop();
      context.executeCallback( context );
    },

  'pop-stack': function( context ) {
      sourceStack = context.stacks[ context.stack.pop() ];
      context.stack.push( sourceStack.pop() );
      context.executeCallback( context );
    },

  // push - [ d ], ( a b c ) -> ( a b c d )
  'push': function(item, context) {
      context.stack.push( item );
      context.executeCallback( context );
    },

  'push-stack': function( context ) {
      var target = context.stack.pop();
      if ( !( target in context.stacks ) ) {
        context.stacks[ target ] = createStack( target );
      };
      var value = context.stack.pop();

      var targetStack = context.stacks[ target ];
      //console.log( "V:", value, "T:", targetStack.name,
      //  "W:", context.writeStack.name, "S:", context.stack.name );
      targetStack.ignoreRedirect = true;
      targetStack.push.apply( targetStack, [ value ] );
      targetStack.ignoreRedirect = false;
    },

  // clear stack
  'cls': function( context ) {
      while (context.stack.length > 0) {
        context.stack.pop();
      }
      context.executeCallback( context );
    },

  // drop - ( a b c ) -> ( a b ), []
  'drop': function( context ) {
      context.stack.pop();
      context.executeCallback( context );
    },

  // dup - ( a b c ) -> ( a b c c ), []
  'dup': function( context ) {
      item = context.stack[ context.stack.length - 1 ];
      context.stack.push( item );
      context.executeCallback( context );
    },

  // swap - ( a b c ) -> ( a c b ), []
  'swap': function( context ) {
      context.stack.push( context.stack.pop(), context.stack.pop() );
      context.executeCallback( context );
    },

  // nip - ( a b c d ) ->  ( a b d )
  'nip': function( context ) {
      top = context.stack.pop();
      context.stack.pop();
      context.stack.push( top );
      context.executeCallback( context );
    },

  // rot -- ( a b c ) -> ( b a c )
  'rot': function( context ) {
      first = context.stack.pop();
      second = context.stack.pop();
      third = context.stack.pop();
      context.stack.push( second, third, first );
      context.executeCallback( context );
    },

  // min_rot -- ( a b c ) -> ( c a b )
  '-rot': function( context ) {
      first = context.stack.pop();
      second = context.stack.pop();
      third = context.stack.pop();
      context.stack.push( first, third, second );
      context.executeCallback( context );
    },

  // push_many -- [ e f g ] ( a b c d ) -> ( a b c d e f g )
  'push_many': function( items, context ) {
      context.stack = context.stack.concat( items )
      context.executeCallback( context );
    },

  // Output our stack onto the console.
  '.s': function( context ) {
      for (var s=0; s<context.stack.length; s++) {
        try { console.log( context.stack.name + ":" + s + " = " + JSON.stringify( context.stack[s] ) ) }
        catch (err) { console.log( s + ": cannot show" ) }
      }
      context.executeCallback( context );
    },

  // Report on our current stack depth.
  'depth': function( context ) {
      retval = context.stack.length;
      context.stack.push( retval );
      context.executeCallback( context );
    }
  };

DebugFns = {
  'listwords': function( context ) {
      for ( var word in context.dictionary.definitions ) {
        context.stack.push( word );
      }
      context.executeCallback( context );
    },
  };

ArithmeticFns = {
  '+': function( context ) {
      context.stack.push( context.stack.pop() + context.stack.pop() );
      context.executeCallback( context );
    },

  '-': function( context ) {
      context.stack.push( context.stack.pop(), context.stack.pop() );
      context.stack.push( context.stack.pop() - context.stack.pop() );
      context.executeCallback( context );
    },

  '*': function( context ) {
      context.stack.push( context.stack.pop() * context.stack.pop() );
      context.executeCallback( context );
    },

  '/': function( context ) {
      context.stack.push( context.stack.pop(), context.stack.pop() );
      context.stack.push( context.stack.pop() - context.stack.pop() );
      context.executeCallback( context );
    },

  'rand': function( context ) {
      context.stack.push( Math.floor( Math.random() * context.stack.pop() +
                              context.stack.pop() ) );
      context.executeCallback( context );
    }
  };

// String type and manipulation functions.
splitString = 0;
parseString = 1;

parseSplitString = function( stringObject, delim, parseOrSplit ) {
    findDelim = stringObject.search( delim );
    if ( findDelim ) {
      return( [ stringObject.split( delim, 1 )[0],
                stringObject.substr( findDelim + parseOrSplit ),
                true ] );
    } else { 
      return( [ stringObject,
                '',
                false ] );
    };
}

StringFns = {
  // ."                                              ( ." a b c " -- "a b c" )
  '."': function( context ) {
    stringBlock = context.scanUntil( '"', context );
    if ( stringBlock != undefined ) {
      stringObject = stringBlock.join( " " );
      context.stack.push( stringObject );
    } else {
      throw( "Unterminated string found." );
    }
    context.executeCallback( context );
  },

  // $=                                                       ( $1 $2 -- flag )
  //
  // Compare strings.  True if equal.

  '$=': function( context ) {
    conditional( context.stack.pop() == context.stack.pop(), context );
    context.executeCallback( context );
  },

  // sindex                                                      ( $1 $2 -- n )
  //
  // Search for an occurrence of $1 inside $2.  If found, n is the offset
  // within $2 where it was found.  If not found, n is -1.
  'sindex': function( context ) {
    context.stack.push( context.stack.pop().search( context.stack.pop() ) );
    context.executeCallback( context );
  },

  // split-string                                   ( $1 delim -- tail$ head$ )
  //
  // Find the first occurrence of the character "delim" in $1.  If found,
  // head$ is the portion of $1 up to but not including the delimiter and tail$
  // is the portion of $1 from the delimiter (inclusive) to the end.  If not
  // found, head$ is $1 and tail$ is empty (i.e. its length is 0).
  'split-string': function( context ) {
    stringSplit = parseSplitString( context.stack.pop(),
                                    context.stack.pop(),
                                    splitString );
    context.stack.push( stringSplit[ 0 ], stringSplit[ 1 ] );
    context.executeCallback( context );
  },

  // left-parse-string                              ( $1 delim -- tail$ head$ )
  // 
  // Find the first occurrence of "delim" in $1.  If found, head$ is the
  // portion of $1 up to but not including the delimiter and tail$ is the
  // portion of $1 after the delimiter (not inclusive) to the end.  If not
  // found, head$ is $1 and tail$ is empty (i.e. its length is 0).
  'left-parse-string': function( context ) {
    stringSplit = parseSplitString( context.stack.pop(),
                                    context.stack.pop(),
                                    parseString );
    context.stack.push( stringSplit[ 0 ], stringSplit[ 1 ] );
    context.executeCallback( context );
  },

  // lex                     ( $1 delim$ -- tail$ head$ delim true | $1 false )
  // 
  // Find the first occurrence in $1 of any character in delim$ .  If found,
  // head$ is the portion of $1 up to but not including the delimiter,
  // tail$ is the portion of $1 after the delimiter (not inclusive) to the
  // end, delim is the actual character found, and the top of the stack is
  // true.  If not found, $1 is the original value of $1 and the top of
  // the stack is false.
  'lex': function( context ) {
    stringSplit = parseSplitString( context.stack.pop(),
                                    context.stack.pop(),
                                    parseString );
    if ( stringSplit[2] === true ) {
      context.stack.push( stringSplit[ 0 ], // head
                          stringSplit[ 1 ], // tail
                          1 );              // true
    } else {
      context.stack.push( stringSplit[ 0 ], // original string
                          0 );              // false
    };
    context.executeCallback( context );

  }
}


var conditional = function( result, context ) {
  if ( result ) {
    context.stack.push( -1 );
  } else {
    context.stack.push( 0 );
  }
  context.executeCallback( context );
}

ConditionalFns = {
  "=": function( context ) {
      conditional( context.stack.pop() == context.stack.pop(), context );
    }, 
  "<>": function( context ) {
      conditional( context.stack.pop() != context.stack.pop(), context );
    },
  "<": function( context ) {
      conditional( context.stack.pop() < context.stack.pop(), context );
    },
  ">": function( context ) {
      conditional( context.stack.pop() > context.stack.pop(), context );
    },
  "<=": function( context ) {
      conditional( context.stack.pop() <= context.stack.pop(), context );
    },
  ">=": function( context ) {
      conditional( context.stack.pop() >= context.stack.pop(), context );
    },
  "0=": function( context ) {
      conditional( context.stack.pop() == 0, context );
    },
  "0<>": function( context ) {
      conditional( context.stack.pop() != 0, context );
    },
  "0>=": function( context ) {
      conditional( context.stack.pop() < 0, context );
    },
    "0<=": function( context ) {
      conditional( context.stack.pop() > 0, context );
    },
  "true": function( context ) {
      stack.push( -1 );
      context.executeCallback( context );
    },
  "false": function( context ) {
      stack.push( 0 );
      context.executeCallback( context );
    },
  "between": function( context ) {
      num = context.stack.pop();
      low = context.stack.pop();
      high = context.stack.pop();
      conditional( low <= num <= high, context );
    },
  "within": function( context ) {
      num = context.stack.pop();
      low = context.stack.pop();
      high = context.stack.pop();
      conditional( low <= num < high, context );
    },
  "if": function( context ) {
      elseBlock = context.scanUntil( "else", context );
      thenBlock = context.scanUntil( "then", context );

      if ( thenBlock == undefined ) {
        raise( "Syntax error: IF without THEN" );
      } else if ( context.stack.pop() != 0 ) {
        thenBlock = context.compile( thenBlock );
        context.tokens = thenBlock.concat( context.tokens );
      } else if ( typeof elseBlock != undefined ) {
        context.compile( elseBlock );
        context.tokens = elseBlock.concat( context.tokens );
      }
      context.executeCallback( context );
    }
  };

LoopFns = {
    // begin .. again -- our loop functions, which really needs to be enhanced
    // to allow for conditionals.
    'begin': function( context ) {
      againBlock = context.scanUntil( "again", context );

      if ( againBlock != undefined ) {
        block = context.compile( againBlock );
        context.tokens = block.concat( [ "begin" ], block, [ "again" ] );
        context.executeCallback( context );
      } else {
        throw( "BEGIN loop without AGAIN.");
      }
    }
  };




ExecutionFns = {
  // Our resolution of tokens to allow the browser to breathe.
  'tokenresolution': function( context ) {
    tokenresolution = context.stack.pop();
    context.executeCallback( context );
  },

  // Define an execution block, which is a JavaScript array.
  '[': function( context ) {
    var executionBlock = context.scanUntil( "]", context );
    if ( executionBlock != undefined ) {
      // Do some typing of our AoT, particularly for numerics.  We don't
      // want to compile these, as these in particular may be run in another
      // context entirely that may resolve the symbols differently, like
      // an RPC call to a remote Python implementation.
      for (var index in executionBlock) {
        var currToken = executionBlock[ index ];
        if ( currToken !== '' && !isNaN(currToken) ) {
          var tokenFloat = parseFloat( currToken );
          executionBlock[ index ] = tokenFloat;
          }
      }
      // The executionBlock is pushed onto the stack as a distinct 
      // individual object.
      context.stack.push( executionBlock );
      context.executeCallback( context );
    } else {
      throw( "No closing ']' found for execution block.")
    }
  },

  // Execute Forth block, this is currently run asynchronously now that loops
  // inject more tokens into the stream rather than execute a new context.
  '|': function( context ) {
    forthCoro = context.stack.pop();

    newContext = applyExecutionContext.apply( createContext( context ) );
    newContext.execute( forthCoro );
    context.executeCallback( context );
  },

  // A Forth RPC -- we can send a Forth execution block to a server to
  // execute on our behalf.
  '#': function( context ) {
    forthExecutionBlock = context.stack.pop();

    // We actually block the main execution thread until we complete getting
    // a response back.  Server responses are encoded in JSON, with an array
    // item for each stack item returned.
    function responseIntoContext(context) {
      // Here, we actually return a function that does the job, to work around
      // scoping issues.
      return( function() {
        if (this.readyState == 4) {
          // Anyone who uses a JSON parse fn that uses exec() is batshit insane.
          response = jsonParse( myRequest.responseText );
          for (var item in response) {
            context.stack.push( response[ item ] );
          }
          context.executeCallback( context );
        }
      } );
    }

    // Our RPC call is made via XMLHttpRequest asynchronously, though we
    // force this execution thread to wait until this completes.  The contents
    // of the execution block are sent to the server in JSON.
    var myRequest = new XMLHttpRequest();
    myRequest.onload = responseIntoContext( context );
    myRequest.open( "POST", "", true );
    myRequest.setRequestHeader( "Content-Type", "text/plain" );
    myRequest.send( JSON.stringify( forthExecutionBlock ) );
  }
}

ExtraFns = {
  "time": function(context) {
    context.stack.push( new Date().getTime() );
    context.executeCallback( context );
  },
  "print": function(context) {
    console.log( context.stack.pop() )
    context.executeCallback( context );
  }
}

currTokenCount = 0;
tokenresolution = 200;

// Set up our initial Forth context with dictionary, stack, and then the
// context containing all of them.
initialDictionary = createDictionary(
  { forthWords: [ ForthFns,
                  StackFns,
                  ArithmeticFns,
                  StringFns,
                  ConditionalFns,
                  LoopFns,
                  ExecutionFns,
                  ExtraFns,
                  DebugFns ] } );
initialContext = createContext( { dictionary: initialDictionary } );
executionContext = applyExecutionContext.apply( initialContext );

// If we have 'module', we export our class instances, as we're likely
// Node.js.
if (typeof module != 'undefined' ) {
  module.exports.applyExecutionContext = applyExecutionContext; 
  module.exports.createContext = createContext;
  module.exports.initialDictionary = initialDictionary;
}
