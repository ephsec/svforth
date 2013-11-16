%pntr = type i64*
%strbuf = type i8*
%cell = type i64
%cell.ptr = type i64*
%exec = type i64
%exec.ptr = type i64*
%ret = type i64
%ret.ptr = type i64*
%int = type i64
%addr = type i64
%addr.ptr = type i64*

@CELLSIZE = weak global %int 8
%FNPTR = type void (%cell.ptr*, %exec.ptr*, %ret.ptr*, %int*)*
%WORD = type { %WORD*, %FNPTR, i8* }

; *****************************************************************************
; stdlib functions
; *****************************************************************************

declare i8 @getchar()
declare i32 @puts(i8*)
declare i32 @read(%int, i8*, %int)
declare i32 @printf(i8*, ... )
declare void @llvm.memcpy.p0i8.p0i8.i32(i8*, i8*, i32, i32, i1)

; below needs to be adjusted to the machine architecutre as appropriate; wrapper
; funciton is called from within the Forth code.
declare {i64, i1} @llvm.uadd.with.overflow.i64(i64 %a, i64 %b)

define {%int, i1} @llvm_ump(%int %first.value, %int %second.value) {
    %res = call {%int, i1} @llvm.uadd.with.overflow.i64(%int %first.value,
                                                        %int %second.value)
    ret {%int, i1} %res
}

; *****************************************************************************
; for ease of debugging, allows us to print a value to stdout
; *****************************************************************************

@valueString = internal constant    [7 x i8]  c"%llu\0D\0A\00"
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
@stackString = internal constant    [14 x i8] c"@%llu: %llu\0D\0A\00"
@SPString = internal constant       [23 x i8] c"SP: @%llu SP0: @%llu\0D\0A\00"
@SPValuesString = internal constant [33 x i8] c"SP: @%llu=%llu SP0: @%llu=%llu\0D\0A\00"
@EIPString = internal constant      [13 x i8] c"EIP: @%llu\0D\0A\00"
@EIPValueString = internal constant [19 x i8] c"EIP: @%llu: %llu\0D\0A\00"
@pushString = internal constant     [17 x i8] c"%llu --> @%llu\0D\0A\00"
@popString = internal constant      [17 x i8] c"@%llu --> %llu\0D\0A\00"

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

define void @printEIPPtr(%cell.ptr* %EIP.ptr.ptr) {
    %string = getelementptr [13 x i8]* @EIPString, i32 0, i32 0
    ; obtain the heap position that EIP is pointing at
    %EIP.ptr = getelementptr %cell.ptr* %EIP.ptr.ptr, i32 0
    %EIP.heap.ptr = load %cell.ptr* %EIP.ptr
    %EIP.heap.addr.ptr = getelementptr %cell.ptr %EIP.heap.ptr, i32 0
    %EIP.heap.addr.int = ptrtoint %cell.ptr %EIP.heap.addr.ptr to %addr

    %printf_ret = call i32 (i8*, ... )* @printf(i8* %string,
                                                %int %EIP.heap.addr.int)    
    ret void
}

define void @printEIPPtrValue(%cell.ptr* %EIP.ptr.ptr) {
    %string = getelementptr [19 x i8]* @EIPValueString, i32 0, i32 0
    ; obtain the heap position that EIP is pointing at
    %EIP.ptr = getelementptr %cell.ptr* %EIP.ptr.ptr, i32 0
    %EIP.heap.ptr = load %cell.ptr* %EIP.ptr
    %EIP.heap.addr.ptr = getelementptr %cell.ptr %EIP.heap.ptr, i32 0
    %EIP.heap.addr.int = ptrtoint %cell.ptr %EIP.heap.addr.ptr to %addr
    %EIP.heap.addr.value = load %cell.ptr %EIP.heap.addr.ptr

    %printf_ret = call i32 (i8*, ... )* @printf(i8* %string,
                                                %int %EIP.heap.addr.int,
                                                %int %EIP.heap.addr.value)    
    ret void
}

define void @printStackPtrs(%cell.ptr* %SP.ptr.ptr) {
    %string = getelementptr [23 x i8]* @SPString, i32 0, i32 0
    ; obtain the stack position that SP is pointing at
    %SP.ptr = getelementptr %cell.ptr* %SP.ptr.ptr, i32 0
    %SP.stack.ptr = load %cell.ptr* %SP.ptr
    %SP.stack.addr.ptr = getelementptr %cell.ptr %SP.stack.ptr, i32 0
    %SP.stack.addr.int = ptrtoint %cell.ptr %SP.stack.addr.ptr to %addr
    ; obtain the stack position that SP0 is pointing at
    %SP0.stack.ptr = load %cell.ptr* @SP0
    %SP0.stack.addr.ptr = getelementptr %addr.ptr %SP0.stack.ptr, i32 0
    %SP0.stack.addr.int = ptrtoint %addr.ptr %SP0.stack.addr.ptr to %addr

    %printf_ret = call i32 (i8*, ... )* @printf(i8* %string,
                                                %int %SP.stack.addr.int, 
                                                %int %SP0.stack.addr.int)    
    ret void
}

define void @printStackPtrValues(%cell.ptr* %SP.ptr.ptr) {
    %string = getelementptr [33 x i8]* @SPValuesString, i32 0, i32 0
    ; obtain the stack position that SP is pointing at
    %SP.ptr = getelementptr %cell.ptr* %SP.ptr.ptr, i32 0
    %SP.stack.ptr = load %cell.ptr* %SP.ptr
    %SP.stack.addr.ptr = getelementptr %cell.ptr %SP.stack.ptr, i32 0
    %SP.stack.addr.int = ptrtoint %cell.ptr %SP.stack.addr.ptr to %addr
    %SP.stack.addr.value = load %cell.ptr %SP.stack.addr.ptr
    ; obtain the stack position that SP0 is pointing at
    %SP0.stack.ptr = load %cell.ptr* @SP0
    %SP0.stack.addr.ptr = getelementptr %addr.ptr %SP0.stack.ptr, i32 0
    %SP0.stack.addr.int = ptrtoint %addr.ptr %SP0.stack.addr.ptr to %addr
    %SP0.stack.addr.value = load %cell.ptr %SP0.stack.addr.ptr

    %printf_ret = call i32 (i8*, ... )* @printf(i8* %string,
                                                %int %SP.stack.addr.int, 
                                                %int %SP.stack.addr.value,
                                                %int %SP0.stack.addr.int,
                                                %int %SP0.stack.addr.value)    
    ret void
}

define cc 10 void @printStackPop(%int %addr, %int %value) {
    %string = getelementptr [17 x i8]* @popString, i32 0, i32 0
    %printf_ret = call i32 (i8*, ... )* @printf(i8* %string,
                                                %int %addr, %int %value)
    ret void
}

define cc 10 void @printStackPush(%int %addr, %int %value) {
    %string = getelementptr [17 x i8]* @pushString, i32 0, i32 0
    %printf_ret = call i32 (i8*, ... )* @printf(i8* %string,
                                                %int %value, %int %addr)
    ret void
}

; *****************************************************************************
; globals used for Forth heap, execution and stack
; *****************************************************************************

@SP0 = weak global %cell.ptr null
@HEAP = weak global %cell.ptr null

@dictPtr = weak global %WORD* null      ; pointer to the last word in the dict
@heapSize = weak global %int 0          ; size of the heap in i8 bytes

; * constants containing strings of Forth words
@str_dispStack = internal constant [ 3 x i8 ] c".s\00"
@str_c_at =      internal constant [ 3 x i8 ] c"C@\00"
@str_c_bang =    internal constant [ 3 x i8 ] c"C!\00"
@str_sp_at =     internal constant [ 4 x i8 ] c"SP@\00"
@str_sp_bang =   internal constant [ 4 x i8 ] c"SP!\00"
@str_swap =      internal constant [ 5 x i8 ] c"SWAP\00"
@str_dup =       internal constant [ 4 x i8 ] c"DUP\00"
@str_drop =      internal constant [ 5 x i8 ] c"DROP\00"
@str_over =      internal constant [ 5 x i8 ] c"OVER\00"
@str_umplus =    internal constant [ 4 x i8 ] c"UM+\00"
@str_add =       internal constant [ 2 x i8 ] c"+\00"
@str_sub =       internal constant [ 2 x i8 ] c"-\00"
@str_mul =       internal constant [ 2 x i8 ] c"*\00"
@str_div =       internal constant [ 2 x i8 ] c"/\00"
@str_lit =       internal constant [ 5 x i8 ] c"_LIT\00"
@str_char_min =  internal constant [ 6 x i8 ] c"CHAR-\00"
@str_char_plus = internal constant [ 6 x i8 ] c"CHAR+\00"
@str_chars =     internal constant [ 6 x i8 ] c"CHARS\00"
@str_cell_min =  internal constant [ 6 x i8 ] c"CELL-\00"
@str_cell_plus = internal constant [ 6 x i8 ] c"CELL+\00"
@str_cells =     internal constant [ 6 x i8 ] c"CELLS\00"
@str_nonzero =   internal constant [ 3 x i8 ] c"0<\00"
@str_and =       internal constant [ 4 x i8 ] c"AND\00"
@str_or =        internal constant [ 3 x i8 ] c"OR\00"
@str_xor =       internal constant [ 4 x i8 ] c"XOR\00"

