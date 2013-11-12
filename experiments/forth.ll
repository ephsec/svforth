%pntr = type i64*
%int = type i64
%cell = type i64
;%WORD = type void ()*

%FNPTR = type void ()*
%WORD = type { %pntr, %FNPTR, i8* }

; *****************************************************************************
; stdlib functions
; *****************************************************************************

declare i32 @puts(i8*)
declare i32 @read(%int, i8*, %int)
declare i32 @printf(i8*, ... )

; *****************************************************************************
; for ease of debugging, allows us to print a value to stdout
; *****************************************************************************

@valueString = internal constant [7 x i8] c"%llu\0D\0A\00"
@stackString = internal constant [13 x i8] c"%llu: %llu\0D\0A\00"

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

; *****************************************************************************
; globals used for Forth heap, execution and stack
; *****************************************************************************

@heapPtr = weak global %pntr null 		; pointer to an alloca'ed structure
@dictPtr = weak global %pntr null		; pointer to the last word in the dict
@heapSize = weak global %int 0 			; size of the heap in i8 bytes
@execIdx = weak global %int 0 			; curr exec idx relative to @heapPtr
@stackIdx = weak global %int 0 			; curr stack idx relative to @heapPtr

; * constants containing strings of Forth words
@str_dispStack = internal constant [ 3 x i8 ] c".s\00"
@str_swap =      internal constant [ 5 x i8 ] c"swap\00"
@str_dup =       internal constant [ 4 x i8 ] c"dup\00"
@str_add =       internal constant [ 2 x i8 ] c"+\00"
@str_sub = 		 internal constant [ 2 x i8 ] c"-\00"
@str_mul =       internal constant [ 2 x i8 ] c"*\00"
@str_div =       internal constant [ 2 x i8 ] c"/\00"

; * test forth program
@str_testProgram = internal constant [ 14 x i8 ] c"+ dup swap .s\00"

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
	%ins = call %int @nextExec()

	%is_done = icmp eq %int %ins, 0
	br i1 %is_done, label %done, label %execIns

execIns:
	%functionPtr = inttoptr %int %ins to void ()*
	call void %functionPtr()
	ret void	

done:
	ret void
}

; *** dictionary functions
define void @registerDictionary(i8* %wordString, %FNPTR %wordPtr) {
	%dictPtr = load %pntr* @dictPtr

	%newDictEntry = alloca %WORD
	%newDictEntry.prevEntry = getelementptr %WORD* %newDictEntry, i32 0, i32 0
	%newDictEntry.wordPtr = getelementptr %WORD* %newDictEntry, i32 0, i32 1
	%newDictEntry.wordString = getelementptr %WORD* %newDictEntry, i32 0, i32 2
	store %pntr %dictPtr, %pntr* %newDictEntry.prevEntry
	store %FNPTR %wordPtr, %FNPTR* %newDictEntry.wordPtr
	store i8* %wordString, i8** %newDictEntry.wordString

	ret void
}

