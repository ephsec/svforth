%pntr = type i64*
%int = type i64
%cell = type i64
%strbuf = type i8*

%FNPTR = type void ()*
%WORD = type { %WORD*, %FNPTR, i8* }

; *****************************************************************************
; stdlib functions
; *****************************************************************************

declare i8 @getchar()
declare i32 @puts(i8*)
declare i32 @read(%int, i8*, %int)
declare i32 @printf(i8*, ... )
declare void @llvm.memcpy.p0i8.p0i8.i32(i8*, i8*, i32, i32, i1)

; *****************************************************************************
; for ease of debugging, allows us to print a value to stdout
; *****************************************************************************

@valueString = internal constant    [7 x i8]  c"%llu\0D\0A\00"
@stackString = internal constant    [13 x i8] c"%llu: %llu\0D\0A\00"
@wordString =  internal constant    [5 x i8]  c"%s\0D\0A\00"
@twoWordString = internal constant  [8 x i8]  c"%s %s\0D\0A\00"
@execString = internal constant     [6 x i8]  c"EXEC:\00"
@dictString = internal constant     [6 x i8]  c"DICT:\00"
@tokenString = internal constant    [7 x i8]  c"TOKEN:\00"
@literalString = internal constant  [9 x i8]  c"LITERAL:\00"
@compiledString = internal constant [10 x i8] c"COMPILED:\00"
@charString = internal constant     [6 x i8]  c"CHAR:\00"
@progOutString = internal constant  [9 x i8]  c"PROGRAM:\00"
@dictNavString = internal constant  [15 x i8] c"--> %s (%llu) \00"
@newlineString = internal constant  [3 x i8]  c"\0D\0A\00"
@promptString = internal constant   [5 x i8]  c" Ok \00"

define void @printValue8(i8 %value) {
    %string = getelementptr [7 x i8]* @valueString, i32 0, i32 0
    %printf_ret = call i32 (i8*, ... )* @printf(i8* %string, i8 %value)
    ret void
}


define void @printValue32(i32 %value) {
    %string = getelementptr [7 x i8]* @valueString, i32 0, i32 0
    %printf_ret = call i32 (i8*, ... )* @printf(i8* %string, i32 %value)
    ret void
}

define void @printValue64(i64 %value) {
    %string = getelementptr [7 x i8]* @valueString, i32 0, i32 0
    %printf_ret = call i32 (i8*, ... )* @printf(i8* %string, i64 %value)
    ret void
}

define void @printValueInt(%int %value) {
    %string = getelementptr [7 x i8]* @valueString, i32 0, i32 0
    %printf_ret = call i32 (i8*, ... )* @printf(i8* %string, %int %value)
    ret void
}

define void @printValueCell(%cell %value) {
    %string = getelementptr [7 x i8]* @valueString, i32 0, i32 0
    %printf_ret = call i32 (i8*, ... )* @printf(i8* %string, %cell %value)
    ret void    
}

define void @printString(i8* %value) {
    %string = getelementptr [5 x i8]* @wordString, i32 0, i32 0
    %printf_ret = call i32 (i8*, ... )* @printf(i8* %string, i8* %value)
    ret void
}

define void @printTwoString(i8* %value, i8* %value2) {
    %string = getelementptr [8 x i8]* @twoWordString, i32 0, i32 0
    %printf_ret = call i32 (i8*, ... )* @printf(i8* %string, i8* %value,
        i8* %value2)
    ret void
}

define void @outputNewLine() {
    %string = getelementptr [3 x i8]* @newlineString, i32 0, i32 0
    %printf_ret = call i32 (i8*, ... )* @printf(i8* %string)
    ret void
}

; *****************************************************************************
; globals used for Forth heap, execution and stack
; *****************************************************************************

@heapPtr = weak global %pntr null       ; pointer to an alloca'ed structure
@dictPtr = weak global %WORD* null      ; pointer to the last word in the dict
@heapSize = weak global %int 0          ; size of the heap in i8 bytes
@execIdx = weak global %int 0           ; curr exec idx relative to @heapPtr
@stackIdx = weak global %int 0          ; curr stack idx relative to @heapPtr

; * constants containing strings of Forth words
@str_dispStack = internal constant [ 3 x i8 ] c".s\00"
@str_swap =      internal constant [ 5 x i8 ] c"swap\00"
@str_dup =       internal constant [ 4 x i8 ] c"dup\00"
@str_add =       internal constant [ 2 x i8 ] c"+\00"
@str_sub =       internal constant [ 2 x i8 ] c"-\00"
@str_mul =       internal constant [ 2 x i8 ] c"*\00"
@str_div =       internal constant [ 2 x i8 ] c"/\00"
@str_lit =       internal constant [ 5 x i8 ] c"_lit\00"

; * test forth program
@str_testProgram = internal constant [ 21 x i8 ] c"99 2 3 dup + swap .s\00"

; **** heap access and manipulation functions
define %pntr @getHeap_ptr(%int %index) {
    ; load our heap pointer, which is stored as a pointer
    %heapPtr = load %pntr* @heapPtr
    ; retrieve and return our value pointer
    %valuePtr = getelementptr %pntr %heapPtr, %int %index
    ret %pntr %valuePtr
}

