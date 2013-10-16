#!/usr/bin/python
from __future__         import print_function
from BaseHTTPServer     import BaseHTTPRequestHandler, HTTPServer, test
from SocketServer       import ThreadingMixIn
from collections        import OrderedDict
import os
import json
import cgi
import urllib2
import lib.pefile as pefile
import base64
import binascii

# Empty function for typing tests
def function(): pass

class ForthDictionary():
    def __init__(self):
        self.__forthdictionary = {}

    def register(self, identifier, function):
        self.__forthdictionary[ unicode( identifier ) ] = function

    def remove(self, identifier):
        del self.__forthdictionary[token]

    def getWord(self, identifier):
        if unicode( identifier ) in self.__forthdictionary:
            return( self.__forthdictionary.get( unicode( identifier ) ) )

    def hasWord(self, identifier):
        if unicode( identifier ) in self.__forthdictionary:
            return( True )

    def registerFns(self, fnsToRegister):
        for forthWord, function in fnsToRegister:
            print( forthWord, "registered" )
            self.register( forthWord, function )

    def printKeys(self):
        print( self.__forthdictionary.keys() )

class ParserError(Exception): pass

class Parser():
    def __init__(self, dictionary):
        self.dictionary = dictionary

    def execute(self, input, context):
        if ( isinstance( input, basestring ) ) :
            tokens = input.split(" ")
            context.tokens = tokens
        elif ( isinstance(input, Tokens) or type(input) == type([]) ):
            context.tokens = input
        else:
            raise ParserError( "Invalid input to execution parser." )

        self.nextToken( context )

    def nextToken(self, context):
        stack = context.stack
        tokens = context.tokens
        dictionary = self.dictionary

        if len( tokens ) == 0:
            return
        currToken = context.tokens.pop(0)

        if ( isinstance( currToken, basestring ) ):
            if ( currToken == "" ): self.nextToken(context)
            elif dictionary.hasWord( currToken ):
                word = dictionary.getWord( currToken )
                if ( type(word) == type( function ) ):
                    #print( "Executing ", word )
                    word( context )
                elif ( isinstance( word, basestring ) ):
                    self.execute( word, context )
                elif ( type( word ) == type( [] ) ):
                    context.tokens.extend( word )
            else:
                try:
                    if int( currToken ):
                        if float( currToken ) != int( currToken ):
                            stack.push( float( currToken ) )
                        else:
                            stack.push( int( currToken ) )
                    elif currToken == "0":
                        stack.push( 0 )
                except:
                    stack.push( currToken )
        elif ( type( currToken ) == type( function ) ):
            currToken( context )
        else:
            stack.push( currToken )

        self.nextToken( context )

class Stack(list):
    def __init__(self, *args, **kwargs):
        super(Stack, self).__init__(args[0])

    def push(self, item):
        self.append( item )

class Tokens(list):
    def __init__(self, *args, **kwargs):
        super(Tokens, self).__init__(args[0])

    def scanUntil(self, token):
        try:
            next = self.index( token )
        except ValueError:
            return( None )
        returnBlock = self[0:next]
        self[0:next+1] = []
        return( returnBlock )

###############################################################################
# stack functions -- core to Forth
###############################################################################

StackFns = [
    ( "push", lambda (item, context): context.stack.push( item ) ),
    ( "clearstack", lambda (context): setattr( context.stack, [] ) ),
    # drop - ( a b c ) -> ( a b ), []
    ( "drop", lambda (context): context.stack.pop() ),
    # dup - ( a b c ) -> ( a b c c ), []
    ( "dup", lambda (context): context.stack.push( context.stack[-1] ) ),
    # swap - ( a b c ) -> ( a c b ), []
    ( "swap", lambda (context): context.stack.extend( [ context.stack.pop(),
        context.stack.pop() ] ) ),
    ( "nip", lambda (context): context.stack.pop(-2) ),
    ( "rot", lambda (context): context.stack.push( context.stack.pop(0) ) ),
    ( "-rot", lambda (context):
        context.stack.insert( 0, context.stack.pop() ) ),
    ( ".s", lambda (context): map( print, context.stack ) ),
    # depth -- ( a b c ) -> ( a b c 3 )
    ( "depth", lambda (context):
        context.stack.push( context.stack.length() ) ),
    # peek -- ( a b c d 2 ) -> ( a b c d b )
    ( "peek", lambda (context):
        context.stack.push( context.stack[ context.stack.pop() ] ) ) ]