; * test forth program
@str_testProgram = internal constant [ 21 x i8 ] c"99 2 3 DUP + SWAP .s\00"

; **** heap access and manipulation functions
define fastcc %pntr @getHeap_ptr(%int %index) {
    ; load our heap pointer, which is stored as a pointer
    %heapPtr = load %pntr* @HEAP
    ; retrieve and return our value pointer
    %valuePtr = getelementptr %pntr %heapPtr, %int %index
    ret %pntr %valuePtr
}

define fastcc %int @getHeap(%int %index) {
    %valuePtr = call fastcc %pntr @getHeap_ptr(%int %index)
    %value = load %pntr %valuePtr
    ret %int %value
}

define fastcc void @putHeap(%int %index, %int %value) {
    %valuePtr = call fastcc %pntr @getHeap_ptr(%int %index)
    store %int %value, %pntr %valuePtr
    ret void
}

define fastcc void @insertToken(%int %index, %FNPTR %token) {
    %insPtr = call fastcc %pntr @getHeap_ptr(%int %index)
    %tokenPtrInt = ptrtoint %FNPTR %token to %int
    call fastcc void @putHeap(%int %index, %int %tokenPtrInt)
    ret void
}

define fastcc void @insertLiteral(%int %index, %int %value) {
    %insPtr = call fastcc %pntr @getHeap_ptr(%int %index)
    call fastcc void @putHeap(%int %index, %int %value)
    ret void
}

; ****************************************************************************
; stack manipulation functions
; ****************************************************************************

;   SP!                         ( n -- ) r4: n
define cc 10 void @_SP_POP(%cell.ptr* %SP.ptr.ptr, %exec.ptr* %EIP.ptr.ptr,
                           %ret.ptr* %RSP.ptr.ptr, %cell* %DATA.ptr) {

    %SP.next.ptr.int.ptr = alloca %addr
    ; obtain the stack value that SP is pointing at
    call cc 10 void @_SP_PEEK(%cell.ptr* %SP.ptr.ptr, %exec.ptr* %EIP.ptr.ptr,
                           %ret.ptr* %RSP.ptr.ptr, %cell* %DATA.ptr)
    ; decrement our stack pointer now that we've obtained our value
    call cc 10 void @_SP_INCR(%cell.ptr* %SP.ptr.ptr, %exec.ptr* %EIP.ptr.ptr,
                           %ret.ptr* %RSP.ptr.ptr, %addr* %SP.next.ptr.int.ptr)

    ; report the pop
    %SP.next.ptr.int = load %addr* %SP.next.ptr.int.ptr
    %DATA.value = load %cell* %DATA.ptr
    ;call cc 10 void @printStackPop(%addr %SP.next.ptr.int, %cell %DATA.value)

    ret void
}

;    DUP                         ( n -- n n )
define cc 10 void @_SP_DUP(%cell.ptr* %SP.ptr.ptr, %exec.ptr* %EIP.ptr.ptr,
                            %ret.ptr* %RSP.ptr.ptr, %cell* %DATA.ptr) {

    %value.ptr = alloca %cell
    ; obtain the stack value that SP is pointing at
    call cc 10 void @_SP_PEEK(%cell.ptr* %SP.ptr.ptr, %exec.ptr* %EIP.ptr.ptr,
                           %ret.ptr* %RSP.ptr.ptr, %cell* %value.ptr)
    ; push a duplicate of the value onto the stack
    call cc 10 void @_SP_PUSH(%cell.ptr* %SP.ptr.ptr, %exec.ptr* %EIP.ptr.ptr,
                           %ret.ptr* %RSP.ptr.ptr, %cell* %value.ptr)

    ret void
}

;   PUSH                        ( -- n )
define cc 10 void @_SP_PUSH(%cell.ptr* %SP.ptr.ptr, %exec.ptr* %EIP.ptr.ptr,
                        %ret.ptr* %RSP.ptr.ptr, %cell* %DATA.ptr) {

    %SP.next.ptr.int.ptr = alloca %addr
    %DATA.value = load %cell* %DATA.ptr

    call cc 10 void @_SP_DECR(%cell.ptr* %SP.ptr.ptr, %exec.ptr* %EIP.ptr.ptr,
                          %ret.ptr* %RSP.ptr.ptr, %addr* %SP.next.ptr.int.ptr )

    %SP.next.ptr.int = load %addr* %SP.next.ptr.int.ptr
    %SP.next.ptr = inttoptr %addr %SP.next.ptr.int to %addr*

    ; store our value at the new stack position
    store %cell %DATA.value, %cell.ptr %SP.next.ptr

    ;call cc 10 void @printStackPush(%addr %SP.next.ptr.int, %cell %DATA.value)

    ret void
}

;   SP@                         ( -- a )
;   INTERNAL: push the stack position onto the stack

define cc 10 void @_SP_AT(%cell.ptr* %SP.ptr.ptr, %exec.ptr* %EIP.ptr.ptr,
                          %ret.ptr* %RSP.ptr.ptr, %cell* %DATA.ptr) {

    ; obtain the stack position that SP is pointing at
    %SP.ptr = getelementptr %cell.ptr* %SP.ptr.ptr, i32 0
    %value.ptr = load %cell.ptr* %SP.ptr
    %value.cell.ptr = getelementptr %cell.ptr %value.ptr, i32 0
    %SP.ptr.int = ptrtoint %cell.ptr %value.cell.ptr to %addr
    store %addr %SP.ptr.int, %addr* %DATA.ptr

    call cc 10 void @_SP_PUSH(%cell.ptr* %SP.ptr.ptr, %exec.ptr* %EIP.ptr.ptr,
                           %ret.ptr* %RSP.ptr.ptr, %addr* %DATA.ptr)

    ret void
}

;   SWAP                        ( n1 n2 -- n2 n1 )
;   INTERNAL: swap the topmost two elements of the stack
define cc 10 void @_SP_SWAP(%cell.ptr* %SP.ptr.ptr, %exec.ptr* %EIP.ptr.ptr,
                           %ret.ptr* %RSP.ptr.ptr) {
    %first.ptr = alloca %cell
    %second.ptr = alloca %cell
    call cc 10 void @_SP_POP(%cell.ptr* %SP.ptr.ptr, %exec.ptr* %EIP.ptr.ptr,
                           %ret.ptr* %RSP.ptr.ptr, %cell* %first.ptr)
    call cc 10 void @_SP_POP(%cell.ptr* %SP.ptr.ptr, %exec.ptr* %EIP.ptr.ptr,
                           %ret.ptr* %RSP.ptr.ptr, %cell* %second.ptr)
    call cc 10 void @_SP_PUSH(%cell.ptr* %SP.ptr.ptr, %exec.ptr* %EIP.ptr.ptr,
                           %ret.ptr* %RSP.ptr.ptr, %cell* %first.ptr)
    call cc 10 void @_SP_PUSH(%cell.ptr* %SP.ptr.ptr, %exec.ptr* %EIP.ptr.ptr,
                           %ret.ptr* %RSP.ptr.ptr, %cell* %second.ptr)
    ret void
}

;   OVER                        ( n1 n2 -- n1 n2 n1 )
;   INTERNAL: copy the second value on the stack into the front of the stack
define cc 10 void @_SP_OVER(%cell.ptr* %SP.ptr.ptr, %exec.ptr* %EIP.ptr.ptr,
                           %ret.ptr* %RSP.ptr.ptr) {
    %first.ptr = alloca %cell
    %second.ptr = alloca %cell
    call cc 10 void @_SP_POP(%cell.ptr* %SP.ptr.ptr, %exec.ptr* %EIP.ptr.ptr,
                           %ret.ptr* %RSP.ptr.ptr, %cell* %first.ptr)
    call cc 10 void @_SP_POP(%cell.ptr* %SP.ptr.ptr, %exec.ptr* %EIP.ptr.ptr,
                           %ret.ptr* %RSP.ptr.ptr, %cell* %second.ptr)
    call cc 10 void @_SP_PUSH(%cell.ptr* %SP.ptr.ptr, %exec.ptr* %EIP.ptr.ptr,
                           %ret.ptr* %RSP.ptr.ptr, %cell* %second.ptr)
    call cc 10 void @_SP_PUSH(%cell.ptr* %SP.ptr.ptr, %exec.ptr* %EIP.ptr.ptr,
                           %ret.ptr* %RSP.ptr.ptr, %cell* %first.ptr)
    call cc 10 void @_SP_PUSH(%cell.ptr* %SP.ptr.ptr, %exec.ptr* %EIP.ptr.ptr,
                           %ret.ptr* %RSP.ptr.ptr, %cell* %second.ptr)
    ret void
}