define %int @getHeap(%int %index) {
    %valuePtr = call %pntr @getHeap_ptr(%int %index)
    %value = load %pntr %valuePtr
    ret %int %value
}

define void @putHeap(%int %index, %int %value) {
    %valuePtr = call %pntr @getHeap_ptr(%int %index)
    store %int %value, %pntr %valuePtr
    ret void
}

define void @insertToken(%int %index, void ()* %token) {
    %insPtr = call %pntr @getHeap_ptr(%int %index)
    %tokenPtrInt = ptrtoint void ()* %token to %int
    call void @putHeap(%int %index, %int %tokenPtrInt)
    ret void
}

define void @insertLiteral(%int %index, %int %value) {
    %insPtr = call %pntr @getHeap_ptr(%int %index)
    call void @putHeap(%int %index, %int %value)
    ret void
}

; **** stack manipulation functions
define void @pushStack(%int %value) {
    ; load our stack pointer which is stored as an int32, relative to @heapPtr
    %stackIdx = load %pntr @stackIdx
    ; decrement our stack pointer, as our stack is right to left from the end
    ; of the heap
    %newStackIdx = sub %int %stackIdx, 1
    ; store our value at our stack location
    call void @putHeap(%int %newStackIdx, %int %value)
    ; store our new current stack index
    store %int %newStackIdx, %pntr @stackIdx
    ret void
}

define %cell @popStack() {
    ; load our stack pointer which is stored as an int32, relative to @heapPtr
    %stackIdx = load %pntr @stackIdx
    ; grab our value to return from the stack
    %value = call %cell @getHeap(%int %stackIdx)
    ; increment our stack pointer, moving it to the right
    %newStackIdx = add %int %stackIdx, 1
    ; store our new current stack index
    store %int %newStackIdx, %pntr @stackIdx
    ; finally, return the value we popped off the stack
    ret %cell %value
}

define %cell @getTopStack() {
    ; load our stack pointer which is stored as an int32, relative to @heapPtr
    %stackIdx = load %pntr @stackIdx
    ; grab our value to return from the stack
    %value = call %int @getHeap(%int %stackIdx)
    ; finally, return the value we popped off the stack
    ret %cell %value
}

; **** execution loop functions
define %int @nextExec() {
    ; our current execution pointer, which is %heapPtr + %execIdx
    %execIdx = load %pntr @execIdx
    ; dereference our heap pointer and point at the element under the %execIdx
    ; indice
    %ins = call %int @getHeap(%int %execIdx)
    ; increment our instruction pointer and store it
    %nextExec = add %int %execIdx, 1
    store %int %nextExec, %pntr @execIdx
    ; finally, return our instruction
    ret %int %ins
}

define void @next() {
    ; c"EXEC:"
    %execString = getelementptr [6 x i8]* @execString, i32 0, i32 0

    %ins = call %int @nextExec()

    %is_done = icmp eq %int %ins, 0
    br i1 %is_done, label %done, label %execIns

execIns:
    %currToken = call %strbuf @lookupFn(%int %ins)
    call void @printTwoString(%strbuf %execString, %strbuf %currToken)

    %functionPtr = inttoptr %int %ins to void ()*
    call void %functionPtr()
    ret void    

done:
    ret void
}

; *** dictionary functions
;
; The dictionary is a linked list, where the global dictionary pointer points
; at the last word in the dictionary.  Each dictionary entry %WORD is defined
; as such:
;
; { %WORD*, %FNPTR, i8* }
;
; * %WORD* is a pointer to the previous word in the dictionary
; * %FNPTR* is a pointer to the function associated with this word
; * i8* is a pointer to a null terminated string that contains the string
;   representation of the word.
;
; In other words, it is:
; +--------------------------+---------------------+-------+
; | pointer to previous word | pointer to assembly | name  |
; +--------------------------+---------------------+-------+
;
; So, an example dictionary would look like:
;
;         null - terminates dictionary
;          ^
;          |
; +--------|-------------+--------------------------+-------+
; | pointer to null      | pointer to @DISPSTACK fn | .s    |
; +----------------------+--------------------------+-------+
;          ^
;          |
; +--------|-------------+--------------------------+-------+
; | pointer to DISPSTACK | pointer to @DIV fn       | /     |
; +----------------------+--------------------------+-------+
;          ^
;          |
; +--------|-------------+--------------------------+-------+
; | pointer to DIV       | pointer to @MUL fn       | *     |
; +----------------------+--------------------------+-------+
;          ^
;          |
;          |
;      @dictPtr*
;
; This arrangement allows Forth to redefine a word without overriding an
; already compiled reference to the word.  Once the redefinition is done with,
; it can then be FORGOT -- restoring the original definition.  This allows
; for some very powerful redefinitions of functions for current contexts.