; *** compiler functions
define void @compile(i8* %programString, %int %heapIdx) {
	%progStrIdx = alloca i32
	%beginCurrToken = alloca i32
	%currChrPtr = alloca i8

	store i32 0, i32* %progStrIdx

	br label %beginToken

beginToken:
	%progStrIdxValue = load i32* %progStrIdx
	store i32 %progStrIdxValue, i32* %beginCurrToken
	%currChrPtr_beginToken = getelementptr i8* %programString,
										   i32 %progStrIdxValue
	%currChr_beginToken = load i8* %currChrPtr_beginToken
	%is_null = icmp eq i8 %currChr_beginToken, 0
	store i8 %currChr_beginToken, i8* %currChrPtr
	br i1 %is_null, label %done, label %scanSpace

scanSpace:
	%currChr = load i8* %currChrPtr
	%is_space = icmp eq i8 %currChr, 32
	%is_null_scanSpace = icmp eq i8 %currChr, 0
	%is_token = or i1 %is_space, %is_null_scanSpace
	br i1 %is_token, label %handleToken, label %nextChr

nextChr:
	%progStrIdxValue_nextChr = load i32* %progStrIdx
	%newProgStrIdx = add i32 %progStrIdxValue_nextChr, 1
	store i32 %newProgStrIdx, i32* %progStrIdx
	%currChrPtr_nextChr = getelementptr i8* %programString, i32 %newProgStrIdx
	%currChr_nextChr = load i8* %currChrPtr_nextChr
	store i8 %currChr_nextChr, i8* %currChrPtr
	br label %scanSpace

handleToken:
	%progStrIdxValue_handleToken = load i32* %progStrIdx
	%endCurrToken = sub i32 %progStrIdxValue_handleToken, 1
	br label %done

done:
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

define void @SWAP() {
	%first = call %cell @popStack()
	%second = call %cell @popStack()
	call void @pushStack(%cell %first)
	call void @pushStack(%cell %second)
	call void @next()
	ret void
}

define void @DUP() {
	%first = call %cell @getTopStack()
	call void @pushStack(%cell %first)
	call void @next()
	ret void
}

define void @ADD() {
	%first = call %cell @popStack()
	%second = call %cell @popStack()
	%result = add %cell %first, %second
	call void @pushStack(%cell %result)
	call void @next()
	ret void
}

define void @SUB() {
	%first = call %cell @popStack()
	%second = call %cell @popStack()
	%result = sub %cell %second, %first
	call void @pushStack(%cell %result)
	call void @next()
	ret void
}

define void @MUL() {
	%first = call %cell @popStack()
	%second = call %cell @popStack()
	%result = mul %cell %first, %second
	call void @pushStack(%cell %result)
	call void @next()
	ret void
}

define void @DIV() {
	%first = call %cell @popStack()
	%second = call %cell @popStack()
	%result = udiv %cell %second, %first
	call void @pushStack(%cell %result)
	call void @next()
	ret void
}

define void @DISPSTACK() {
	call void @showStack()
	call void @next()
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

	; push 1, 2, 3 onto the stack
	call void @pushStack(%int 1)
	call void @pushStack(%int 2)
	call void @pushStack(%int 3)

	; .s - @DISPSTACK
	%ptr_dispStack = getelementptr [ 3 x i8 ]* @str_dispStack, i32 0
	%i8_dispStack = bitcast [ 3 x i8 ]* %ptr_dispStack to i8*
	call void @registerDictionary( i8* %i8_dispStack, %FNPTR @DISPSTACK )

	; / - @DIV
	%ptr_div = getelementptr [ 2 x i8 ]* @str_div, i32 0
	%i8_div = bitcast [ 2 x i8 ]* %ptr_div to i8*
	call void @registerDictionary( i8* %i8_div, %FNPTR @DIV )

	; * - @MUL
	%ptr_mul = getelementptr [ 2 x i8 ]* @str_mul, i32 0
	%i8_mul = bitcast [ 2 x i8 ]* %ptr_mul to i8*
	call void @registerDictionary( i8* %i8_mul, %FNPTR @MUL )

	; - - @SUB
	%ptr_sub = getelementptr [ 2 x i8 ]* @str_sub, i32 0
	%i8_sub = bitcast [ 2 x i8 ]* %ptr_sub to i8*
	call void @registerDictionary( i8* %i8_sub, %FNPTR @SUB )

	; + - @ADD
	%ptr_add = getelementptr [ 2 x i8 ]* @str_add, i32 0
	%i8_add = bitcast [ 2 x i8 ]* %ptr_add to i8*
	call void @registerDictionary( i8* %i8_add, %FNPTR @ADD )

	; swap - @SWAP
	%ptr_swap = getelementptr [ 5 x i8 ]* @str_swap, i32 0
	%i8_swap = bitcast [ 5 x i8 ]* %ptr_swap to i8*
	call void @registerDictionary( i8* %i8_swap, %FNPTR @SWAP )

	; dup - @DUP
	%ptr_dup = getelementptr [ 4 x i8 ]* @str_dup, i32 0
	%i8_dup = bitcast [ 4 x i8 ]* %ptr_dup to i8*
	call void @registerDictionary( i8* %i8_dup, %FNPTR @DUP )

	; ** compile our forth program
	%ptr_testProgram = getelementptr[ 14 x i8 ]* @str_testProgram, i32 0
	%i8_testProgram = bitcast [ 14 x i8 ]* %ptr_testProgram to i8*


	ret %int 0
}