;   PEEK                        ( n -- n ) r4: n
;   INTERNAL: return the value under the stack pointer in r4
define cc 10 void @_SP_PEEK(%cell.ptr* %SP.ptr.ptr, %exec.ptr* %EIP.ptr.ptr,
                           %ret.ptr* %RSP.ptr.ptr, %cell* %DATA.ptr) {
    ; obtain the stack value that SP is pointing at
    %SP.ptr = getelementptr %cell.ptr* %SP.ptr.ptr, i32 0
    %value.ptr = load %cell.ptr* %SP.ptr
    %value.cell.ptr = getelementptr %cell.ptr %value.ptr, i32 0
    %value.cell.ptr.int = ptrtoint %cell.ptr %value.cell.ptr to %int
    ; grab the current value under the stack pointer
    %value.cell = load %cell* %value.cell.ptr
    store %cell %value.cell, %cell* %DATA.ptr

    ret void
}

;   DROP                        ( n -- )
;   INTERNAL: increment the stack pointer, which has a side effect of DROP
define cc 10 void @_SP_INCR(%cell.ptr* %SP.ptr.ptr, %exec.ptr* %EIP.ptr.ptr,
                           %ret.ptr* %RSP.ptr.ptr, %cell* %DATA.ptr) {
    ; obtain the stack position that SP is pointing at
    %SP.ptr = getelementptr %cell.ptr* %SP.ptr.ptr, i32 0
    %value.ptr = load %cell.ptr* %SP.ptr
    %value.cell.ptr = getelementptr %cell.ptr %value.ptr, i32 0

    ; increment SP
    %SP.ptr.int = ptrtoint %cell.ptr %value.cell.ptr to %addr
    %SP.next.ptr.int = add %addr %SP.ptr.int, 8
    %SP.next.ptr = inttoptr %addr %SP.next.ptr.int to %cell.ptr

    ; finalize our new state
    store %cell %SP.next.ptr.int, %cell* %DATA.ptr
    store %cell.ptr %SP.next.ptr, %cell.ptr* %SP.ptr.ptr

    ret void
}

;   INTERNAL: decrement the stack pointer
define cc 10 void @_SP_DECR(%cell.ptr* %SP.ptr.ptr, %exec.ptr* %EIP.ptr.ptr,
                           %ret.ptr* %RSP.ptr.ptr, %cell* %DATA.ptr) {
    ; obtain the stack position that SP is pointing at
    %SP.ptr = getelementptr %cell.ptr* %SP.ptr.ptr, i32 0
    %value.ptr = load %cell.ptr* %SP.ptr
    %value.cell.ptr = getelementptr %cell.ptr %value.ptr, i32 0

    ; decrement SP
    %SP.ptr.int = ptrtoint %cell.ptr %value.cell.ptr to %addr
    %SP.next.ptr.int = sub %addr %SP.ptr.int, 8
    %SP.next.ptr = inttoptr %addr %SP.next.ptr.int to %cell.ptr
    ;call void @printValueInt( %addr %SP.next.ptr.int )

    ; finalize our new state
    store %cell %SP.next.ptr.int, %cell* %DATA.ptr
    store %cell.ptr %SP.next.ptr, %cell.ptr* %SP.ptr.ptr

    ret void
}

; ****************************************************************************
; Memory access functions
; ****************************************************************************

; C!                          ( c a -- ) 
define cc 10 void @_C_BANG(%cell.ptr* %SP.ptr.ptr, %exec.ptr* %EIP.ptr.ptr,
                         %ret.ptr* %RSP.ptr.ptr) {
    %address.cell.ptr = alloca %cell
    %value.cell.ptr   = alloca %cell

    call cc 10 void @_SP_POP(%cell.ptr* %SP.ptr.ptr, %exec.ptr* %EIP.ptr.ptr,
                           %ret.ptr* %RSP.ptr.ptr, %cell* %address.cell.ptr)
    call cc 10 void @_SP_POP(%cell.ptr* %SP.ptr.ptr, %exec.ptr* %EIP.ptr.ptr,
                           %ret.ptr* %RSP.ptr.ptr, %cell* %value.cell.ptr)

    %address.cell = load %cell* %address.cell.ptr
    %value.cell = load %cell* %value.cell.ptr
    %address.ptr = inttoptr %cell %address.cell to %cell*
    store %cell %value.cell, %cell* %address.ptr

    ret void
}

; C@                          ( a -- c )
define cc 10 void @_C_AT(%cell.ptr* %SP.ptr.ptr, %exec.ptr* %EIP.ptr.ptr,
                         %ret.ptr* %RSP.ptr.ptr) {
    %address.cell.ptr = alloca %cell
    %value.cell.ptr =   alloca %cell

    call cc 10 void @_SP_POP(%cell.ptr* %SP.ptr.ptr, %exec.ptr* %EIP.ptr.ptr,
                             %ret.ptr* %RSP.ptr.ptr, %cell* %address.cell.ptr)

    %address.cell = load %cell* %address.cell.ptr
    %address.ptr = inttoptr %cell %address.cell to %addr*
    %retrieve.cell = load %cell* %address.ptr
    store %cell %retrieve.cell, %cell* %value.cell.ptr

    call cc 10 void @_SP_PUSH(%cell.ptr* %SP.ptr.ptr, %exec.ptr* %EIP.ptr.ptr,
                              %ret.ptr* %RSP.ptr.ptr, %cell* %value.cell.ptr)

    ret void
}


; ****************************************************************************
; Execution loop functions
; ****************************************************************************

define cc 10 void @_EIP_INCR(%cell.ptr* %SP.ptr.ptr, %exec.ptr* %EIP.ptr.ptr,
                             %ret.ptr* %RSP.ptr.ptr) {
    ; resolve our current EIP
    %EIP.ptr = getelementptr %exec.ptr* %EIP.ptr.ptr, i32 0
    %EIP.value.ptr = load %exec.ptr* %EIP.ptr
    %EIP.exec.ptr = getelementptr %exec.ptr %EIP.value.ptr, i32 0

    ; increment EIP
    %EIP.ptr.int = ptrtoint %exec.ptr %EIP.exec.ptr to %addr
    %EIP.next.ptr.int = add %addr %EIP.ptr.int, 8
    %EIP.next.ptr = inttoptr %addr %EIP.next.ptr.int to %exec.ptr

    ; finalize our new state
    store %exec.ptr %EIP.next.ptr, %exec.ptr* %EIP.ptr.ptr

    ret void
}

define cc 10 void @_EIP_NEXT(%cell.ptr* %SP.ptr.ptr, %exec.ptr* %EIP.ptr.ptr,
                             %ret.ptr* %RSP.ptr.ptr, %int* %DATA.ptr) {

    ; obtain the data that the EIP is pointing at
    %EIP.ptr = getelementptr %exec.ptr* %EIP.ptr.ptr, i32 0
    %EIP.ins.ptr.ptr = load %exec.ptr* %EIP.ptr
    %EIP.ins.ptr = getelementptr %exec.ptr %EIP.ins.ptr.ptr, i32 0
    %EIP.ins = load %exec.ptr %EIP.ins.ptr

    ; increment our EIP now that we've got our data
    call cc 10 void @_EIP_INCR(%cell.ptr* %SP.ptr.ptr, %exec.ptr* %EIP.ptr.ptr,
                         %ret.ptr* %RSP.ptr.ptr)

    ; finalize our state and return our instruction
    store %exec %EIP.ins, %int* %DATA.ptr

    ret void
}

define cc 10 void @_EIP_PEEK(%cell.ptr* %SP.ptr.ptr, %exec.ptr* %EIP.ptr.ptr,
                             %ret.ptr* %RSP.ptr.ptr, %addr* %DATA.ptr) {
    ; obtain the data that the EIP is pointing at
    %EIP.ptr = getelementptr %exec.ptr* %EIP.ptr.ptr, i32 0
    %EIP.ins.ptr.ptr = load %exec.ptr* %EIP.ptr
    %EIP.ins.ptr = getelementptr %exec.ptr %EIP.ins.ptr.ptr, i32 0
    %EIP.ins = load %exec.ptr %EIP.ins.ptr

    ; finalize our state and return our instruction
    store %exec %EIP.ins, %int* %DATA.ptr

    ret void
}

define cc 10 void @_EIP_JMP(%cell.ptr* %SP.ptr.ptr, %exec.ptr* %EIP.ptr.ptr,
                        %ret.ptr* %RSP.ptr.ptr, %addr* %DATA.ptr) {
    %EIP.new = load %addr* %DATA.ptr
    %EIP.new.ptr = inttoptr %addr %EIP.new to %exec.ptr

    ; store the new EIP
    %EIP.ptr = getelementptr %exec.ptr* %EIP.ptr.ptr, i32 0
    %EIP.ins.ptr.ptr = load %exec.ptr* %EIP.ptr
    %EIP.ins.ptr = getelementptr %exec.ptr %EIP.ins.ptr.ptr, i32 0
    store %exec.ptr %EIP.new.ptr, %exec.ptr* %EIP.ptr.ptr

    ; execute our new instruction under the EIP
    call cc 10 void @next(%cell.ptr* %SP.ptr.ptr, %exec.ptr* %EIP.ptr.ptr,
                          %ret.ptr* %RSP.ptr.ptr, %addr* %DATA.ptr) noreturn

    ret void
}