define void @registerDictionary(i8* %wordString, %WORD* %newDictEntry,
                                %FNPTR %wordPtr) {
    %dictPtr = load %WORD** @dictPtr

    %newDictEntry.prevEntry = getelementptr %WORD* %newDictEntry, i32 0, i32 0
    %newDictEntry.wordPtr = getelementptr %WORD* %newDictEntry, i32 0, i32 1
    %newDictEntry.wordString = getelementptr %WORD* %newDictEntry, i32 0, i32 2
    store %WORD* %dictPtr, %WORD** %newDictEntry.prevEntry
    store %FNPTR %wordPtr, %FNPTR* %newDictEntry.wordPtr
    store i8* %wordString, i8** %newDictEntry.wordString

    ; move our dictionary pointer to the newly defined word, the new tail
    store %WORD* %newDictEntry, %WORD** @dictPtr

    ret void
}

define void @printDictionary() {
    ; c"--> %s (%llu) \00"
    %dictNavString.ptr = getelementptr [15 x i8]* @dictNavString, i32 0, i32 0

    ; load the last word that the dictionary pointer references into %currWord
    %dict.ptr = load %WORD** @dictPtr
    %dictWord.ptr = getelementptr %WORD* %dict.ptr, i32 0
    %dictWord.value = load %WORD* %dictWord.ptr
    %currWord.ptr = alloca %WORD
    store %WORD %dictWord.value, %WORD* %currWord.ptr

    br label %begin
begin:
    ; check if we've hit a null pointer; if we have, we're done.
    %is_null.flag = icmp eq %WORD* %currWord.ptr, null
    br i1 %is_null.flag, label %done, label %printWord
printWord:
    ; derefernce our current word pointer and then our string
    %currWord.wordString.ptr.ptr = getelementptr %WORD* %currWord.ptr,
                                                        i32 0, i32 2
    %currWord.wordString.ptr = load i8** %currWord.wordString.ptr.ptr

    ; obtain our function pointer, dereference it, and conver the pointer to
    ; an int for human representation
    %forthFn.ptr.ptr = getelementptr %WORD* %currWord.ptr, i32 0, i32 1
    %forthFn.ptr = load void()** %forthFn.ptr.ptr
    %forthFn.ptr.int = ptrtoint void()* %forthFn.ptr to %int

    ; print our pretty dictionary order
    %printf_ret = call i32 (i8*, ... )* @printf(i8* %dictNavString.ptr,
                                                i8* %currWord.wordString.ptr,
                                                i64 %forthFn.ptr.int)

    ; advance to the next definition
    %nextWord.ptr.ptr = getelementptr %WORD* %currWord.ptr, i32 0, i32 0
    %nextWord.ptr = load %WORD** %nextWord.ptr.ptr

    ; check if we've hit the end of our dictionary
    %is_next_null.flag = icmp eq %WORD* %nextWord.ptr, null
    br i1 %is_next_null.flag, label %done, label %continueSetup
continueSetup:
    ; store our next dictionary word into our current working word
    %nextWord = load %WORD* %nextWord.ptr
    store %WORD %nextWord, %WORD* %currWord.ptr
    br label %begin
done:
    ; clean up by outputting a new line before returning
    call void @outputNewLine()
    ret void

}

define %strbuf @lookupFn(%int %fnPntr.value) {
    ; setup with the tail end of our dictionary
    %tailDictPtr.ptr = load %WORD** @dictPtr
    %dictWord.ptr = getelementptr %WORD* %tailDictPtr.ptr, i32 0
    %dictWord.value = load %WORD* %dictWord.ptr

    ; copy our current dictWord into a local working space
    %currDictWord.ptr = alloca %WORD
    store %WORD %dictWord.value, %WORD* %currDictWord.ptr

    br label %begin

begin:
    ; first, we check if we've reached the end of our dictionary chain, which
    ; would be a null pointer at the first definition
    %is_null = icmp eq %WORD* %currDictWord.ptr, null
    br i1 %is_null, label %notFound, label %checkWord
checkWord:
    %currFn.ptr.ptr = getelementptr %WORD* %currDictWord.ptr, i32 0, i32 1
    %currFn.ptr = load void()** %currFn.ptr.ptr
    %currFn.ptr.value = ptrtoint void()* %currFn.ptr to %int

    %is_fn.flag = icmp eq %int %fnPntr.value, %currFn.ptr.value
    br i1 %is_fn.flag, label %returnFnString, label %nextFn
nextFn:
    ; advance to the next word by looking up the current word's pointer to
    ; the next
    %nextDictWord.ptr.ptr = getelementptr %WORD* %currDictWord.ptr,
                                          i32 0, i32 0
    %nextDictWord.ptr = load %WORD** %nextDictWord.ptr.ptr

    ; we check if the next word's pointer is null -- if it is, we've reached
    ; the end of the dictionary with no match
    %is_next_null.flag = icmp eq %WORD* %nextDictWord.ptr, null
    br i1 %is_next_null.flag, label %notFound, label %finishNextFn
finishNextFn:
    ; grab the next word and copy it into our current working word
    %nextDictWord.value = load %WORD* %nextDictWord.ptr
    store %WORD %nextDictWord.value, %WORD* %currDictWord.ptr
    ; begin the loop all over again
    br label %begin
returnFnString:
    ; derefernce our current word pointer and then our string
    %currDictWord.wordString.ptr.ptr = getelementptr %WORD* %currDictWord.ptr,
                                                        i32 0, i32 2
    %currDictWord.wordString.ptr = load i8** %currDictWord.wordString.ptr.ptr

    ret %strbuf %currDictWord.wordString.ptr
notFound:
    ret %strbuf null
} 

