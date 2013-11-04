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
      context.stack.push( data );
      loadCallback();
    } );
  }
} else {
  var getFile = function( path, context, loadCallback ) {
    function responseIntoStack() {
      if (this.readyState == 4) {
        context.stack.push( req.responseText );
        loadCallback();
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
  if ( 'stack' in spec ) { var stack = spec.stack }
    else { var stack = [] };
  if ( 'tokens' in spec ) { var tokens = spec.tokens }
    else { var tokens = [] };
  var returnValue = spec.returnValue;
  var callback = spec.callback;

  context = {};

  context.dictionary = dictionary
  context.stack = stack
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
  this.execute = function( input, returnContext ) {
    // This is the only function that doesn't take context as an argument,
    // instead leveraging the fact that we're a context object ourself; this
    // segues into apply() very well.
    var context = this;

    if ( typeof input === 'undefined' ) {
      // We were not passed any input to execute, so we execute the tokens that
      // are already set in the current context.
      input = context.tokens;
    }

    if ( typeof( input ) == "string" ) {
      // If we're a string, we split along a whitespace delimiter, for crude
      // 'tokenization'.
      context.tokens = input.split( /\s/ );
    } else if ( typeof( input ) == "object" ) {
      // We were passed an array, so we want to make a copy of the array rather
      // than operate directly on the array.  Operating on a definition would
      // be very bad, and break us.
      context.tokens = input.slice(0);
    } else {
      // We don't know what the hell we were passed.
      throw( "Invalid input to execution parser." );
    }

    // If we reach the end of execution of this context, we can return to a
    // different context.
    if ( typeof( returnContext ) !== 'undefined' ) {
      context.returnContext = returnContext;
    }

    // Kick off our execution parser on our current context.
    context.nextToken( context );
  }

  // Advance to the next token in our input stream.  This is really a wrapper
  // for parseNextToken which is a counter, and calls out to setTimeout() 
  // as appropriate to allow the browser to actually breathe.
  this.nextToken = function( context ) {
    if ( typeof currTokenCount !== 'undefined' ) {
      currTokenCount = currTokenCount + 1
    } else {
      currTokenCount = 1
    }

    if ( ( currTokenCount % tokenresolution ) === 0 ) {
      // We've hit our speedbump, so call setTimeout.
      var nextCall = function() {
          context.parseNextToken( context );
        }
      setTimeout( nextCall, 0 );
    } else {
      // Full speed ahead.
      context.parseNextToken( context );
    }
  }

  this.parseNextToken = function( context ) {
    // Nothing more to parse, so we're done and return.
    if ( context.tokens.length == 0 ) {
      if ( typeof context.returnContext !== 'undefined' ) {
        // We have another context to return to, so we execute the callback
        // on the old context to return control to it.
        returnContext = context.returnContext;
        context.executeCallback( returnContext );
      } else {
        // Ensure that we're not called again, ending the token execution
        // loop.
        context.callback = undefined;
        return;
      }
    }

    // Before we do anything, set our callback on the current context to 
    // advance to the next token.  All Forth functions should be calling the
    // callback to complete, allowing the parser state to advance.
    context.callback = this.nextToken;

    // We move onto the next token by assigning the new token to currToken
    // and dropping it from the current token stream.
    currToken = this.advanceToken( context );

    // We're a string, so we need to evaluate it.
    if ( typeof( currToken ) == 'string' ) {
      // Null string due to extra whitespace, ignore it.
      if ( currToken == "" ) {
        context.nextToken( context );
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
          context.nextToken( context );
        } else {
          // The definition contained an array, so we insert this definition
          // into our current stream at the beginning.

          // We splice to copy the word to ensure that the original definition
          // do not get tampered with.
          copyWord = word.splice(0);
          context.tokens = copyWord.concat( context.tokens );
          context.nextToken( context );
        }
      // Check if our token is a number so that we properly push it onto the
      // stack as an int or a float.
      } else if ( !isNaN(currToken) ) {
          tokenInt = parseInt( currToken );
          tokenFloat = parseFloat( currToken );
          if ( tokenInt == tokenFloat ) {
            context.stack.push( tokenInt );
          } else {
            context.stack.push( tokenFloat );
          }
          context.nextToken( context );
      } else {
        // We don't appear to be anything that we need to execute, so we 
        // push ourself as a string onto the stack.
        context.stack.push( currToken );
        context.nextToken( context );
      }
    } else if ( typeof( currToken ) == 'function' ) {
      // We're a closure, so invoke it directly.
      currToken( context );
    } else if ( typeof( currToken ) !== 'undefined' ) {
      // We're not a string or a function, so push ourself onto the stack.
      context.stack.push( currToken );
      context.nextToken( context );
    }
  }

  // Advance to the next token, discarding it from the input stream and 
  // returning it.
  this.advanceToken = function( context ) {
    return( context.tokens.splice(0, 1)[ 0 ] );
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
    tokenIndex = 0;

    // Check if we've been compiled in the past.
    if ( 'compiled' in tokens ) {
      return( tokens );
    }

    while ( tokenIndex <= tokens.length-1 ) {
      // We found a string in our token stream, so let's examine it.
      if ( typeof( tokens[ tokenIndex ] ) == 'string' ) {
        token = tokens[ tokenIndex ];
        // We are a begin comment; we don't want comments in our compiled
        // output, so we discard them.
        if ( token == "(" ) {
          tokens.splice( tokenIndex, tokens.indexOf( ")" ) - tokenIndex + 1 );
        // We do a lookup in our dictionary for the token string.
        } else if ( tokens[tokenIndex] in this.dictionary.definitions ) {
          // We found it, so insert the definition directly into the token
          // stream in place of the word.  This can be a JavaScript function,
          // or it can be a compiled array of tokens obtained from a definition
          // written in Forth.
          wordLookup = this.dictionary.getWord( token );
          // If we're a string, we want to keep the string lookup rather than
          // attempt to inject the string directly into the stream.
          if ( typeof( wordLookup ) === 'function' ) {
            tokens[ tokenIndex ] = wordLookup;
          } else {
            tokens[ tokenIndex ] = token;
          }
          tokenIndex += 1;
        } else if ( tokens[tokenIndex] == "" ) {
          // Null token to discard, caused by extra whitespaces.
          tokens.splice( tokenIndex, 1 );
        } else if ( !isNaN(tokens[tokenIndex]) ) {
          // We're a number, but what kind?  We determine this by converting
          // to an Integer or a Float -- if they're the same, it's an Integer,
          // if they are different, it's a Float.
          tokenInt = parseInt( tokens[ tokenIndex ] );
          tokenFloat = parseFloat( tokens[ tokenIndex ] );
          if ( tokenInt == tokenFloat ) {
            tokens[ tokenIndex ] = tokenInt;
          } else {
            tokens[ tokenIndex ] = tokenFloat;
          }
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

  // Load a Forth file into our current execution context.
  this.load = function( path ) {
    context = this;
    loadCallback = function() {
      fileContents = context.stack.pop();
      tokenizedContents = fileContents.split( /\s/ );
      context.tokens = tokenizedContents.concat( context.tokens );
      context.nextToken( context );
    }
    getFile( path, context, loadCallback );
  }

  // We return our context object enhanced with our execution functions.
  return( this );
}

ForthFns = {
  // : word ... ; -- our Forth word definitions.
  ":": function( context ) {
    defineBlock = context.scanUntil( ";", context )

    if ( defineBlock != undefined ) {
      // Our new word to define and put in the Dictionary.
      newWord = defineBlock[0];
      // Our definition for the word is the rest of the statement up to ';'
      definition = defineBlock.splice( 1, defineBlock.length );
      // We compile our definition before storing it -- this speeds up
      // execution by replacing strings with function references in the
      // token array where appropriate.
      definition = context.compile( definition );
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
    path = context.stack.pop( context );
    context.load( path );
    },
  };

// Core stack functions in Forth
StackFns = {
  // pop - ( a b c ) -> ( a b ), [ c ]
  'pop' : function( context ) {
      context.returnValue = context.stack.pop();
      context.executeCallback( context );
    },

  // push - [ d ], ( a b c ) -> ( a b c d )
  'push' : function(item, context) {
      context.stack.push( item );
      context.executeCallback( context );
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
      top = context.stack.pop();
      next = context.stack.pop();
      context.stack.push( top );
      context.stack.push( next );
      context.executeCallback( context );
    },

  // nip - ( a b c d ) ->  ( a b d )
  'nip': function( context ) {
      top = context.stack.pop();
      context.stack.pop();
      context.stack.push( top );
      context.executeCallback( context );
    },

  // rot -- ( a b c d ) -> ( b c d a )
  'rot': function( context ) {
      bottom = context.stack[0];
      context.stack.splice(0, 1);
      context.stack.push( bottom );
      context.executeCallback( context );
    },

  // min_rot -- ( a b c d ) -> ( d a b c )
  '-rot': function( context ) {
      context.stack.splice( 0, 0, context.stack.pop() );
      context.executeCallback( context );
    },

  // push_many -- [ e f g ] ( a b c d ) -> ( a b c d e f g )
  'push_many': function( items, context ) {
      context.stack = context.stack.concat( items )
      context.executeCallback( context );
    },

  // Output our stack onto the console.
  '.s': function( context ) {
      for (var s in context.stack) {
         console.log( s + ": " + JSON.stringify( context.stack[s] ) )
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
      for ( var word in context.dictionary ) {
        context.stack.push( word );
      }
      context.executeCallback( context );
    }
  };

ArithmeticFns = {
  '+': function( context ) {
      context.stack.push( context.stack.pop() + context.stack.pop() );
      context.executeCallback( context );
    },

  '-': function( context ) {
      first = context.stack.pop();
      second = context.stack.pop();
      context.stack.push( second - first );
      context.executeCallback( context );
    },

  '*': function( context ) {
      context.stack.push( context.stack.pop() * context.stack.pop() );
      context.executeCallback( context );
    },

  '/': function( context ) {
      first = context.stack.pop();
      second = context.stack.pop();
      context.stack.push( second / first );
      context.executeCallback( context );
    },

  'rand': function( context ) {
      context.stack.push( Math.floor( Math.random() * context.stack.pop() +
                              context.stack.pop() ) );
      context.executeCallback( context );
    }
  };


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
        context.execute( thenBlock );
      } else if ( typeof elseBlock != undefined ) {
        context.execute( elseBlock );
      }
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
    executionBlock = context.scanUntil( "]", context );
    if ( executionBlock != undefined ) {
      // Do some typing of our AoT, particularly for numerics.  We don't
      // want to compile these, as these in particular may be run in another
      // context entirely that may resolve the symbols differently, like
      // an RPC call to a remote Python implementation.
      for (var index in executionBlock) {
        currToken = executionBlock[ index ];
        if ( !isNaN(currToken) ) {
          tokenInt = parseInt( currToken );
          tokenFloat = parseFloat( currToken );
          if ( tokenInt == tokenFloat ) {
            executionBlock[ index ] = tokenInt;
          } else {
            executionBlock[ index ] = tokenFloat;
          }
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

currTokenCount = 0;
tokenresolution = 200;

// Set up our initial Forth context with dictionary, stack, and then the
// context containing all of them.
initialDictionary = createDictionary(
  { forthWords: [ ForthFns,
                  StackFns,
                  ArithmeticFns,
                  ConditionalFns,
                  LoopFns,
                  ExecutionFns ] } );
initialContext = createContext( { dictionary: initialDictionary } );
executionContext = applyExecutionContext.apply( initialContext );

// If we have 'module', we export our class instances, as we're likely
// Node.js.
if (typeof module != 'undefined' ) {
  module.exports.applyExecutionContext = applyExecutionContext; 
  module.exports.createContext = createContext;
  module.exports.initialDictionary = initialDictionary;
}