define cc 10 void @_EIP_EXEC(%cell.ptr* %SP.ptr.ptr, %exec.ptr* %EIP.ptr.ptr,
                             %ret.ptr* %RSP.ptr.ptr, %addr* %DATA.ptr) {
    ; obtain the data that the EIP is pointing at
    %EIP.ptr = getelementptr %exec.ptr* %EIP.ptr.ptr, i32 0
    %EIP.ins.ptr.ptr = load %exec.ptr* %EIP.ptr
    %EIP.ins.ptr = getelementptr %exec.ptr %EIP.ins.ptr.ptr, i32 0
    %EIP.ins = load %exec.ptr %EIP.ins.ptr

    ; resolve and execute our instruction under the EIP
    %functionPtr = inttoptr %int %EIP.ins to void (%cell.ptr*,
        %exec.ptr*, %ret.ptr*, %int*)*
    call void %functionPtr(%cell.ptr* %SP.ptr.ptr, %exec.ptr* %EIP.ptr.ptr,
                           %ret.ptr* %RSP.ptr.ptr, %int* %DATA.ptr) noreturn

    ret void
}

define cc 10 void @next(%cell.ptr* %SP.ptr.ptr, %exec.ptr* %EIP.ptr.ptr,
                        %ret.ptr* %RSP.ptr.ptr, %int* %DATA.ptr) {
    ; c"EXEC:"
    %execString = getelementptr [6 x i8]* @execString, i32 0, i32 0
    %nxtIns.ptr = alloca %int
    call cc 10 void @_EIP_PEEK(%cell.ptr* %SP.ptr.ptr, %exec.ptr* %EIP.ptr.ptr,
                               %ret.ptr* %RSP.ptr.ptr, %addr* %nxtIns.ptr)
    call cc 10 void @_EIP_INCR(%cell.ptr* %SP.ptr.ptr, %exec.ptr* %EIP.ptr.ptr,
                               %ret.ptr* %RSP.ptr.ptr)
    %nxtIns.value = load %int* %nxtIns.ptr

    %is_done.flag = icmp eq %int %nxtIns.value, 0
    br i1 %is_done.flag, label %done, label %execIns

execIns:
    %functionPtr = inttoptr %int %nxtIns.value to void (%cell.ptr*,
        %exec.ptr*, %ret.ptr*, %int*)*
    call void %functionPtr(%cell.ptr* %SP.ptr.ptr, %exec.ptr* %EIP.ptr.ptr,
                           %ret.ptr* %RSP.ptr.ptr, %int* %DATA.ptr) noreturn
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
    %forthFn.ptr = load %FNPTR* %forthFn.ptr.ptr
    %forthFn.ptr.int = ptrtoint %FNPTR %forthFn.ptr to %int

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
    %currFn.ptr = load %FNPTR* %currFn.ptr.ptr
    %currFn.ptr.value = ptrtoint %FNPTR %currFn.ptr to %int

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
    %forthFn.ptr = call %FNPTR (i8*)* @lookupDictionary(i8* %currToken.ptr)

    ; load our current heap index for inserting a pointer or a literal
    %currHeapIdx.value = load %int* %currHeapIdx.ptr

    ; check if we have a function pointer, or a null pointer
    %is_fnPtr_null = icmp eq %FNPTR %forthFn.ptr, null
    br i1 %is_fnPtr_null, label %checkLiteral, label %insertFn

insertFn:
    ; insert our function pointer into our heap
    call fastcc void @insertToken(%int %currHeapIdx.value, %FNPTR %forthFn.ptr)

    ; advance our local heap index now that we've inserted a token
    %newHeapIdx.value = add %int %currHeapIdx.value, 1
    store %int %newHeapIdx.value, %int* %currHeapIdx.ptr

    ; show that we've 'compiled' a token
    call void @printTwoString(i8* %compiledString.ptr, i8* %currToken.ptr)

    ; all done with the token, let's move on
    br label %checkTokenEndNull

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
    call fastcc void @insertToken(%int %currHeapIdx.value, %FNPTR @_LIT)
    %newHeapIdx.value.insertLiteral = add %int %currHeapIdx.value, 1

    ; Now that we have our constructed literal, insert it into the heap
    call fastcc void @insertLiteral(%int %newHeapIdx.value.insertLiteral,
                                   %int %newLiteralInt.value)

    ; report our new literal to the user
    call void @printTwoString(i8* %literalString.ptr, i8* %currToken.ptr)

    ; Finally, increment and store our current heap pointer.
    %storeHeapIdx.value = add %int %newHeapIdx.value.insertLiteral, 1
    store %int %storeHeapIdx.value, %pntr %currHeapIdx.ptr

    br label %checkTokenEndNull

checkTokenEndNull:
    ; we check if the terminator on our current token is null, as that'stack
    ; a string and compilation ending moment as well
    %endTokenChr.ptr = getelementptr i8* %programString.ptr,
                                    i32 %progStrIdx.value.handleToken
    %endTokenChr.value = load i8* %endTokenChr.ptr
    %is_chr_null.flag = icmp eq i8 %endTokenChr.value, 0

    br i1 %is_chr_null.flag, label %done, label %advanceIdx

advanceIdx:
    ; advance past the space we're hovering over at present
    %nextProgStrIdx.value.advanceIdx = add i32 %progStrIdx.value.handleToken, 1
    store i32 %nextProgStrIdx.value.advanceIdx, i32* %progStrIdx.ptr

    ; begin all over again
    br label %beginToken

invalidLiteral:
    br label %done

done:
    %currHeapIdx.value.done = load %pntr %currHeapIdx.ptr
    ;call void @printValueInt( %int %currHeapIdx.value.done )

    ; clean up by terminating our compiled output with a null byte
    call fastcc void @insertLiteral(%int %currHeapIdx.value.done,
                             %int 00)

    ret void
}

; *****************************************************************************
; utility routine to show the current contents of our stack
; *****************************************************************************

define cc 10 void @showStack(%cell.ptr* %SP.ptr.ptr, %exec.ptr* %EIP.ptr.ptr,
                             %ret.ptr* %RSP.ptr.ptr, %int* %DATA.ptr) {
    %stack_string = getelementptr [14 x i8]* @stackString, i64 0, i64 0

    ; obtain the address of the bottom of our stack
    %SP0.stack.ptr = load %cell.ptr* @SP0
    %SP0.stack.addr.ptr = getelementptr %addr.ptr %SP0.stack.ptr, i32 0
    %SP0.addr = ptrtoint %addr.ptr %SP0.stack.addr.ptr to %addr

    %null.ptr = alloca %cell
    %SSP.addr.ptr = alloca %addr 
    %cell.value.ptr = alloca %cell

    ; obtain the stack position that SP is pointing at
    ; SP@ -> stack
    call cc 10 void @_SP_AT(%cell.ptr* %SP.ptr.ptr, %exec.ptr* %EIP.ptr.ptr,
                            %ret.ptr* %RSP.ptr.ptr, %int* %null.ptr)

    ; POP -> %SP.addr
    call cc 10 void @_SP_POP(%cell.ptr* %SP.ptr.ptr, %exec.ptr* %EIP.ptr.ptr,
                             %ret.ptr* %RSP.ptr.ptr, %int* %SSP.addr.ptr)

    ; kick off the loop
    br label %loop

loop:
    %SSP.addr = load %addr* %SSP.addr.ptr
    %is_done.flag = icmp eq %int %SSP.addr, %SP0.addr
    br i1 %is_done.flag, label %done, label %continue_loop

continue_loop:
    ; push our current show stack address onto the stack
    call cc 10 void @_SP_PUSH(%cell.ptr* %SP.ptr.ptr, %exec.ptr* %EIP.ptr.ptr,
                              %ret.ptr* %RSP.ptr.ptr, %int* %SSP.addr.ptr)

    ; resolve the memory location and retrieve the item onto the stack
    call cc 10 void @_C_AT(%cell.ptr* %SP.ptr.ptr, %exec.ptr* %EIP.ptr.ptr,
                           %ret.ptr* %RSP.ptr.ptr)

    ; pop the memory cell we just retrieved into our cell value pointer
    call cc 10 void @_SP_POP(%cell.ptr* %SP.ptr.ptr, %exec.ptr* %EIP.ptr.ptr,
                             %ret.ptr* %RSP.ptr.ptr, %int* %cell.value.ptr)

    ; report our current stack address and item
    %cell.value = load %cell* %cell.value.ptr
    %printf_ret = call i32 (i8*, ... )* @printf(i8* %stack_string,
                                                %int %SSP.addr, 
                                                %int %cell.value)

    ; increment and store our new stack location, starting the loop again
    %SSP.new.value = add %int %SSP.addr, 8
    store %int %SSP.new.value, %addr.ptr %SSP.addr.ptr
    br label %loop

done:
    ret void
}