define %FNPTR @lookupDictionary(i8* %wordString) {
    ; c"TOKEN:\00"
    %tokenString.ptr = getelementptr [ 7 x i8 ]* @tokenString, i32 0
    %tokenString.i8.ptr = bitcast [ 7 x i8 ]* %tokenString.ptr to i8*
    ; c"DICT:\00"
    %dictString.ptr = getelementptr [ 6 x i8 ]* @dictString, i32 0
    %dictString.i8.ptr = bitcast [ 6 x i8 ]* %dictString.ptr to i8*

    ; allocate our current index in the two words that we compare
    %charIdx.ptr = alloca i32

    ; setup with the tail end of our dictionary
    %tailDictPtr.ptr = load %WORD** @dictPtr
    %dictWord.ptr = getelementptr %WORD* %tailDictPtr.ptr, i32 0
    %dictWord.value = load %WORD* %dictWord.ptr

    ; copy our current dictWord into a local working space
    %currDictWord.ptr = alloca %WORD
    store %WORD %dictWord.value, %WORD* %currDictWord.ptr

    br label %begin

begin:
    ; first, we check if we've reached the end of our dictionary chain, which
    ; would be a null pointer at the first definition
    %is_null = icmp eq %WORD* %currDictWord.ptr, null
    br i1 %is_null, label %notFound, label %checkWord
checkWord:
    ; reset our word character index to 0 as we're checking a new definition
    store i32 0, i32* %charIdx.ptr

    ; grab the pointer to the string representation of our current dict entry
    %dictWord.wordString.ptr.ptr = getelementptr %WORD* %currDictWord.ptr,
                                                 i32 0, i32 2
    %dictWord.wordString.ptr = load i8** %dictWord.wordString.ptr.ptr

    ; begin our string comparison block
    br label %compChar
compChar:
    %charIdx.value = load i32* %charIdx.ptr
    ; set up our current character from the dictionary word string
    %dict.char.ptr = getelementptr i8* %dictWord.wordString.ptr,
                                   i32 %charIdx.value
    %dict.char = load i8* %dict.char.ptr
    ; set up our current character from the target string we're working with
    %wstr.char.ptr = getelementptr i8* %wordString,
                                   i32 %charIdx.value
    %wstr.char = load i8* %wstr.char.ptr

    ; show the user the current characters we're looking at
    ;call void @printTwoString( i8* %dictString.i8.ptr, i8* %dict.charPtr )
    ;call void @printTwoString( i8* %tokenString.i8.ptr, i8* %wstr.charPtr )

    ; check if we're looking at a null terminator in either case
    %dict.is_null.flag = icmp eq i8 %dict.char, 0
    %wstr.is_null.flag = icmp eq i8 %wstr.char, 0

    ; if both are null characters, we've hit the end of both strings without
    ; a mismatch and have successfully found a match
    %is_match.flag = and i1 %dict.is_null.flag, %wstr.is_null.flag
    br i1 %is_match.flag, label %foundDefn, label %checkNull
checkNull:
    ; if either and not both are null characters, we've reached the end of one
    ; string -- the beginning is a substring of the other, but it's not a match
    %hit_null.flag = or i1 %dict.is_null.flag, %wstr.is_null.flag
    br i1 %hit_null.flag, label %nextWord, label %checkChar
checkChar:
    ; then finally, we check if the two characters are the same; if not, we
    ; abandon the current definition, and advance to the next word in the
    ; dictionary. if they are the same, we move on to the next character
    %is_same.flag = icmp eq i8 %wstr.char, %dict.char
    br i1 %is_same.flag, label %nextChar, label %nextWord
nextChar:
    ; increment the character index and start our loop again
    %newCharIdx.value = add i32 %charIdx.value, 1
    store i32 %newCharIdx.value, i32* %charIdx.ptr
    br label %compChar
nextWord:
    ; advance to the next word by looking up the current word's pointer to
    ; the next
    %nextDictWord.ptr.ptr = getelementptr %WORD* %currDictWord.ptr,
                                          i32 0, i32 0
    %nextDictWord.ptr = load %WORD** %nextDictWord.ptr.ptr

    ; we check if the next word's pointer is null -- if it is, we've reached
    ; the end of the dictionary with no match
    %is_next_null.flag = icmp eq %WORD* %nextDictWord.ptr, null
    br i1 %is_next_null.flag, label %notFound, label %finishNextWord
finishNextWord:
    ; grab the next word and copy it into our current working word
    %nextDictWord.value = load %WORD* %nextDictWord.ptr
    store %WORD %nextDictWord.value, %WORD* %currDictWord.ptr
    ; begin the loop all over again
    br label %begin
foundDefn:
    ; get the pointer to our function and return it to the caller
    %forthFn.ptr.ptr = getelementptr %WORD* %currDictWord.ptr, i32 0, i32 1
    %forthFn.ptr = load %FNPTR* %forthFn.ptr.ptr
    ret %FNPTR %forthFn.ptr
notFound:
    ; we didn't find anything, so we return null
    ret %FNPTR null
}

