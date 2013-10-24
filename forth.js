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

var createContext = function ( spec ) {
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

var createDictionary = function( spec ) {
  if ( typeof spec === 'undefined' ) { spec = {} };
  if ( 'dictionary' in spec ) { var dictionary = spec.dictionary }
    else { var dictionary = {} };
  if ( 'forthWords' in spec ) { var forthWordSets = spec.forthWords }
    else { var forthWordSets = [] };
  if ( !( '__dictionary' in dictionary) ) { dictionary.__dictionary = {} };

  dictionary.register = function( tokenString, fn ) {
      this.__dictionary[ tokenString ] = fn;
    }

  dictionary.registerWords = function( functionDict ) {
    for (var word in functionDict) {
        this.register( word, functionDict[ word ] );
      };
    }

  dictionary.remove = function( tokenString ) {
      delete this.__dictionary[ tokenString ];
    }

  dictionary.getWord = function( tokenString ) {
    word = this.__dictionary[ tokenString ];

    // if we have a precompiled word, we return the tokens as a new array,
    // to ensure that the original precompiled word isn't sliced away
    if ( Object.prototype.toString.call( word ) === '[object Array]' ) {
      return( word.slice(0) )
    } else {
      return this.__dictionary[ tokenString ];
    }
  }

  dictionary.definitions = dictionary.__dictionary;

  for ( var forthWordSet in forthWordSets ) {
    dictionary.registerWords( forthWordSets[ forthWordSet ] );
  }

  return( dictionary );

}

var createExecutionContext = function (context) {
  this.execute = function(input) {
    var context = this;

    if ( typeof input === 'undefined' ) {
      input = context.tokens;
    }

    // If we're a string, we split along a whitespace delimiter, for crude
    // 'tokenization'.
    if ( typeof( input ) == "string" ) {
      context.tokens = input.split(/\s/)
    // We were passed an array, so we want to make a copy of the array rather
    // than operate directly on the array.  Operating on a definition would
    // be very bad, and break us.
    } else if ( typeof(input) == "object" ) {
      context.tokens = input.slice(0)
    } else {
      // We don't know what the hell we were passed.
      throw( "Invalid input to execution parser." )
    }

    this.nextToken(context);
  }

  this.nextToken = function(context) {
    // Nothing more to parse, so we're done and return.
    if ( context.tokens.length == 0 ) {
      return;
    }

    context.callback = this.nextToken;

    // We move onto the next token by assigning the new token to currToken
    // and dropping it from the current token stream.
    advanceRet = this.advanceToken( context );
    currToken = advanceRet[0];
    context.tokens = advanceRet[1];

    // We're a string, so we need to evaluate it.
    if ( typeof( currToken ) == 'string' ) {
      // Null string due to extra whitespace, ignore it.
      if ( currToken == "" ) {
        this.nextToken( context );
      } else if (currToken in context.dictionary.definitions) {
        // We're in the dictionary, so we do a lookup and retrieve the
        // definition.
        word = context.dictionary.getWord( currToken );
        if ( typeof( word ) == 'function' ) {
          // We found a JavaScript function or closure stored in the definition,
          // so we execute it, with the callback to move onto the next token.
          word( context );
        } else if ( typeof( word ) == 'string' ) {
          // We found a definition that only contains a string, so we need
          // to execute it as an input stream.
          newExecution = createExecutionContext( createNewContext( context ) );
          newExecution.execute( word );
        } else {
          // The definition contained an array, so we insert this definition
          // into our current stream at the beginning.
          context.tokens = context.tokens.concat( word );
          this.nextToken( context );
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
          this.nextToken( context );
      } else {
        // We don't appear to be anything that we need to execute, so we 
        // push ourself as a string onto the stack.
        context.stack.push( currToken );
        this.nextToken( context );
      }
    } else if ( typeof( currToken ) == 'function' ) {
      // We're a closure, so invoke it directly.
      currToken( context );

    } else {
      // We're not a string or a function, so push ourself onto the stack.
      context.stack.push( currToken );
      this.nextToken( context );
    }
  }

  this.advanceToken = function(context) {
    retToken = context.tokens.splice(0, 1)[ 0 ]
    return( [ retToken, context.tokens ] );
  }

  this.executeCallback = function(context) {
    if( typeof context.callback != 'undefined' ) {
      context.callback( context );
    }
  }

  this.scanUntil = function(token, context) {
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

  return( this );

}

// Core stack functions in Forth
StackFns = {
  // pop - ( a b c ) -> ( a b ), [ c ]
  'pop' : function(context) {
      context.returnValue = context.stack.pop();
      context.executeCallback( context );
    },

  // push - [ d ], ( a b c ) -> ( a b c d )
  'push' : function(item, context) {
      context.stack.push( item );
      context.executeCallback( context );
    },

  // clear stack
  'cls': function(context) {
      while (context.stack.length > 0) {
        context.stack.pop();
      }
      context.executeCallback( context );
    },

  // drop - ( a b c ) -> ( a b ), []
  'drop': function(context) {
      context.stack.pop();
      context.executeCallback( context );
    },

  // dup - ( a b c ) -> ( a b c c ), []
  'dup': function(context) {
      item = context.stack[ context.stack.length - 1 ];
      context.stack.push( item );
      context.executeCallback( context );
    },

  // swap - ( a b c ) -> ( a c b ), []
  'swap': function(context) {
      top = context.stack.pop();
      next = context.stack.pop();
      context.stack.push( top );
      context.stack.push( next );
      context.executeCallback( context );
    },

  // nip - ( a b c d ) ->  ( a b d )
  'nip': function(context) {
      top = context.stack.pop();
      context.stack.pop();
      context.stack.push( top );
      context.executeCallback( context );
    },

  // rot -- ( a b c d ) -> ( b c d a )
  'rot': function(context) {
      bottom = context.stack[0];
      context.stack.splice(0, 1);
      context.stack.push( bottom );
      context.executeCallback( context );
    },

  // min_rot -- ( a b c d ) -> ( d a b c )
  '-rot': function(context) {
      context.stack.splice( 0, 0, context.stack.pop() );
      context.executeCallback( context );
    },

  // push_many -- [ e f g ] ( a b c d ) -> ( a b c d e f g )
  'push_many': function(items, context) {
      context.stack = context.stack.concat( items )
      context.executeCallback( context );
    },

  '.s': function(context) {
      for (var s in context.stack) {
         console.log( s + ": " + JSON.stringify( context.stack[s] ) )
      }
      context.executeCallback( context );
    },

  'depth': function(context) {
      retval = context.stack.length;
      context.executeCallback( context );
    }
}

DebugFns = {
  'listwords': function(context) {
      for ( var word in context.dictionary ) {
        context.stack.push( word );
      }
      context.executeCallback( context );
    }
}

ArithmeticFns = {
  '+': function(context) {
      context.stack.push( context.stack.pop() + context.stack.pop() );
      context.executeCallback( context );
    },

  '-': function(context) {
      first = context.stack.pop();
      second = context.stack.pop();
      context.stack.push( second - first );
      context.executeCallback( context );
    },

  '*': function(context) {
      context.stack.push( context.stack.pop() * context.stack.pop() );
      context.executeCallback( context );
    },

  '/': function(context) {
      first = context.stack.pop();
      second = context.stack.pop();
      context.stack.push( second / first );
      context.executeCallback( context );
    },

  'rand': function(context) {
      stack.push( Math.floor( Math.random() * context.stack.pop() + context.stack.pop() ) );
      context.executeCallback( context );
    }
}


var conditional = function(result, context) {
  if ( result ) {
    context.stack.push( -1 );
  } else {
    context.stack.push( 0 );
  }
  context.executeCallback( context );
}

ConditionalFns = {
  "=": function(context) {
      conditional( context.stack.pop() == context.stack.pop(), context );
    }, 
  "<>": function(context) {
      conditional( context.stack.pop() != context.stack.pop(), context );
    },
  "<": function(context) {
      conditional( context.stack.pop() < context.stack.pop(), context );
    },
  ">": function(context) {
      conditional( context.stack.pop() > context.stack.pop(), context );
    },
  "<=": function(context) {
      conditional( context.stack.pop() <= context.stack.pop(), context );
    },
  ">=": function(context) {
      conditional( context.stack.pop() >= context.stack.pop(), context );
    },
  "0=": function(context) {
      conditional( context.stack.pop() == 0, context );
    },
  "0<>": function(context) {
      conditional( context.stack.pop() != 0, context );
    },
  "0>=": function(context) {
      conditional( context.stack.pop() < 0, context );
    },
    "0<=": function(context) {
      conditional( context.stack.pop() > 0, context );
    },
  "true": function(context) {
      stack.push( -1 );
      context.executeCallback( context );
    },
  "false": function(context) {
      stack.push( 0 );
      context.executeCallback( context );
    },
  "between": function(context) {
      num = context.stack.pop();
      low = context.stack.pop();
      high = context.stack.pop();
      conditional( low <= num <= high, context );
    },
  "within": function(context) {
      num = context.stack.pop();
      low = context.stack.pop();
      high = context.stack.pop();
      conditional( low <= num < high, context );
    },
  "if": function(context) {
      elseBlock = context.scanUntil( "else", context );
      thenBlock = context.scanUntil( "then", context );

      if ( thenBlock == undefined ) {
        raise( "Syntax error: IF without THEN" );
      } else if ( context.stack.pop() != 0 ) {
        context.execute( thenBlock, context );
      } else if ( typeof elseBlock != undefined ) {
        context.execute( elseBlock, context );
      }
    }
}

initialDictionary = createDictionary(
  { forthWords: [ StackFns,
                  ArithmeticFns,
                  ConditionalFns ] } );
initialContext = createContext( { dictionary: initialDictionary } );
executionContext = createExecutionContext.apply( initialContext );


/* 
function Conditionals() {

  this.lt = 

  this.gt = 

  this.lte = 

  this.gte = 

  this.not = 

  this.nonzero = 

  this.ltz = 

  this.gtz = 

  this.ltez = function(context) {
    conditional( context.stack.pop() <= 0, callback )
  }

  this.gtez = function(context) {
    conditional( context.stack.pop() >= 0, callback )
  }

  this.true = 

  this.false = function(context) {
    stack.push( 0 )
    executeCallback( context )
  }

  this.between = 

  this.within = 

  this.ifthenelse = 


}
 
function Search()
{
  this.filter = function(context) {
      filterTerm = context.stack.pop();
      depth = stack.depth();
      for (var count=0; count < depth; count++) {
          examine = context.stack.pop();
          if ('data' in examine) {
             if (examine.data.search(filterTerm) > 0) {
                stack.push(examine);
             }
          }
          stack.rot();
      }
      context.executeCallback( context );
  }

  Word( "filter", this.filter );

}

function JsonForth() {
  this.jget = function(context) {
      field = context.stack.pop();
      artifact = context.stack.pop();
      stack.push( artifact );
      stack.push( artifact[ field ] );
      context.executeCallback( context );
  }

  Word( "jget", this.jget );

}

function Display() {
  this.show = function(context) {
      for (count=0; count<stack.depth(); count++) {
          artifact = stack.peek(count);
          if ( artifact['atype']=='irc' ) {
            irc = JSON.parse( artifact['data'] )
            console.log( irc['ts'] + ": " + irc['data'] )
          }
      }
  }

  Word( "show", this.show );

}

function DataStore() {
  this.remote = function(query, callback) {
    function responseIntoStack() {
      if (this.readyState == 4) {
        response = jsonParse(myRequest.responseText)
        for (var item in response) {
            if ( "data" in response[item] ) {
            response[item].data = jsonParse(response[item].data)
            }
          stack.push( response[item] )
        }
        executeCallback( context )
      }
    }

    var myRequest = new XMLHttpRequest()
    myRequest.onload = responseIntoStack
    myRequest.open("POST", "http://localhost:1339", true)
    myRequest.setRequestHeader("Content-Type", "text/plain")
    myRequest.send(query)
  }

  this.pull = function(context) {
    limit = context.stack.pop();
    artifactType = context.stack.pop();            
    query = artifactType + " " + limit + " pull"
    datastore.remote( query )
    context.executeCallback( context );
  }

  this.clearserverstack = function(context) {
    datastore.remote( 'cls' );
    context.executeCallback( context );      
  }

  Word( "get", this.get );
  Word( "before", this.preceding_context );
  Word( "after", this.following_context );
  Word( "context", this.context );
  Word( "pull", this.pull );
  Word( "rcls", this.clearserverstack );      // rcls ( a b c -- )
}

*/

// **************************************************************************
// The heart of our Forth, the execution parser; parser state is advanced in
// JavaScript by the use of callbacks when the function is completed.
// New execution contexts are created by instantiating the Execution object
// with a token stream or string, callback to invoke when done, and optionally
// the stack to use for this particular execution context.
// **************************************************************************

/*

function execute(context)
{

  // Set our token update resolution.
  this.updateresolution = function(context) {
    self.tokenResolution = context.stack.pop()
    executeCallback( context )
  }

  this.execute = function(input, callback, stackToUse) {
    forthparser = this

    // If we're a string, we split along a whitespace delimiter, for crude
    // 'tokenization'.
    if ( typeof( input ) == "string" ) {
      self.tokens = input.split(/\s/)
    // We were passed an array, so we want to make a copy of the array rather
    // than operate directly on the array.  Operating on a definition would
    // be very bad, and break us.
    } else if ( typeof(input) == "object" ) {
      self.tokens = input.slice(0)
    } else {
      // We don't know what the hell we were passed.
      throw( "Invalid input to execution parser." )
    }

    // We support multiple stacks, and the stack operated on is an optional
    // argument.
    if ( stackToUse != undefined ) {
      // We were passed a stack, so do the necessary setup here.
      if ( stackToUse in stacks ) {
        stack = stacks[ stackToUse ]
      } else {
        stack = new Stack()
        stacks[ stackToUse ] = stack
      }
      self.stackLabel = stackToUse
    } else {
      // We default to the @global stack if no @stack was passed in.
      stack = stacks[ "@global" ]
      self.stackLabel = "@global"
    }

    // We were passed a callback, so to ensure that it gets executed,
    // we inject it at the end of our token stream.
    if ( typeof(callback) != "undefined" ) {
      self.tokens.push( callback )
    }

    // Start the entire execution process.
    self.nextToken()
  }


  // This hack is pretty important for browsers which would hang without
  // the JavaScript execution loop yielding once in a while.  We have a 
  // 'token resolution' parameter that is a tradeoff between SVFORTH
  // performance and browser state updates.
  this.nextToken = function() {
    tokenCount += 1;

    if ( ( tokenCount % self.tokenResolution ) != 0 ) {
      parseNextToken();
    } else {
      setTimeout( function() { parseNextToken() }, 0 );
    }
  }

  function parseNextToken() {
    // Nothing more to parse, so we're done and return.
    if ( self.tokens.length == 0 ) {
      return;
    }

    // We move onto the next token by assigning the new token to currToken
    // and dropping it from the current token stream.
    advanceRet = advanceCursor();
    currToken = advanceRet[0];
    self.tokens = advanceRet[1];

    // We're a string, so we need to evaluate it.
    if ( typeof( currToken ) == 'string' ) {
      // Null string due to extra whitespace, ignore it.
      if ( currToken == "" ) {
        self.nextToken();
      } else if (currToken in dictionary.definitions) {
        // We're in the dictionary, so we do a lookup and retrieve the
        // definition.
        word = dictionary.getWord( currToken );
        if ( typeof( word ) == 'function' ) {
          // We found a JavaScript function or closure stored in the definition,
          // so we execute it, with the callback to move onto the next token.
          word( self.nextToken );
        } else if ( typeof( word ) == 'string' ) {
          // We found a definition that only contains a string, so we need
          // to execute it as an input stream.
          newExecution = new Execution();
          newExecution.execute( word, self.nextToken, self.stackLabel );
        } else {
          // The definition contained an array, so we insert this definition
          // into our current stream at the beginning.
          self.tokens = self.tokens.concat( word );
          self.nextToken();
        }
      // Check if our token is a number so that we properly push it onto the
      // stack as an int or a float.
      } else if ( !isNaN(currToken) ) {
          tokenInt = parseInt( currToken );
          tokenFloat = parseFloat( currToken );
          if ( tokenInt == tokenFloat ) {
            stack.push( tokenInt, self.nextToken );
          } else {
            stack.push( tokenFloat, self.nextToken );
          }
      } else {
        // We don't appear to be anything that we need to execute, so we 
        // push ourself as a string onto the stack.
        stack.push( currToken, self.nextToken );
      }
    } else if ( typeof( currToken ) == 'function' ) {
      // We're a closure, so invoke it directly.
      currToken( self.nextToken );

    } else {
      // We're not a string or a function, so push ourself onto the stack.
      stack.push( currToken, self.nextToken );
    }
  }

  // Move on to the next token, dropping the current token from the input
  // stream.
  function advanceCursor() {
    retToken = self.tokens.splice(0, 1)[ 0 ]
    return( [ retToken, self.tokens ] );
  }

  // Searches for the token in question, and returns the block between the
  // beginning and the token in question, removing it from the stream.


  // This helper function inserts tokens at the beginning of the token stream.
  this.insertTokens = function(newtokens) {
    self.tokens = newtokens.concat( self.tokens );
  }

  // **************************************************************************
  // SVFORTH does not strictly need a 'compiler', as it is implemented in
  // high level languages such as Python and JavaScript.  It could work
  // directly on whitespace-delimited string input streams, but sometimes we
  // want to replace these strings with actual anonymous functions in place
  // of strings where it matters, such as frequently called words.
  // **************************************************************************

  this.compile = function(tokens) {
    tokenIndex = 0;
    while ( tokenIndex <= tokens.length-1 ) {
      // We found a string in our token stream, so let's examine it.
      if ( typeof( tokens[ tokenIndex ] ) == 'string' ) {
        token = tokens[ tokenIndex ];
        // We are a begin comment; we don't want comments in our compiled
        // output, so we discard them.
        if ( token == "(" ) {
          tokens.splice( tokenIndex, tokens.indexOf( ")" ) - tokenIndex + 1 );
        // We do a lookup in our dictionary for the token string.
        } else if ( tokens[tokenIndex] in dictionary.definitions ) {
          // We found it, so insert the definition directly into the token
          // stream in place of the word.  This can be a JavaScript function,
          // or it can be a compiled array of tokens obtained from a definition
          // written in Forth.
          tokens[tokenIndex] = dictionary.getWord( token );
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
    return tokens
  }

  // **************************************************************************
  // Core to being Forth is being able to define a new word or replace any word
  // in the Dictionary.  SVFORTH only supports defining words using Forth
  // within the context of execution.  JavaScript and Python words can only
  // be defined in their respective contexts.
  // **************************************************************************

  this.define = function (callback) {
    defineBlock = self.scanUntil( ";" )

    if ( defineBlock != undefined ) {
      // Our new word to define and put in the Dictionary.
      newWord = defineBlock[0];
      // Our definition for the word is the rest of the statement up to ';'
      definition = defineBlock.splice( 1, defineBlock.length );
      // We compile our definition before storing it -- this speeds up
      // execution by replacing strings with function references in the
      // token array where appropriate.
      definition = self.compile( definition );
      // Actually define our word, just like JavaScript and Python does.
      Word( newWord, definition )
      executeCallback( callback )
    } else {
      raise( "No terminating ';' found for word definition.")
    }
  }

  this.begin = function(context) {
    againBlock = self.scanUntil( "again" )
    if ( againBlock != undefined ) {
      this.compile( againBlock )

      function blockLoop( block ) {
        forthparser.execute( block, function() { blockLoop( block ) },
          self.stackLabel)
      }

      blockLoop( againBlock )

    } else {
      throw( "BEGIN loop without AGAIN.")
    }
  }

  this.beginComment = function(context) {
    self.scanUntil( ")" );
    executeCallback( callback )
  }

}

// ***************************************************************************
// We support execution blocks as an object that is executable as a RPC, a
// coroutine, or a new blocking execution thread.
// ***************************************************************************

function ExecutionBlock() {
  self = this

  this.beginBlock = function(context) {
    executionBlock = forthparser.scanUntil( "]" );
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
      stack.push( executionBlock );
      executeCallback( callback );
    } else {
      throw( "No closing ']' found for execution block.")
    }
  }

  // A Forth coroutine -- this is run in an independent execution context
  // asynchronously.  A coroutine itself runs synchronously, like the main
  // execution thread, however.
  this.coro = function(context) {
    targetStack = context.stack.pop()
    forthClosure = context.stack.pop()
    var forthparser = new Execution()
    forthparser.execute( forthClosure, undefined, targetStack )
    // The above callout to forthparser.execute is non-blocking, so we
    // go right to continuing our current execution thread by invoking
    // the callback.
    executeCallback( callback )
  }

  // A Forth RPC -- we can send a Forth execution block to a server to
  // execute on our behalf.  We can also redirect the output of the stack
  // to a stack other than @global.
  this.rpc = function(context) {
    stackToUse = context.stack.pop()
    forthExecutionBlock = context.stack.pop()

    if ( stackToUse != undefined ) {
      if ( stackToUse in stacks ) {
        targetStack = stacks[ stackToUse ]
      } else {
        targetStack = new Stack()
        stacks[ stackToUse ] = targetStack
      }
    } else {
      stackToUse = stacks[ "@global" ]
    }

    // We actually block the main execution thread until we complete getting
    // a response back.  Server responses are encoded in JSON, with an array
    // item for each stack item returned.
    function responseIntoStack(targetStack, callback) {
      // Here, we actually return a function that does the job, to work around
      // scoping issues.
      return( function() {
        if (this.readyState == 4) {
          // Anyone who uses the JSON parse that uses exec() is batshit insane.
          response = jsonParse( myRequest.responseText );
          for (var item in response) {
            targetStack.push( response[ item ] );
          }
          executeCallback( callback );
        }
      } )
    }

    // Our RPC call is made via XMLHttpRequest asynchronously, though we
    // force this execution thread to wait until this completes.  The contents
    // of the execution block are sent to the server in JSON.
    var myRequest = new XMLHttpRequest();
    myRequest.onload = responseIntoStack( targetStack, callback );
    responseIntoStack.targetStack = targetStack;
    myRequest.open( "POST", "", true );
    myRequest.setRequestHeader( "Content-Type", "text/plain" );
    myRequest.send( JSON.stringify( forthExecutionBlock ) );
  }

  Word( "[", this.beginBlock )
  Word( "coro", this.coro )
  Word( "rpc", this.rpc )

}

// ***************************************************************************
// Instantiate the heart of our Forth system, the dictionary of Forth words
// that contain the functions associated with these words, whether in
// JavaScript or Forth.
// ***************************************************************************

var dictionary = new Dictionary();

// Helper function to register a Word -- not neccessary, but makes the code
// more readable and distinct.
function Word( name, fn )
{
    dictionary.register( name, fn );
}

// ***************************************************************************
// Inject our core stack operators into the Forth dictionary as closures.
// ***************************************************************************

// pop  ( a b c -- a b )
Word( "pop",
      function (callback) { stack.pop(callback) } );   
Word( "push",
      function (callback) { stack.push(callback) } ); 
Word( "cls",
      function (callback) { stack.clearstack(callback) } ); 
Word( "dup",
      function (callback) { stack.dup(callback) } );                        
// drop ( a b c -- a b )
Word( "drop",
      function (callback) { stack.drop(callback) } );
Word( "over",
      function (callback) { stack.over(callback) } );
// swap ( a b c -- a c b )
Word( "swap",
      function (callback) { stack.swap(callback) } );                      
Word( "nip",
      function (callback) { stack.nip(callback) } );
Word( "tuck",
      function (callback) { stack.tuck(callback) } );
Word( "rot",
      function (callback) { stack.rot(callback) } );
Word( "-rot",
      function (callback) { stack.min_rot(callback) } );
Word( ".s",
      function (callback) { stack.displaystack(callback) } );

// ***************************************************************************
// Now that our Dictionary and key operators are set up, initialize the rest
// of the Forth environment.  This currently is a set of global variables,
// which desperately needs to be refactored.
// ***************************************************************************

var stacks = { "@global": new Stack() };
var stack = stacks[ "@global" ];
var datastore = new DataStore();
var arithmetic = new Arithmetic();
var search = new Search();
var jsonforth = new JsonForth();
var display = new Display();
var conditionals = new Conditionals();
var debug = new Debug();
var forthparser = new Execution();
var executionblock = new ExecutionBlock();
var tokenCount = 0;

// Forth words that can only be used once our execution context is instantiated.

Word("listwords",
      function (callback) { debug.listwords( callback ) } )
Word( ":",
      function (callback) { forthparser.define( callback ) } )
Word( "tokenresolution",
      function (callback) { forthparser.updateresolution( callback ) } )
Word( "begin",
      function (callback) { forthparser.begin( callback ) } )
Word( "(",
      function (callback) { forthparser.beginComment( callback ) } )

*/

// If we have 'module', we export our class instances, as we're likely
// Node.js.
if (typeof module != 'undefined' ) {
  module.exports.createExecutionContext = createExecutionContext; 
  module.exports.createContext = createContext;
  module.exports.initialDictionary = initialDictionary;
}