; *****************************************************************************
; here be FORTH words now
; *****************************************************************************

define cc 10 void @_LIT(%cell.ptr* %SP.ptr.ptr, %exec.ptr* %EIP.ptr.ptr,
                        %ret.ptr* %RSP.ptr.ptr, %int* %DATA.ptr) noreturn {
    ; get the value under our EIP
    %nullValue.ptr = alloca %cell
    %litValue.ptr = alloca %cell
    call cc 10 void @_EIP_PEEK(%cell.ptr* %SP.ptr.ptr, %exec.ptr* %EIP.ptr.ptr,
                               %ret.ptr* %RSP.ptr.ptr, %addr* %litValue.ptr)
    ; push it onto our stack
    call cc 10 void @_SP_PUSH(%cell.ptr* %SP.ptr.ptr, %exec.ptr* %EIP.ptr.ptr,
                              %ret.ptr* %RSP.ptr.ptr, %int* %litValue.ptr)
    ; advance our EIP now
    call cc 10 void @_EIP_INCR(%cell.ptr* %SP.ptr.ptr, %exec.ptr* %EIP.ptr.ptr,
                               %ret.ptr* %RSP.ptr.ptr)
    call cc 10 void @next(%cell.ptr* %SP.ptr.ptr, %exec.ptr* %EIP.ptr.ptr,
                           %ret.ptr* %RSP.ptr.ptr, %int* %DATA.ptr) noreturn

    ret void
}

define cc 10 void @SWAP(%cell.ptr* %SP.ptr.ptr, %exec.ptr* %EIP.ptr.ptr,
                        %ret.ptr* %RSP.ptr.ptr, %int* %DATA.ptr) noreturn {
    ; call the intrinsic SWAP
    call cc 10 void @_SP_SWAP(%cell.ptr* %SP.ptr.ptr, %exec.ptr* %EIP.ptr.ptr,
                              %ret.ptr* %RSP.ptr.ptr)
    call cc 10 void @next(%cell.ptr* %SP.ptr.ptr, %exec.ptr* %EIP.ptr.ptr,
                           %ret.ptr* %RSP.ptr.ptr, %int* %DATA.ptr) noreturn

    ret void
}

define cc 10 void @DUP(%cell.ptr* %SP.ptr.ptr, %exec.ptr* %EIP.ptr.ptr,
                       %ret.ptr* %RSP.ptr.ptr, %int* %DATA.ptr) noreturn {
    ; call the intrinsic DUP
    call cc 10 void @_SP_DUP(%cell.ptr* %SP.ptr.ptr, %exec.ptr* %EIP.ptr.ptr,
                              %ret.ptr* %RSP.ptr.ptr, %int* %DATA.ptr)
    call cc 10 void @next(%cell.ptr* %SP.ptr.ptr, %exec.ptr* %EIP.ptr.ptr,
                           %ret.ptr* %RSP.ptr.ptr, %int* %DATA.ptr) noreturn

    ret void
}

define cc 10 void @DROP(%cell.ptr* %SP.ptr.ptr, %exec.ptr* %EIP.ptr.ptr,
                       %ret.ptr* %RSP.ptr.ptr, %int* %DATA.ptr) noreturn {
    ; call the intrinsic increment stack operator, to 'drop' the current item
    call cc 10 void @_SP_INCR(%cell.ptr* %SP.ptr.ptr, %exec.ptr* %EIP.ptr.ptr,
                              %ret.ptr* %RSP.ptr.ptr, %int* %DATA.ptr)
    call cc 10 void @next(%cell.ptr* %SP.ptr.ptr, %exec.ptr* %EIP.ptr.ptr,
                           %ret.ptr* %RSP.ptr.ptr, %int* %DATA.ptr) noreturn

    ret void
}

define cc 10 void @C_AT(%cell.ptr* %SP.ptr.ptr, %exec.ptr* %EIP.ptr.ptr,
                        %ret.ptr* %RSP.ptr.ptr, %int* %DATA.ptr) noreturn {
    ; call the intrinsic operator
    call cc 10 void @_C_AT(%cell.ptr* %SP.ptr.ptr, %exec.ptr* %EIP.ptr.ptr,
                           %ret.ptr* %RSP.ptr.ptr)
    call cc 10 void @next(%cell.ptr* %SP.ptr.ptr, %exec.ptr* %EIP.ptr.ptr,
                           %ret.ptr* %RSP.ptr.ptr, %int* %DATA.ptr) noreturn

    ret void
}

define cc 10 void @C_BANG(%cell.ptr* %SP.ptr.ptr, %exec.ptr* %EIP.ptr.ptr,
                          %ret.ptr* %RSP.ptr.ptr, %int* %DATA.ptr) noreturn {
    ; call the intrinsic operator
    call cc 10 void @_C_BANG(%cell.ptr* %SP.ptr.ptr, %exec.ptr* %EIP.ptr.ptr,
                             %ret.ptr* %RSP.ptr.ptr)
    call cc 10 void @next(%cell.ptr* %SP.ptr.ptr, %exec.ptr* %EIP.ptr.ptr,
                           %ret.ptr* %RSP.ptr.ptr, %int* %DATA.ptr) noreturn

    ret void
}

define cc 10 void @SP_AT(%cell.ptr* %SP.ptr.ptr, %exec.ptr* %EIP.ptr.ptr,
                        %ret.ptr* %RSP.ptr.ptr, %int* %DATA.ptr) noreturn {
    ; call the intrinsic operator
    call cc 10 void @_SP_AT(%cell.ptr* %SP.ptr.ptr, %exec.ptr* %EIP.ptr.ptr,
                           %ret.ptr* %RSP.ptr.ptr, %int* %DATA.ptr)
    call cc 10 void @next(%cell.ptr* %SP.ptr.ptr, %exec.ptr* %EIP.ptr.ptr,
                           %ret.ptr* %RSP.ptr.ptr, %int* %DATA.ptr) noreturn

    ret void
}

define cc 10 void @SP_BANG(%cell.ptr* %SP.ptr.ptr, %exec.ptr* %EIP.ptr.ptr,
                        %ret.ptr* %RSP.ptr.ptr, %int* %DATA.ptr) noreturn {
    ; call the intrinsic operator
    call cc 10 void @_SP_POP(%cell.ptr* %SP.ptr.ptr, %exec.ptr* %EIP.ptr.ptr,
                             %ret.ptr* %RSP.ptr.ptr, %int* %DATA.ptr)
    call cc 10 void @next(%cell.ptr* %SP.ptr.ptr, %exec.ptr* %EIP.ptr.ptr,
                           %ret.ptr* %RSP.ptr.ptr, %int* %DATA.ptr) noreturn

    ret void
}

; ****************************************************************************
; ALU stuff
; ****************************************************************************

define cc 10 void @CHAR_MIN(%cell.ptr* %SP.ptr.ptr, %exec.ptr* %EIP.ptr.ptr,
                            %ret.ptr* %RSP.ptr.ptr, %int* %DATA.ptr) noreturn {
    %charSize.ptr = alloca %cell
    store %cell 1, %cell* %charSize.ptr
    call cc 10 void @_SP_PUSH(%cell.ptr* %SP.ptr.ptr, %exec.ptr* %EIP.ptr.ptr,
                              %ret.ptr* %RSP.ptr.ptr, %int* %charSize.ptr)
    call cc 10 void @SUB(%cell.ptr* %SP.ptr.ptr, %exec.ptr* %EIP.ptr.ptr,
                         %ret.ptr* %RSP.ptr.ptr, %int* %DATA.ptr) noreturn
    ret void
}

define cc 10 void @CHAR_PLUS(%cell.ptr* %SP.ptr.ptr, %exec.ptr* %EIP.ptr.ptr,
                            %ret.ptr* %RSP.ptr.ptr, %int* %DATA.ptr) noreturn {
    %charSize.ptr = alloca %cell
    store %cell 1, %cell* %charSize.ptr
    call cc 10 void @_SP_PUSH(%cell.ptr* %SP.ptr.ptr, %exec.ptr* %EIP.ptr.ptr,
                              %ret.ptr* %RSP.ptr.ptr, %int* %charSize.ptr)
    call cc 10 void @ADD(%cell.ptr* %SP.ptr.ptr, %exec.ptr* %EIP.ptr.ptr,
                         %ret.ptr* %RSP.ptr.ptr, %int* %DATA.ptr) noreturn
    ret void
}

; chars is a no-op as our addressing and indexing is int8
define cc 10 void @CHARS(%cell.ptr* %SP.ptr.ptr, %exec.ptr* %EIP.ptr.ptr,
                            %ret.ptr* %RSP.ptr.ptr, %int* %DATA.ptr) noreturn {
    call cc 10 void @next(%cell.ptr* %SP.ptr.ptr, %exec.ptr* %EIP.ptr.ptr,
                           %ret.ptr* %RSP.ptr.ptr, %int* %DATA.ptr) noreturn
    ret void
}