; *** compiler functions
define void @compile(i8* %programString.ptr, %int %heapIdx.value) {
    ; c"PROGRAM:\00"
    %progOutString.ptr = getelementptr [9 x i8]* @progOutString, i32 0, i32 0
    ; c"COMPILED:\00"
    %compiledString.ptr = getelementptr [10 x i8]* @compiledString, i32 0, i32 0
    ; c"CHAR:\00"
    %charString.ptr = getelementptr [6 x i8]* @charString, i32 0, i32 0
    ; c"LITERAL:\00"
    %literalString.ptr = getelementptr [9 x i8]* @literalString, i32 0, i32 0

    %progStrIdx.ptr = alloca i32        ; where we are in the program string
    %beginCurrToken.ptr = alloca i32    ; where the current token begins
    %currChr.ptr = alloca i8            ; a pointer to the current character
    %currHeapIdx.ptr = alloca %int      ; where in the heap we insert our token

    ; we start at the beginning of the program string
    store i32 0, i32* %progStrIdx.ptr
    ; initialize our local heap pointer to the value passed into the function
    store %int %heapIdx.value, %int* %currHeapIdx.ptr

    ; show the user what we're working with
    call void @printTwoString(i8* %progOutString.ptr, i8* %programString.ptr)

    ; begin the whole process
    br label %beginToken

beginToken:
    ; grab our current program string index to work with
    %progStrIdx.value = load i32* %progStrIdx.ptr

    ; mark this as the beginning of our new token
    store i32 %progStrIdx.value, i32* %beginCurrToken.ptr

    ; resolve the programString pointer and index, and obtain our current char
    %currChr.ptr.beginToken = getelementptr i8* %programString.ptr,
                                           i32 %progStrIdx.value
    %currChr.value.beginToken = load i8* %currChr.ptr.beginToken
    store i8 %currChr.value.beginToken, i8* %currChr.ptr

    ; check if we're a null byte and branch accordingly; null byte terminates
    %is_null.flag = icmp eq i8 %currChr.value.beginToken, 0
    br i1 %is_null.flag, label %done, label %scanSpace

scanSpace:
    ; debug call to show what character we're looking at
    ;call void @printTwoString(i8* %charString.ptr, i8* %currChr.ptr)

    %currChr.value = load i8* %currChr.ptr
    ; check if we're a space
    %is_space.flag = icmp eq i8 %currChr.value, 32
    ; also check if we're a null character
    %is_null.flag.scanSpace = icmp eq i8 %currChr.value, 0
    ; if we're a null character or a space, we terminate our token
    %is_token.flag = or i1 %is_space.flag, %is_null.flag.scanSpace
    br i1 %is_token.flag, label %handleToken, label %nextChr

nextChr:
    ; advance the program pointer and set up the character for the next pass
    %progStrIdx.value.nextChr = load i32* %progStrIdx.ptr
    %nextProgStrIdx.value = add i32 %progStrIdx.value.nextChr, 1
    store i32 %nextProgStrIdx.value, i32* %progStrIdx.ptr
    ; grab our current character from programString and store it
    %currChr.ptr.nextChr = getelementptr i8* %programString.ptr,
                                         i32 %nextProgStrIdx.value
    %currChr.value.nextChr = load i8* %currChr.ptr.nextChr
    store i8 %currChr.value.nextChr, i8* %currChr.ptr
    ; evaluate our new current character
    br label %scanSpace

handleToken:
    ; compute and acquire the beginning and the end of the token
    %progStrIdx.value.handleToken = load i32* %progStrIdx.ptr
    ; the end of our current token is our current program string index
    %endCurrToken.ptr = alloca i32
    store i32 %progStrIdx.value.handleToken, i32* %endCurrToken.ptr
    %endCurrToken.value = load i32* %endCurrToken.ptr
    %beginCurrToken.value = load i32* %beginCurrToken.ptr
    %tokenLength.value = sub i32 %endCurrToken.value, %beginCurrToken.value
    ; we include the null byte for our new token string
    %tokenLengthPad.value = add i32 %tokenLength.value, 1
    ; get pointer to beginning of our token in the program string
    %currTokenBegin.ptr = getelementptr i8* %programString.ptr,
                                        i32 %beginCurrToken.value

    ; copy the token string in question from the program string source
    %currToken.ptr = alloca i8, i32 %tokenLengthPad.value
    call void @llvm.memcpy.p0i8.p0i8.i32(i8* %currToken.ptr,
                                         i8* %currTokenBegin.ptr,
                                         i32 %tokenLength.value, i32 0, i1 0)


    ; add a null byte at the end to make it a null terminated string
    %nullLocation.ptr = getelementptr i8* %currToken.ptr,
                                      i32 %tokenLength.value
    store i8 00, i8* %nullLocation.ptr

    ; call void @printTwoString(i8* %charString.ptr, i8* %currToken.ptr)

    ; lookup our token in the dictionary
    %forthFn.ptr = call void ()* (i8*)* @lookupDictionary(i8* %currToken.ptr)

    ; load our current heap index for inserting a pointer or a literal
    %currHeapIdx.value = load %int* %currHeapIdx.ptr

    ; check if we have a function pointer, or a null pointer
    %is_fnPtr_null = icmp eq %FNPTR %forthFn.ptr, null
    br i1 %is_fnPtr_null, label %checkLiteral, label %insertFn

insertFn:
    ; insert our function pointer into our heap
    call void @insertToken(%int %currHeapIdx.value, %FNPTR %forthFn.ptr)

    ; advance our local heap index now that we've inserted a token
    %newHeapIdx.value = add %int %currHeapIdx.value, 1
    store %int %newHeapIdx.value, %int* %currHeapIdx.ptr

    ; show that we've 'compiled' a token
    call void @printTwoString(i8* %compiledString.ptr, i8* %currToken.ptr)

    ; all done with the token, let's move on
    br label %advanceIdx

checkLiteral:
    ; our current token was not found on the dictionary, so we interpret it
    ; as a literal, insert LIT pointer into our execution stream and then
    ; insert the literal there

    ; set up values for our literal parser
    %literalInt.ptr = alloca %int
    store %int 0, %pntr %literalInt.ptr
    %tokenIdx.ptr = alloca %int
    %currDigit.ptr = alloca %int
    store %int 0, %pntr %currDigit.ptr

    ; initialize our positional multiplier with 1, the first rightmost digit
    %posMultiplier.ptr = alloca %int
    store %int 1, %pntr %posMultiplier.ptr

    ; we scan our literal right to left, so set our pointer to the end
    %tokenLength.value.int = zext i32 %tokenLength.value to %int
    %newTokenIdx.value = sub %int %tokenLength.value.int, 1
    store %int %newTokenIdx.value, %pntr %tokenIdx.ptr

    br label %literalLoop

literalLoop:
    %tokenIdx.value = load %pntr %tokenIdx.ptr
    %litChr.ptr = getelementptr i8* %currToken.ptr, %int %tokenIdx.value
    %litChr.value = load i8* %litChr.ptr

    ; 0-9 is ASCII 48-57 -- check if we are within this
    %is_less.flag = icmp ult i8 %litChr.value, 48
    %is_more.flag = icmp ugt i8 %litChr.value, 57
    %is_outside.flag = or i1 %is_less.flag, %is_more.flag
    br i1 %is_outside.flag, label %invalidLiteral, label %validChar

validChar:
    ; we're within ASCII range 48-57, so subtract 48 to get our digit
    %digit.value = sub i8 %litChr.value, 48
    %digit.value.int = zext i8 %digit.value to %int

    ; get our current positional multiplier and multiply our digit by that
    %posMultiplier.value = load %pntr %posMultiplier.ptr
    %posValue.value = mul %int %digit.value.int, %posMultiplier.value

    ; add our positioned digit to our current running total
    %literalInt.value = load %pntr %literalInt.ptr
    %newLiteralInt.value = add %int %literalInt.value, %posValue.value
    store %int %newLiteralInt.value, %pntr %literalInt.ptr

    ; if we're at the leftmost digit, we're done
    %is_done.flag = icmp eq %int %tokenIdx.value, 0
    br i1 %is_done.flag, label %insertLiteral, label %nextLitChr

nextLitChr:
    ; increase our multiplier with the new digit, multiplying by 10
    %newPosMultiplier.value = mul %int %posMultiplier.value, 10
    store %int %newPosMultiplier.value, %pntr %posMultiplier.ptr

    %nextLiteralIdx.value = sub %int %tokenIdx.value, 1
    store %int %nextLiteralIdx.value, %pntr %tokenIdx.ptr
    br label %literalLoop

insertLiteral:
    ; insert our _LIT function into the heap
    call void @insertToken(%int %currHeapIdx.value, %FNPTR @LIT)
    %newHeapIdx.value.insertLiteral = add %int %currHeapIdx.value, 1

    ; Now that we have our constructed literal, insert it into the heap
    call void @insertLiteral(%int %newHeapIdx.value.insertLiteral,
                             %int %newLiteralInt.value)

    ; report our new literal to the user
    call void @printTwoString(i8* %literalString.ptr, i8* %currToken.ptr)

    ; Finally, increment and store our current heap pointer.
    %storeHeapIdx.value = add %int %newHeapIdx.value.insertLiteral, 1
    store %int %storeHeapIdx.value, %pntr %currHeapIdx.ptr

    br label %advanceIdx

advanceIdx:
    ; advance past the space we're hovering over at present
    %nextProgStrIdx.value.handleToken = add i32 %progStrIdx.value.handleToken, 1
    store i32 %nextProgStrIdx.value.handleToken, i32* %progStrIdx.ptr

    ; begin all over again
    br label %beginToken

invalidLiteral:
    ;call void @printValueInt(%int 9999999)
    br label %done

done:
    %currHeapIdx.value.done = load %pntr %currHeapIdx.ptr

    ; clean up by terminating our compiled output with a null byte
    call void @insertLiteral(%int %currHeapIdx.value.done,
                             %int 00)

    ret void
}

