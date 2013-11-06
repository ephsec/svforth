
function forth(stdlib, foreign, heap) {
  "use asm";

  // Our heap
  var HU32 = new stdlib.Uint32Array(heap);

  // Registers
  var eax = 0;
  var ebx = 0;
  var ecx = 0;
  var edx = 0;
  var esi = 0;
  var edi = 0;
  var ebp = 0;
  var esp = 0;
  var reg = 0;

  function Display() {
    currStack = new Uint32Array( heap, esp * 4, HU32.byteLength / 4 - esp );
    viewStack = [];
    for (i=0; i<currStack.length; i++) {
      viewStack.push( currStack[i] );
    }
    console.log( "NEXT:", ftable[eax].name, "ESP:", esp,
      "STACK:", viewStack );
  }

  function LODSL() {
    eax = HU32[esi];    // read memory into accumulator
    esi = esi + 1;      // increment ESI pointer
  };

  function NEXT() {
    LODSL();            // move onto our next instruction in the heap
    Display();
    ftable[eax]();      // execute the instruction pointed at in the heap
  };

  // Push our register passed onto the return stack.
  function PUSHRSP(reg) {
    ebp = ebp - 1;
    HU32[ebp] = reg;
  };

  // Pop our register from the return stack.
  function POPRSP(reg) {
    reg = HU32[ebp];
    ebp = ebp + 1;
  };

  function DOCOL() {
    PUSHRSP(esi);     // push our current ESI onto the return stack
    eax = eax + 4;    // eax points to our codeword, so we skip it and
    esi = eax;        // set esi to +32 bytes -- this means our Forth
                      // words can be up to 32 bytes long.
    NEXT();           // move onto the next codeword
  };

  // END is simply a stub function that doesn't call NEXT(), therby
  // ending execution.
  function END() {};

  // Forth words

  function POP() {
    reg = HU32[esp];
    esp = esp + 1;
    return( reg );
  };

  function PUSH(reg) {
    esp = esp - 1;
    HU32[esp] = reg;
  };

  function DROP() {
    eax = POP();
    NEXT();
  };

  function SWAP() {
    eax = POP();
    ebx = POP();
    PUSH(eax);
    PUSH(ebx);
    NEXT();
  };

  function DUP() {
    eax = HU32[esp];
    PUSH(eax);
    NEXT();
  };

  function OVER() {
    eax = HU32[esp+1];
    PUSH(eax);
    NEXT();
  };

  function ROT() {
    eax = POP();
    ebx = POP();
    ecx = POP();
    PUSH(eax);
    PUSH(ebx);
    PUSH(ecx);
    NEXT();
  };

  function MINROT() {
    eax = POP();
    ebx = POP();
    ecx = POP();
    PUSH(eax);
    PUSH(ecx);
    PUSH(ebx);
    NEXT();
  };

  function TWODROP() {
    eax = POP();
    eax = POP();
    NEXT();
  };

  function TWODUP() {
    eax = HU32[esp];
    ebx = HU32[esp+1];
    PUSH(ebx);
    PUSH(eax);
    NEXT();
  };

  function TWOSWAP() {
    eax = POP();
    ebx = POP();
    ecx = POP();
    edx = POP();
    PUSH(ebx);
    PUSH(eax);
    PUSH(edx);
    PUSH(ecx);
    NEXT();
  };

  function QDUP() {
    eax = HU32[esp];
    if ( eax != 0 ) {
      PUSH(eax);
    };
    NEXT();
  };

  function INCR() {
    HU32[esp] = HU32[esp] + 1;
    NEXT();
  };

  function DECR() {
    HU32[esp] = HU32[esp] - 1;
    NEXT();
  };

  function INCR4() {
    HU32[esp] = HU32[esp] + 4;
    NEXT();
  };

  function DECR4() {
    HU32[esp] = HU32[esp] - 4;
    NEXT();
  };

  function ADD() {
    eax = POP();
    HU32[esp] = HU32[esp] + eax;
    NEXT();
  };

  function SUB() {
    eax = POP();
    HU32[esp] = HU32[esp] - eax;
    NEXT();
  };

  function MUL() {
    eax = POP();
    ebx = POP();
    eax = ebx * eax;
    PUSH(eax);
    NEXT();
  };

  function DIV() {
    ebx = POP();
    eax = POP();
    eax = ebx / eax;
    PUSH(eax);
    NEXT();
  };

  var ftable = [ END, POP, PUSH, DROP, SWAP, DUP, OVER, ROT, MINROT, TWODROP,
           TWOSWAP, QDUP, INCR, DECR, INCR4, DECR4, ADD, SUB, MUL,
           DIV ];

  function execute(progAddr, endStackAddr) {
    esi = progAddr;
    esp = endStackAddr;
    NEXT();
  }

  return( execute );

};

function compile(input) {
  var tokenArray = [];
  var currIndex = 0;
  var defs = [ "END", "POP", "PUSH", "DROP", "SWAP", "DUP", "OVER", "ROT",
        "-ROT", "2DROP", "2SWAP", "?DUP", "INCR", "DECR", "INCR4",
        "DECR4", "+", "-", "*", "/" ];
  tokens = input.split(/\s/);
  while (tokens.length) {
    token = tokens.shift();
    if ( defs.indexOf( token ) ) {
      tokenArray[currIndex] = defs.indexOf( token );
      currIndex = currIndex + 1;
    }
  }

  var compiledTokens = ArrayBuffer(currIndex * 4);
  var compiledAligned32 = Uint32Array(compiledTokens);
  for (i in tokenArray) {
    compiledAligned32[i] = tokenArray[i];
  };
  return( compiledTokens );
}

// Test functions
var ForthHeap = new ArrayBuffer(128);
var ForthHeap32 = new Uint32Array(ForthHeap);
executeForth = forth(global, undefined, ForthHeap);

// Set our initial stack
ForthHeap32[31] = 1;
ForthHeap32[30] = 2;
ForthHeap32[29] = 3;

// Get a compiled list of function references
compiled = compile("+ DUP ROT SWAP OVER + DUP *")
compiled32 = new Uint32Array(compiled);

// Inject our compiled stream into our heap.
for (i in compiled32) {
  ForthHeap32[i] = compiled32[i];
};

instructionPointer = 0;
endOfStackPointer = 29;

executeForth(instructionPointer, endOfStackPointer);