define cc 10 void @CELL_MIN(%cell.ptr* %SP.ptr.ptr, %exec.ptr* %EIP.ptr.ptr,
                            %ret.ptr* %RSP.ptr.ptr, %int* %DATA.ptr) noreturn {
    call cc 10 void @_SP_PUSH(%cell.ptr* %SP.ptr.ptr, %exec.ptr* %EIP.ptr.ptr,
                              %ret.ptr* %RSP.ptr.ptr, %int* @CELLSIZE)
    call cc 10 void @SUB(%cell.ptr* %SP.ptr.ptr, %exec.ptr* %EIP.ptr.ptr,
                         %ret.ptr* %RSP.ptr.ptr, %int* %DATA.ptr) noreturn
    ret void
}

define cc 10 void @CELL_PLUS(%cell.ptr* %SP.ptr.ptr, %exec.ptr* %EIP.ptr.ptr,
                             %ret.ptr* %RSP.ptr.ptr, %int* %DATA.ptr) noreturn {
    call cc 10 void @_SP_PUSH(%cell.ptr* %SP.ptr.ptr, %exec.ptr* %EIP.ptr.ptr,
                              %ret.ptr* %RSP.ptr.ptr, %int* @CELLSIZE)
    call cc 10 void @ADD(%cell.ptr* %SP.ptr.ptr, %exec.ptr* %EIP.ptr.ptr,
                         %ret.ptr* %RSP.ptr.ptr, %int* %DATA.ptr) noreturn
    ret void
}

define cc 10 void @CELLS(%cell.ptr* %SP.ptr.ptr, %exec.ptr* %EIP.ptr.ptr,
                         %ret.ptr* %RSP.ptr.ptr, %int* %DATA.ptr) noreturn {
    call cc 10 void @_SP_PUSH(%cell.ptr* %SP.ptr.ptr, %exec.ptr* %EIP.ptr.ptr,
                              %ret.ptr* %RSP.ptr.ptr, %int* @CELLSIZE)
    call cc 10 void @MUL(%cell.ptr* %SP.ptr.ptr, %exec.ptr* %EIP.ptr.ptr,
                         %ret.ptr* %RSP.ptr.ptr, %int* %DATA.ptr) noreturn
    ret void
}

define cc 10 void @NONZERO(%cell.ptr* %SP.ptr.ptr, %exec.ptr* %EIP.ptr.ptr,
                           %ret.ptr* %RSP.ptr.ptr, %int* %DATA.ptr) noreturn {
    call cc 10 void @_SP_POP(%cell.ptr* %SP.ptr.ptr, %exec.ptr* %EIP.ptr.ptr,
                             %ret.ptr* %RSP.ptr.ptr, %int* %DATA.ptr)
    %DATA.value = load %int* %DATA.ptr
    %result.flag = icmp ugt %int %DATA.value, 0
    %result.int = zext i1 %result.flag to %int
    store %int %result.int, %int* %DATA.ptr
    call cc 10 void @_SP_PUSH(%cell.ptr* %SP.ptr.ptr, %exec.ptr* %EIP.ptr.ptr,
                              %ret.ptr* %RSP.ptr.ptr, %int* %DATA.ptr)
    call cc 10 void @next(%cell.ptr* %SP.ptr.ptr, %exec.ptr* %EIP.ptr.ptr,
                           %ret.ptr* %RSP.ptr.ptr, %int* %DATA.ptr) noreturn
    ret void
}

define cc 10 void @AND(%cell.ptr* %SP.ptr.ptr, %exec.ptr* %EIP.ptr.ptr,
                           %ret.ptr* %RSP.ptr.ptr, %int* %DATA.ptr) noreturn {
    %first.ptr = alloca %int
    %second.ptr = alloca %int
    call cc 10 void @_SP_POP(%cell.ptr* %SP.ptr.ptr, %exec.ptr* %EIP.ptr.ptr,
                             %ret.ptr* %RSP.ptr.ptr, %int* %first.ptr)
    call cc 10 void @_SP_POP(%cell.ptr* %SP.ptr.ptr, %exec.ptr* %EIP.ptr.ptr,
                             %ret.ptr* %RSP.ptr.ptr, %int* %second.ptr)
    %first.value = load %int* %first.ptr
    %second.value = load %int* %second.ptr
    %DATA.value = and %int %first.value, %second.value
    store %int %DATA.value, %int* %DATA.ptr
    call cc 10 void @_SP_PUSH(%cell.ptr* %SP.ptr.ptr, %exec.ptr* %EIP.ptr.ptr,
                              %ret.ptr* %RSP.ptr.ptr, %int* %DATA.ptr)
    call cc 10 void @next(%cell.ptr* %SP.ptr.ptr, %exec.ptr* %EIP.ptr.ptr,
                           %ret.ptr* %RSP.ptr.ptr, %int* %DATA.ptr) noreturn
    ret void
}

define cc 10 void @OR(%cell.ptr* %SP.ptr.ptr, %exec.ptr* %EIP.ptr.ptr,
                      %ret.ptr* %RSP.ptr.ptr, %int* %DATA.ptr) noreturn {
    %first.ptr = alloca %int
    %second.ptr = alloca %int
    call cc 10 void @_SP_POP(%cell.ptr* %SP.ptr.ptr, %exec.ptr* %EIP.ptr.ptr,
                             %ret.ptr* %RSP.ptr.ptr, %int* %first.ptr)
    call cc 10 void @_SP_POP(%cell.ptr* %SP.ptr.ptr, %exec.ptr* %EIP.ptr.ptr,
                             %ret.ptr* %RSP.ptr.ptr, %int* %second.ptr)
    %first.value = load %int* %first.ptr
    %second.value = load %int* %second.ptr
    %DATA.value = or %int %first.value, %second.value
    store %int %DATA.value, %int* %DATA.ptr
    call cc 10 void @_SP_PUSH(%cell.ptr* %SP.ptr.ptr, %exec.ptr* %EIP.ptr.ptr,
                              %ret.ptr* %RSP.ptr.ptr, %int* %DATA.ptr)
    call cc 10 void @next(%cell.ptr* %SP.ptr.ptr, %exec.ptr* %EIP.ptr.ptr,
                           %ret.ptr* %RSP.ptr.ptr, %int* %DATA.ptr) noreturn
    ret void
}

define cc 10 void @XOR(%cell.ptr* %SP.ptr.ptr, %exec.ptr* %EIP.ptr.ptr,
                       %ret.ptr* %RSP.ptr.ptr, %int* %DATA.ptr) noreturn {
    %first.ptr = alloca %int
    %second.ptr = alloca %int
    call cc 10 void @_SP_POP(%cell.ptr* %SP.ptr.ptr, %exec.ptr* %EIP.ptr.ptr,
                             %ret.ptr* %RSP.ptr.ptr, %int* %first.ptr)
    call cc 10 void @_SP_POP(%cell.ptr* %SP.ptr.ptr, %exec.ptr* %EIP.ptr.ptr,
                             %ret.ptr* %RSP.ptr.ptr, %int* %second.ptr)
    %first.value = load %int* %first.ptr
    %second.value = load %int* %second.ptr
    %DATA.value = xor %int %first.value, %second.value
    store %int %DATA.value, %int* %DATA.ptr
    call cc 10 void @_SP_PUSH(%cell.ptr* %SP.ptr.ptr, %exec.ptr* %EIP.ptr.ptr,
                              %ret.ptr* %RSP.ptr.ptr, %int* %DATA.ptr)
    call cc 10 void @next(%cell.ptr* %SP.ptr.ptr, %exec.ptr* %EIP.ptr.ptr,
                           %ret.ptr* %RSP.ptr.ptr, %int* %DATA.ptr) noreturn
    ret void
}

define cc 10 void @UMPLUS(%cell.ptr* %SP.ptr.ptr, %exec.ptr* %EIP.ptr.ptr,
                          %ret.ptr* %RSP.ptr.ptr, %int* %DATA.ptr) noreturn {
    %first.ptr = alloca %cell
    %second.ptr = alloca %cell
    %result.ptr = alloca %cell
    %carry.ptr = alloca %cell
    call cc 10 void @_SP_POP(%cell.ptr* %SP.ptr.ptr, %exec.ptr* %EIP.ptr.ptr,
                             %ret.ptr* %RSP.ptr.ptr, %int* %first.ptr)
    call cc 10 void @_SP_POP(%cell.ptr* %SP.ptr.ptr, %exec.ptr* %EIP.ptr.ptr,
                             %ret.ptr* %RSP.ptr.ptr, %int* %second.ptr)
    %first.value = load %cell* %first.ptr
    %second.value = load %cell* %second.ptr
    %result = call {%int, i1} @llvm_ump(%int %first.value, %int %second.value)
    %sum.int = extractvalue {%int, i1} %result, 0
    %carry.flag = extractvalue {%int, i1} %result, 1
    %carry.int = zext i1 %carry.flag to %int
    store %int %sum.int, %cell* %result.ptr
    call cc 10 void @_SP_PUSH(%cell.ptr* %SP.ptr.ptr, %exec.ptr* %EIP.ptr.ptr,
                              %ret.ptr* %RSP.ptr.ptr, %int* %result.ptr)
    store %int %carry.int, %cell* %carry.ptr
    call cc 10 void @_SP_PUSH(%cell.ptr* %SP.ptr.ptr, %exec.ptr* %EIP.ptr.ptr,
                              %ret.ptr* %RSP.ptr.ptr, %int* %carry.ptr)
    call cc 10 void @next(%cell.ptr* %SP.ptr.ptr, %exec.ptr* %EIP.ptr.ptr,
                           %ret.ptr* %RSP.ptr.ptr, %int* %DATA.ptr) noreturn
    ret void
}