; *****************************************************************************
; utility routine to show the current contents of our stack
; *****************************************************************************

define void @showStack() {
    %stack_string = getelementptr [13 x i8]* @stackString, i64 0, i64 0

    ; set up our loop with the current stack pointer
    %currStackIdx = alloca %int
    %getStackIdx = load %pntr @stackIdx
    store %int %getStackIdx, %pntr %currStackIdx

    ; we need the heap size to figure out how deep our stack currently is
    %heapSize = load %pntr @heapSize

    ; kick off the loop
    br label %loop

loop:
    ; load our current stack index into a temporary value
    %stackIdx = load %pntr %currStackIdx
    ; check if the stack index has reached the heap size yet
    %is_done = icmp uge %int %stackIdx, %heapSize
    br i1 %is_done, label %done, label %continue_loop

continue_loop:
    ; call our getHeap routine to get the stack value under the index pointer
    %currStackValue = call %int @getHeap(%int %stackIdx)

    ; compute our distance relative to the end of the heap for the stack pos
    %relStackIdx = sub %int %heapSize, %stackIdx

    ; call out to printf with our pair of values
    call i32 (i8*, ... )* @printf(i8* %stack_string, %cell %relStackIdx,
        %int %currStackValue)

    ; increment and store our new stack index value, starting the loop again
    %newStackIdx = add %int %stackIdx, 1
    store %int %newStackIdx, %pntr %currStackIdx
    br label %loop

done:
    ret void

}