###############################################################################
# arithmetic functions in Forth
###############################################################################

ArithmeticFns = [
    # ( a b ) -> a + b
    ( "+", lambda (context):
        context.stack.push( context.stack.pop() + context.stack.pop() ) ),
    # ( a b ) -> a - b
    ( "-", lambda (context):
        context.stack.push( context.stack.pop(-1) - context.stack.pop() ) ),
    # ( a b ) -> a * b
    ( "*", lambda (context):
        context.stack.push( context.stack.pop() * context.stack.pop() ) ),
    # ( a b ) -> a / b
    ( "/", lambda (context):
        context.stack.push( context.stack.pop(-1) / context.stack.pop() ) ),
    # ( a ) -> rand * a
    ( "rand", lambda (context):
        context.stack.push( int( random.random() * context.stack.pop() ) ) ) ]

###############################################################################
# conditional functions in Forth and supporting functions in Python
###############################################################################

def conditional(result, context):
    if result: context.stack.push(-1)
    else: context.stack.push(1)

def ifthenelse(context):
    element = context.stack.pop()
    elseBlock = context.tokens.scanUntil( "else" )
    thenBlock = context.tokens.scanUntil( "then" )

    if ( thenBlock == None ):
        raise( "Syntax error: IF without THEN" )
    elif ( element != 0 ):
        blockToExecute = thenBlock
    elif ( elseBlock != None ):
        blockToExecute = elseBlock

    newContext = context.spawn()
    newContext.parser.execute(blockToExecute, newContext)

ConditionalFns = [
    ( "=", lambda (context):
        conditional( context.stack.pop() == context.stack.pop() ) ),
    ( "<>", lambda (context):
        conditional( context.stack.pop() != context.stack.pop() ) ),
    ( "<", lambda (context):
        conditional( context.stack.pop() < context.stack.pop() ) ),
    ( ">", lambda (context):
        conditional( context.stack.pop() > context.stack.pop() ) ),
    ( "<=", lambda (context):
        conditional( context.stack.pop() <= context.stack.pop() ) ),
    ( ">=", lambda (context):
        conditional( context.stack.pop() >= context.stack.pop() ) ),
    ( "0=", lambda (context):
        conditional( context.stack.pop() == 0 ) ),
    ( "0<>", lambda (context):
        conditional( context.stack.pop() != 0 ) ),
    ( "0<=", lambda (context):
        conditional( context.stack.pop() <= 0 ) ),
    ( "true", [ -1 ] ),
    ( "false", [ 0 ] ),
    ( "between", lambda (context):
        conditional( context.stack.pop(-1) <= context.stack.pop() <=
            context.stack.pop() ) ),
    ( "within", lambda (context):
        conditional( context.stack.pop(-1) <= context.stack.pop() <
            context.stack.pop() ) ),
    ( "if", ifthenelse )
]

###############################################################################
# loop functions in Forth and supporting functions in Python
###############################################################################

def beginLoop(context):
    againBlock = context.tokens.scanUntil( "again" )
    if ( againBlock != None ):
        while True:
            # Here, we make a copy of the code block to execute upon, as
            # executing against a set of tokens is destructive.
            executeBlock = againBlock[:]
            newContext = context.spawn()
            newContext.parser.execute(executeBlock, newContext)

LoopFns = [
    ( "begin", beginLoop )
]