define cc 10 void @ADD(%cell.ptr* %SP.ptr.ptr, %exec.ptr* %EIP.ptr.ptr,
                       %ret.ptr* %RSP.ptr.ptr, %int* %DATA.ptr) noreturn {
    %first.ptr = alloca %cell
    %second.ptr = alloca %cell
    %result.ptr = alloca %cell
    call cc 10 void @_SP_POP(%cell.ptr* %SP.ptr.ptr, %exec.ptr* %EIP.ptr.ptr,
                             %ret.ptr* %RSP.ptr.ptr, %int* %first.ptr)
    call cc 10 void @_SP_POP(%cell.ptr* %SP.ptr.ptr, %exec.ptr* %EIP.ptr.ptr,
                             %ret.ptr* %RSP.ptr.ptr, %int* %second.ptr)
    %first.value = load %cell* %first.ptr
    %second.value = load %cell* %second.ptr
    %result.value = add %cell %first.value, %second.value
    store %cell %result.value, %cell* %result.ptr
    call cc 10 void @_SP_PUSH(%cell.ptr* %SP.ptr.ptr, %exec.ptr* %EIP.ptr.ptr,
                              %ret.ptr* %RSP.ptr.ptr, %int* %result.ptr)
    call cc 10 void @next(%cell.ptr* %SP.ptr.ptr, %exec.ptr* %EIP.ptr.ptr,
                           %ret.ptr* %RSP.ptr.ptr, %int* %DATA.ptr) noreturn
    ret void
}

define cc 10 void @SUB(%cell.ptr* %SP.ptr.ptr, %exec.ptr* %EIP.ptr.ptr,
                       %ret.ptr* %RSP.ptr.ptr, %int* %DATA.ptr) noreturn {
    %first.ptr = alloca %cell
    %second.ptr = alloca %cell
    %result.ptr = alloca %cell
    call cc 10 void @_SP_POP(%cell.ptr* %SP.ptr.ptr, %exec.ptr* %EIP.ptr.ptr,
                             %ret.ptr* %RSP.ptr.ptr, %int* %first.ptr)
    call cc 10 void @_SP_POP(%cell.ptr* %SP.ptr.ptr, %exec.ptr* %EIP.ptr.ptr,
                             %ret.ptr* %RSP.ptr.ptr, %int* %second.ptr)
    %first.value = load %cell* %first.ptr
    %second.value = load %cell* %second.ptr
    %result.value = sub %cell %second.value, %first.value
    store %cell %result.value, %cell* %result.ptr
    call cc 10 void @_SP_PUSH(%cell.ptr* %SP.ptr.ptr, %exec.ptr* %EIP.ptr.ptr,
                              %ret.ptr* %RSP.ptr.ptr, %int* %result.ptr)
    call cc 10 void @next(%cell.ptr* %SP.ptr.ptr, %exec.ptr* %EIP.ptr.ptr,
                           %ret.ptr* %RSP.ptr.ptr, %int* %DATA.ptr) noreturn
    ret void
}

define cc 10 void @MUL(%cell.ptr* %SP.ptr.ptr, %exec.ptr* %EIP.ptr.ptr,
                       %ret.ptr* %RSP.ptr.ptr, %int* %DATA.ptr) noreturn {
    %first.ptr = alloca %cell
    %second.ptr = alloca %cell
    %result.ptr = alloca %cell
    call cc 10 void @_SP_POP(%cell.ptr* %SP.ptr.ptr, %exec.ptr* %EIP.ptr.ptr,
                             %ret.ptr* %RSP.ptr.ptr, %int* %first.ptr)
    call cc 10 void @_SP_POP(%cell.ptr* %SP.ptr.ptr, %exec.ptr* %EIP.ptr.ptr,
                             %ret.ptr* %RSP.ptr.ptr, %int* %second.ptr)
    %first.value = load %cell* %first.ptr
    %second.value = load %cell* %second.ptr
    %result.value = mul %cell %first.value, %second.value
    store %cell %result.value, %cell* %result.ptr
    call cc 10 void @_SP_PUSH(%cell.ptr* %SP.ptr.ptr, %exec.ptr* %EIP.ptr.ptr,
                              %ret.ptr* %RSP.ptr.ptr, %int* %result.ptr)
    call cc 10 void @next(%cell.ptr* %SP.ptr.ptr, %exec.ptr* %EIP.ptr.ptr,
                           %ret.ptr* %RSP.ptr.ptr, %int* %DATA.ptr) noreturn
    ret void
}

define cc 10 void @DIV(%cell.ptr* %SP.ptr.ptr, %exec.ptr* %EIP.ptr.ptr,
                       %ret.ptr* %RSP.ptr.ptr, %int* %DATA.ptr) noreturn {
    %first.ptr = alloca %cell
    %second.ptr = alloca %cell
    %result.ptr = alloca %cell
    call cc 10 void @_SP_POP(%cell.ptr* %SP.ptr.ptr, %exec.ptr* %EIP.ptr.ptr,
                             %ret.ptr* %RSP.ptr.ptr, %int* %first.ptr)
    call cc 10 void @_SP_POP(%cell.ptr* %SP.ptr.ptr, %exec.ptr* %EIP.ptr.ptr,
                             %ret.ptr* %RSP.ptr.ptr, %int* %second.ptr)
    %first.value = load %cell* %first.ptr
    %second.value = load %cell* %second.ptr
    %result.value = udiv %cell %second.value, %first.value
    store %cell %result.value, %cell* %result.ptr
    call cc 10 void @_SP_PUSH(%cell.ptr* %SP.ptr.ptr, %exec.ptr* %EIP.ptr.ptr,
                              %ret.ptr* %RSP.ptr.ptr, %int* %result.ptr)
    call cc 10 void @next(%cell.ptr* %SP.ptr.ptr, %exec.ptr* %EIP.ptr.ptr,
                           %ret.ptr* %RSP.ptr.ptr, %int* %DATA.ptr) noreturn
    ret void
}

define cc 10 void @DISPSTACK(%cell.ptr* %SP.ptr.ptr, %exec.ptr* %EIP.ptr.ptr,
                             %ret.ptr* %RSP.ptr.ptr, %int* %DATA.ptr) noreturn {
    call cc 10 void @showStack(%cell.ptr* %SP.ptr.ptr, %exec.ptr* %EIP.ptr.ptr,
                               %ret.ptr* %RSP.ptr.ptr, %int* %DATA.ptr)
    call cc 10 void @next(%cell.ptr* %SP.ptr.ptr, %exec.ptr* %EIP.ptr.ptr,
                           %ret.ptr* %RSP.ptr.ptr, %int* %DATA.ptr) noreturn

    ret void
}

; *****************************************************************************
; user interaction
; *****************************************************************************

define cc 10 void @repl(%cell.ptr* %SP.ptr.ptr, %exec.ptr* %EIP.ptr.ptr,
                        %ret.ptr* %RSP.ptr.ptr, %int* %DATA.ptr) {
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

    ; kick off our compiled program
    %jmp.addr.ptr = alloca %exec
    ; load our heap pointer, which is stored as a pointer
    %heap.ptr = load %pntr* @HEAP
    %heap.value.ptr = getelementptr %pntr %heap.ptr, %int 0
    %jmp.addr = ptrtoint %pntr %heap.value.ptr to %int
    store %int %jmp.addr, %exec* %jmp.addr.ptr

    call cc 10 void @_EIP_JMP(%cell.ptr* %SP.ptr.ptr, %exec.ptr* %EIP.ptr.ptr,
                              %ret.ptr* %RSP.ptr.ptr, %int* %jmp.addr.ptr)

    ; reset our input buffer pointer to 0
    store i16 0, i16* %inputBufferIdx.ptr

    br label %prompt

    ret void
}

; *****************************************************************************
; main function
; *****************************************************************************