; *****************************************************************************
; here be FORTH words now
; *****************************************************************************

define void @LIT() noreturn {
    %execIdx.value = load %pntr @execIdx
    %ahead.value = call %cell @getHeap(%int %execIdx.value)
    call void @pushStack(%cell %ahead.value)
    %execIdxIncr.value = add %int %execIdx.value, 1
    store %int %execIdxIncr.value, %pntr @execIdx
    call void @next()
    ret void
}

define void @SWAP() noreturn {
    %first = call %cell @popStack()
    %second = call %cell @popStack()
    call void @pushStack(%cell %first)
    call void @pushStack(%cell %second)
    call void @next()
    ret void
}

define void @DUP() noreturn {
    %first = call %cell @getTopStack()
    call void @pushStack(%cell %first)
    call void @next()
    ret void
}

define void @ADD() noreturn {
    %first = call %cell @popStack()
    %second = call %cell @popStack()
    %result = add %cell %first, %second
    call void @pushStack(%cell %result)
    call void @next()
    ret void
}

define void @SUB() noreturn {
    %first = call %cell @popStack()
    %second = call %cell @popStack()
    %result = sub %cell %second, %first
    call void @pushStack(%cell %result)
    call void @next()
    ret void
}

define void @MUL() noreturn {
    %first = call %cell @popStack()
    %second = call %cell @popStack()
    %result = mul %cell %first, %second
    call void @pushStack(%cell %result)
    call void @next()
    ret void
}

define void @DIV() noreturn {
    %first = call %cell @popStack()
    %second = call %cell @popStack()
    %result = udiv %cell %second, %first
    call void @pushStack(%cell %result)
    call void @next()
    ret void
}

define void @DISPSTACK() noreturn {
    call void @showStack()
    call void @next()
    ret void
}

; *****************************************************************************
; user interaction
; *****************************************************************************

define void @repl() {
    %promptString.ptr = getelementptr [5 x i8]* @promptString, i32 0, i32 0

    %currChr.ptr = alloca i8
    %inputBuffer.ptr = alloca i8, i16 1024
    %inputBufferIdx.ptr = alloca i16
    store i8 0, i8* %currChr.ptr
    store i16 0, i16* %inputBufferIdx.ptr

    br label %prompt

prompt:
    call void @printString( i8* %promptString.ptr )
    br label %inputLoop

inputLoop:
    %inputBufferIdx.value = load i16* %inputBufferIdx.ptr
    %inChr.value = call i8 @getchar()

    ; check for carriage return to decide if we execute or get another char
    %is_cr = icmp eq i8 %inChr.value, 10
    br i1 %is_cr, label %execBuffer, label %addBuffer

addBuffer:
    %inputBufferWindow.ptr = getelementptr i8* %inputBuffer.ptr,
                                           i16 %inputBufferIdx.value
    store i8 %inChr.value, i8* %inputBufferWindow.ptr
    %newInputBufferIdx.value = add i16 %inputBufferIdx.value, 1
    store i16 %newInputBufferIdx.value, i16* %inputBufferIdx.ptr 

    br label %inputLoop

execBuffer:
    ; add a null byte at the end to make it a null terminated string
    %nullLocation.ptr = getelementptr i8* %inputBuffer.ptr,
                                      i16 %inputBufferIdx.value
    store i8 00, i8* %nullLocation.ptr

    ; compile our input into the beginning of our heap
    call void @compile(i8* %inputBuffer.ptr, %int 0)

    ; reset our execution pointer to 0
    store %int 0, %pntr @execIdx

    ; kick off our compiled program
    call void @next()

    ; reset our input buffer pointer to 0
    store i16 0, i16* %inputBufferIdx.ptr

    br label %prompt

    ret void
}