class Context():
    def __init__(self, dictionary=ForthDictionary()):
        self.stack = Stack([])
        self.tokens = Tokens([])
        self.dictionary = dictionary
        self.parser = Parser(dictionary)

    def spawn(self, stack=None, tokens=None):
        childContext = Context(dictionary=self.dictionary)
        if stack is not None:
            childContext.stack = stack
        else:
            childContext.stack = self.stack
        if tokens is not None:
            childContext.tokens = tokens
        else:
            childContext.tokens = self.tokens
        return( childContext )

###############################################################################
# functions to interact with HTTP servers
###############################################################################

def getHttp(context):
    url = context.stack.pop()
    rawData = urllib2.urlopen( url ).read()
    context.stack.push( rawData.decode( 'latin-1' ).encode( 'utf-8' ) )
    print( url, "fetched" )

HTTPClientFns = [
    ( "get-http", getHttp ) ]

###############################################################################
# binary analysis functions
###############################################################################

def loadBinary(context):
    path = context.stack.pop()
    context.stack.push( base64.encodestring( open(path,'r').read() ) )

def getPEInfo(context):
    rawData = context.stack.pop()
    try:
        rawData = base64.decodestring( rawData )
    except binascii.Error:
        pass

    pe = pefile.PE(data=rawData)
    sections = []
    for section in pe.sections:
        sections.append( OrderedDict( [
            ( 'section-name', section.Name ),
            ( 'section-rawdata-begin', section.PointerToRawData ),
            ( 'section-rawdata-size', section.SizeOfRawData ) ] ) )
    context.stack.push( sections )

BinaryFns = [
    ( "get-binary-peinfo", getPEInfo ),
    ( "load-binary", loadBinary ) ]

###############################################################################
# Initialize our startup Forth environment
###############################################################################
global forthdictionary
forthdictionary = ForthDictionary()
forthdictionary.registerFns( StackFns )
forthdictionary.registerFns( ArithmeticFns )
forthdictionary.registerFns( ConditionalFns )
forthdictionary.registerFns( LoopFns )
forthdictionary.registerFns( HTTPClientFns )
forthdictionary.registerFns( BinaryFns )

context = Context(dictionary=forthdictionary)

###############################################################################
# Our HTTP server to serve up client-side SVFORTH files and provide an RPC
# environment for them.
###############################################################################

class ThreadedHTTPServer(ThreadingMixIn, HTTPServer):
    pass

class HTTPHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        if ( self.path == "/" ):
            filePath = "index.html"
        else:
            filePath = self.path[1:]

        if not os.path.isfile( filePath ):
            self.send_response(404)
            self.end_headers()
        else:
            self.send_response(200)
            self.send_header("Content-type", "text/html")
            self.end_headers()
            outFile = open(filePath)
            self.wfile.write( outFile.read() )

    def do_POST(self):
        global forthdictionary
        postSize = self.headers.dict[ 'content-length' ]
        inputTokens = json.loads( self.rfile.read( int( postSize ) ) )
        httpSessionDictionary = forthdictionary
        httpSessionContext = Context(dictionary=httpSessionDictionary)
        print( "GOT RPC REQUEST: %s" % inputTokens )
        try:
            httpSessionContext.parser.execute( inputTokens, httpSessionContext )
        except Exception as err:
            httpSessionContext.stack.push( "SERVER ERROR: %s" % err )
        self.send_response(200)
        self.send_header("Content-type", 'text/data')
        self.end_headers()
        self.wfile.write( json.dumps( httpSessionContext.stack ) )

def HTTPLoop(HandlerClass=HTTPHandler, ServerClass=ThreadedHTTPServer):
    test(HandlerClass, ServerClass)

HTTPLoop()

running = True

while running:
    userinput = raw_input(">>")
    tokens = Tokens( userinput.split(" ") )
    if tokens[0]:
        context.parser.execute( tokens, context )