define %int @main() {
    ; our registers that we pass to every Forth function using Haskell CC
    %SP = alloca %cell.ptr
    %EIP = alloca %cell.ptr
    %RSP = alloca %cell.ptr
    %DATA = alloca %cell

    ; local reference to the @SP0 global
    %SP0 = alloca %cell.ptr

    ; allocate our heap - 8MB
    %heap.ptr = alloca %cell, i32 1048576
    %heap.addr = ptrtoint %cell* %heap.ptr to %int
    ; set up our stack at the end of the heap
    %SP.ptr =  getelementptr %cell.ptr %heap.ptr, i32 1048575
    %SP0.ptr = getelementptr %cell.ptr %heap.ptr, i32 1048575
    store %cell.ptr %SP.ptr, %cell.ptr* %SP
    store %cell.ptr %SP0.ptr, %cell.ptr* @SP0
    store %cell 0, %cell.ptr %SP.ptr

    ; set our EIP at the beginning
    %EIP.ptr = getelementptr %cell.ptr %heap.ptr, i32 0
    store %cell.ptr %EIP.ptr, %cell.ptr* %EIP
    store %cell 0, %cell.ptr %EIP.ptr

    call void @printEIPPtr( %cell.ptr* %EIP )
    call void @printStackPtrValues( %cell.ptr* %SP )

    ; RSP isn't used yet, but we set it anyway
    %RSP.ptr = getelementptr %cell.ptr %heap.ptr, i32 511
    store %cell.ptr %RSP.ptr, %cell.ptr* %RSP

    ; store the pointer to our heap in a global value
    store %pntr %heap.ptr, %pntr* @HEAP

    ; *************************************************************************
    ; register our Forth functions in the dictionary
    ; *************************************************************************

    ; _lit - @LIT
    %ptr_lit = getelementptr [ 5 x i8 ]* @str_lit, i32 0
    %i8_lit = bitcast [ 5 x i8 ]* %ptr_lit to i8*
    %dictEntry.lit = alloca %WORD
    call void @registerDictionary( i8* %i8_lit,  
                                   %WORD* %dictEntry.lit,
                                   %FNPTR @_LIT )

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

    ; UM+ - @UMPLUS
    %ptr_umplus = getelementptr [ 4 x i8 ]* @str_umplus, i32 0
    %i8_umplus = bitcast [ 4 x i8 ]* %ptr_umplus to i8*
    %dictEntry.umplus = alloca %WORD
    call void @registerDictionary( i8* %i8_umplus,  
                                   %WORD* %dictEntry.umplus,
                                   %FNPTR @UMPLUS )

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

    ; drop - @DROP
    %ptr_drop = getelementptr [ 5 x i8 ]* @str_drop, i32 0
    %i8_drop = bitcast [ 5 x i8 ]* %ptr_drop to i8*
    %dictEntry.drop = alloca %WORD
    call void @registerDictionary( i8* %i8_drop,  
                                   %WORD* %dictEntry.drop,
                                   %FNPTR @DROP )

    ; SP@ -- @C_BANG
    %ptr_sp_at = getelementptr [ 4 x i8 ]* @str_sp_at, i32 0
    %i8_sp_at = bitcast [ 4 x i8 ]* %ptr_sp_at to i8*
    %dictEntry.sp_at = alloca %WORD
    call void @registerDictionary( i8* %i8_sp_at,  
                                   %WORD* %dictEntry.sp_at,
                                   %FNPTR @SP_AT )

    ; SP! -- @SP_BANG
    %ptr_sp_bang = getelementptr [ 4 x i8 ]* @str_sp_bang, i32 0
    %i8_sp_bang = bitcast [ 4 x i8 ]* %ptr_sp_bang to i8*
    %dictEntry.sp_bang = alloca %WORD
    call void @registerDictionary( i8* %i8_sp_bang,  
                                   %WORD* %dictEntry.sp_bang,
                                   %FNPTR @C_AT )

    ; C@ -- @C_AT
    %ptr_c_at = getelementptr [ 3 x i8 ]* @str_c_at, i32 0
    %i8_c_at = bitcast [ 3 x i8 ]* %ptr_c_at to i8*
    %dictEntry.c_at = alloca %WORD
    call void @registerDictionary( i8* %i8_c_at,  
                                   %WORD* %dictEntry.c_at,
                                   %FNPTR @C_AT )

    ; C! -- @C_BANG
    %ptr_c_bang = getelementptr [ 3 x i8 ]* @str_c_bang, i32 0
    %i8_c_bang = bitcast [ 3 x i8 ]* %ptr_c_bang to i8*
    %dictEntry.c_bang = alloca %WORD
    call void @registerDictionary( i8* %i8_c_bang,  
                                   %WORD* %dictEntry.c_bang,
                                   %FNPTR @C_BANG )

    ; CHAR- - @CHAR_MIN
    %ptr_char_min = getelementptr [ 6 x i8 ]* @str_char_min, i32 0
    %i8_char_min = bitcast [ 6 x i8 ]* %ptr_char_min to i8*
    %dictEntry.char_min = alloca %WORD
    call void @registerDictionary( i8* %i8_char_min,  
                                   %WORD* %dictEntry.char_min,
                                   %FNPTR @CHAR_MIN )

    ; CHAR+ - @CHAR_PLUS
    %ptr_char_plus = getelementptr [ 6 x i8 ]* @str_char_plus, i32 0
    %i8_char_plus = bitcast [ 6 x i8 ]* %ptr_char_plus to i8*
    %dictEntry.char_plus = alloca %WORD
    call void @registerDictionary( i8* %i8_char_plus,  
                                   %WORD* %dictEntry.char_plus,
                                   %FNPTR @CHAR_PLUS )

    ; CHARS - @CHARS
    %ptr_chars = getelementptr [ 6 x i8 ]* @str_chars, i32 0
    %i8_chars = bitcast [ 6 x i8 ]* %ptr_chars to i8*
    %dictEntry.chars = alloca %WORD
    call void @registerDictionary( i8* %i8_chars,  
                                   %WORD* %dictEntry.chars,
                                   %FNPTR @CHARS )

    ; CELL- - @CELL_MIN
    %ptr_cell_min = getelementptr [ 6 x i8 ]* @str_cell_min, i32 0
    %i8_cell_min = bitcast [ 6 x i8 ]* %ptr_cell_min to i8*
    %dictEntry.cell_min = alloca %WORD
    call void @registerDictionary( i8* %i8_cell_min,  
                                   %WORD* %dictEntry.cell_min,
                                   %FNPTR @CELL_MIN )

    ; CELL+ - @CELL_PLUS
    %ptr_cell_plus = getelementptr [ 6 x i8 ]* @str_cell_plus, i32 0
    %i8_cell_plus = bitcast [ 6 x i8 ]* %ptr_cell_plus to i8*
    %dictEntry.cell_plus = alloca %WORD
    call void @registerDictionary( i8* %i8_cell_plus,  
                                   %WORD* %dictEntry.cell_plus,
                                   %FNPTR @CELL_PLUS )

    ; CELLS - @CELLS
    %ptr_cells = getelementptr [ 6 x i8 ]* @str_cells, i32 0
    %i8_cells = bitcast [ 6 x i8 ]* %ptr_cells to i8*
    %dictEntry.cells = alloca %WORD
    call void @registerDictionary( i8* %i8_cells,  
                                   %WORD* %dictEntry.cells,
                                   %FNPTR @CELLS )

    ; 0< - @NONZERO
    %ptr_nonzero = getelementptr [ 3 x i8 ]* @str_nonzero, i32 0
    %i8_nonzero = bitcast [ 3 x i8 ]* %ptr_nonzero to i8*
    %dictEntry.nonzero = alloca %WORD
    call void @registerDictionary( i8* %i8_nonzero,  
                                   %WORD* %dictEntry.nonzero,
                                   %FNPTR @NONZERO )

    ; AND - @AND
    %ptr_and = getelementptr [ 4 x i8 ]* @str_and, i32 0
    %i8_and = bitcast [ 4 x i8 ]* %ptr_and to i8*
    %dictEntry.and = alloca %WORD
    call void @registerDictionary( i8* %i8_and,  
                                   %WORD* %dictEntry.and,
                                   %FNPTR @AND )

    ; OR - @OR
    %ptr_or = getelementptr [ 3 x i8 ]* @str_or, i32 0
    %i8_or = bitcast [ 3 x i8 ]* %ptr_or to i8*
    %dictEntry.or = alloca %WORD
    call void @registerDictionary( i8* %i8_or,  
                                   %WORD* %dictEntry.or,
                                   %FNPTR @OR )

    ; XOR - @XOR
    %ptr_xor = getelementptr [ 4 x i8 ]* @str_xor, i32 0
    %i8_xor = bitcast [ 4 x i8 ]* %ptr_xor to i8*
    %dictEntry.xor = alloca %WORD
    call void @registerDictionary( i8* %i8_xor,  
                                   %WORD* %dictEntry.xor,
                                   %FNPTR @XOR )

    ; ** test our dictionary navigation
    call void @printDictionary()

    ; ** compile our forth program
    %ptr_testProgram = getelementptr[ 21 x i8 ]* @str_testProgram, i32 0
    %i8_testProgram = bitcast [ 21 x i8 ]* %ptr_testProgram to i8*
    call void @compile(i8* %i8_testProgram, %int 0)

    ; ** and finally, execute our program
    call cc 10 void @next(%cell.ptr* %SP, %cell.ptr* %EIP,
                          %cell.ptr* %RSP, %cell* %DATA)

    call cc 10 void @repl(%cell.ptr* %SP, %cell.ptr* %EIP,
                          %cell.ptr* %RSP, %cell* %DATA)

    ret %int 0
}