; *****************************************************************************
; main function
; *****************************************************************************

define %int @main() {
    ; we allocate our default of 1MB heap
    %heapSizePtr = alloca %int
    store %int 0, %pntr %heapSizePtr
    %initHeapSize = load %pntr %heapSizePtr
    %heapSize = add %int %initHeapSize, 1048576
    store %int %heapSize, %pntr @heapSize

    ; stack pointer begins at the end of the heap
    store %int %heapSize, %pntr @stackIdx
    ; execution starts at the beginning of the heap
    store %int 0, %pntr @execIdx

    ; allocate our actual heap
    %heapPtr = alloca %int, %int %heapSize

    ; store the pointer to our heap in a global value
    store %pntr %heapPtr, %pntr* @heapPtr

    ; .s - @DISPSTACK
    %ptr_dispStack = getelementptr [ 3 x i8 ]* @str_dispStack, i32 0
    %i8_dispStack = bitcast [ 3 x i8 ]* %ptr_dispStack to i8*
    %dictEntry.dispStack = alloca %WORD
    call void @registerDictionary( i8* %i8_dispStack, 
                                   %WORD* %dictEntry.dispStack,
                                   %FNPTR @DISPSTACK )

    ; / - @DIV
    %ptr_div = getelementptr [ 2 x i8 ]* @str_div, i32 0
    %i8_div = bitcast [ 2 x i8 ]* %ptr_div to i8*
    %dictEntry.div = alloca %WORD
    call void @registerDictionary( i8* %i8_div, 
                                   %WORD* %dictEntry.div,
                                   %FNPTR @DIV )

    ; * - @MUL
    %ptr_mul = getelementptr [ 2 x i8 ]* @str_mul, i32 0
    %i8_mul = bitcast [ 2 x i8 ]* %ptr_mul to i8*
    %dictEntry.mul = alloca %WORD
    call void @registerDictionary( i8* %i8_mul, 
                                   %WORD* %dictEntry.mul,
                                   %FNPTR @MUL )

    ; - - @SUB
    %ptr_sub = getelementptr [ 2 x i8 ]* @str_sub, i32 0
    %i8_sub = bitcast [ 2 x i8 ]* %ptr_sub to i8*
    %dictEntry.sub = alloca %WORD
    call void @registerDictionary( i8* %i8_sub,  
                                   %WORD* %dictEntry.sub,
                                   %FNPTR @SUB )

    ; + - @ADD
    %ptr_add = getelementptr [ 2 x i8 ]* @str_add, i32 0
    %i8_add = bitcast [ 2 x i8 ]* %ptr_add to i8*
    %dictEntry.add = alloca %WORD
    call void @registerDictionary( i8* %i8_add,  
                                   %WORD* %dictEntry.add,
                                   %FNPTR @ADD )

    ; _lit - @LIT
    %ptr_lit = getelementptr [ 5 x i8 ]* @str_lit, i32 0
    %i8_lit = bitcast [ 5 x i8 ]* %ptr_lit to i8*
    %dictEntry.lit = alloca %WORD
    call void @registerDictionary( i8* %i8_lit,  
                                   %WORD* %dictEntry.lit,
                                   %FNPTR @LIT )

    ; swap - @SWAP
    %ptr_swap = getelementptr [ 5 x i8 ]* @str_swap, i32 0
    %i8_swap = bitcast [ 5 x i8 ]* %ptr_swap to i8*
    %dictEntry.swap = alloca %WORD
    call void @registerDictionary( i8* %i8_swap,  
                                   %WORD* %dictEntry.swap,
                                   %FNPTR @SWAP )

    ; dup - @DUP
    %ptr_dup = getelementptr [ 4 x i8 ]* @str_dup, i32 0
    %i8_dup = bitcast [ 4 x i8 ]* %ptr_dup to i8*
    %dictEntry.dup = alloca %WORD
    call void @registerDictionary( i8* %i8_dup,  
                                   %WORD* %dictEntry.dup,
                                   %FNPTR @DUP )

    ; ** test our dictionary navigation
    call void @printDictionary()

    ; ** compile our forth program
    %ptr_testProgram = getelementptr[ 21 x i8 ]* @str_testProgram, i32 0
    %i8_testProgram = bitcast [ 21 x i8 ]* %ptr_testProgram to i8*
    call void @compile(i8* %i8_testProgram, %int 0)

    ; ** and finally, execute our program
    call void @next()

    call void @repl()

    ret %int 0
}