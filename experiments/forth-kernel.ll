%pntr = type i64*
%cell = type i64
%cell.ptr = type i64*
%ret = type i64
%ret.ptr = type i64*
%exec = type i64
%exec.ptr = type i64*
%int = type i64
%addr = type i64
%addr.ptr = type i64*
%fnaddr = type i8*

%WORD = type { %WORD*, %int, i8* }

; * test forth program
@str_testProgram = internal constant [ 18 x i8 ] c"99 2 3 DUP + SWAP\00"

; * constants containing strings of Forth words
@str_dispStack = internal constant [ 3 x i8 ] c".s\00"
@str_c_at =      internal constant [ 3 x i8 ] c"C@\00"
@str_c_bang =    internal constant [ 3 x i8 ] c"C!\00"
@str_sp_at =     internal constant [ 4 x i8 ] c"SP@\00"
@str_sp_bang =   internal constant [ 4 x i8 ] c"SP!\00"
@str_swap =      internal constant [ 5 x i8 ] c"SWAP\00"
@str_2swap =     internal constant [ 6 x i8 ] c"2SWAP\00"
@str_dup =       internal constant [ 4 x i8 ] c"DUP\00"
@str_2dup =      internal constant [ 5 x i8 ] c"2DUP\00"
@str_drop =      internal constant [ 5 x i8 ] c"DROP\00"
@str_2drop =     internal constant [ 6 x i8 ] c"2DROP\00"
@str_over =      internal constant [ 5 x i8 ] c"OVER\00"
@str_rot =       internal constant [ 4 x i8 ] c"ROT\00"
@str_nrot =      internal constant [ 5 x i8 ] c"-ROT\00"
@str_umplus =    internal constant [ 4 x i8 ] c"UM+\00"
@str_add =       internal constant [ 2 x i8 ] c"+\00"
@str_sub =       internal constant [ 2 x i8 ] c"-\00"
@str_mul =       internal constant [ 2 x i8 ] c"*\00"
@str_div =       internal constant [ 2 x i8 ] c"/\00"
@str_lit =       internal constant [ 6 x i8 ] c"DOLIT\00"
@str_incr =      internal constant [ 5 x i8 ] c"INCR\00"
@str_decr =      internal constant [ 5 x i8 ] c"DECR\00"
@str_incr8 =     internal constant [ 6 x i8 ] c"INCR8\00"
@str_decr8 =     internal constant [ 6 x i8 ] c"DECR8\00"
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
@str_done =      internal constant [ 5 x i8 ] c"DONE\00"


@kernel.NEXT.addr = internal constant i8* 
                                blockaddress(@kernel, %kernel.NEXT)
@kernel.EXEC_DOCOL.addr = internal constant i8* 
                                blockaddress(@kernel, %kernel.EXEC_DOCOL)
@kernel.EXEC_DOLIT.addr = internal constant i8* 
                                blockaddress(@kernel, %kernel.EXEC_DOLIT)
@kernel.M_AT.addr = internal constant i8* 
                                blockaddress(@kernel, %kernel.M_AT)
@kernel.M_BANG.addr = internal constant i8* 
                                blockaddress(@kernel, %kernel.M_BANG)
@kernel.SP_AT.addr = internal constant i8* 
                                blockaddress(@kernel, %kernel.SP_AT)
@kernel.SP_POP.addr = internal constant i8* 
                                blockaddress(@kernel, %kernel.SP_POP)
@kernel.SP_PUSH.addr = internal constant i8* 
                                blockaddress(@kernel, %kernel.SP_PUSH)
@kernel.SP_SWAP.addr = internal constant i8* 
                                blockaddress(@kernel, %kernel.SP_SWAP)
@kernel.SP_2SWAP.addr = internal constant i8* 
                                blockaddress(@kernel, %kernel.SP_2SWAP)
@kernel.SP_DUP.addr = internal constant i8* 
                                blockaddress(@kernel, %kernel.SP_DUP)
@kernel.SP_2DUP.addr = internal constant i8* 
                                blockaddress(@kernel, %kernel.SP_2DUP)
@kernel.SP_DROP.addr = internal constant i8* 
                                blockaddress(@kernel, %kernel.SP_DROP)
@kernel.SP_2DROP.addr = internal constant i8* 
                                blockaddress(@kernel, %kernel.SP_2DROP)
@kernel.SP_OVER.addr = internal constant i8* 
                                blockaddress(@kernel, %kernel.SP_OVER)
@kernel.SP_ROT.addr = internal constant i8* 
                                blockaddress(@kernel, %kernel.SP_ROT)
@kernel.SP_NROT.addr = internal constant i8* 
                                blockaddress(@kernel, %kernel.SP_NROT)
@kernel.ALU_UM_ADD.addr = internal constant i8* 
                                blockaddress(@kernel, %kernel.ALU_UM_ADD)
@kernel.ALU_ADD.addr = internal constant i8* 
                                blockaddress(@kernel, %kernel.ALU_ADD)
@kernel.ALU_SUB.addr = internal constant i8* 
                                blockaddress(@kernel, %kernel.ALU_SUB)
@kernel.ALU_MUL.addr = internal constant i8* 
                                blockaddress(@kernel, %kernel.ALU_MUL)
@kernel.ALU_DIV.addr = internal constant i8* 
                                blockaddress(@kernel, %kernel.ALU_DIV)
@kernel.ALU_CHAR_SUB.addr = internal constant i8* 
                                blockaddress(@kernel, %kernel.ALU_CHAR_SUB)
@kernel.ALU_CHAR_PLUS.addr = internal constant i8* 
                                blockaddress(@kernel, %kernel.ALU_CHAR_PLUS)
@kernel.ALU_CHARS.addr = internal constant i8* 
                                blockaddress(@kernel, %kernel.ALU_CHARS)
@kernel.ALU_CELL_SUB.addr = internal constant i8* 
                                blockaddress(@kernel, %kernel.ALU_CELL_SUB)
@kernel.ALU_CELL_PLUS.addr = internal constant i8* 
                                blockaddress(@kernel, %kernel.ALU_CELL_PLUS)
@kernel.ALU_CELLS.addr = internal constant i8* 
                                blockaddress(@kernel, %kernel.ALU_CELLS)
@kernel.ALU_GTZ.addr = internal constant i8* 
                                blockaddress(@kernel, %kernel.ALU_GTZ)
@kernel.ALU_AND.addr = internal constant i8* 
                                blockaddress(@kernel, %kernel.ALU_AND)
@kernel.ALU_OR.addr = internal constant i8* 
                                blockaddress(@kernel, %kernel.ALU_OR)
@kernel.ALU_XOR.addr = internal constant i8* 
                                blockaddress(@kernel, %kernel.ALU_XOR)
@kernel.DONE.addr = internal constant i8* 
                                blockaddress(@kernel, %kernel.DONE)

declare i8 @getchar()
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

@promptString = internal constant   [5 x i8]  c" Ok \00"
@wordString =  internal constant    [5 x i8]  c"%s\0D\0A\00"
@valueString = internal constant    [7 x i8]  c"%llu\0D\0A\00"
@SPValuesString = internal constant [33 x i8] c"SP: @%llu=%llu SP0: @%llu=%llu\0D\0A\00"
@charString = internal constant     [6 x i8]  c"CHAR:\00"
@compiledString = internal constant [10 x i8] c"COMPILED:\00"
@dictString = internal constant     [6 x i8]  c"DICT:\00"
@literalString = internal constant  [9 x i8]  c"LITERAL:\00"
@progOutString = internal constant  [9 x i8]  c"PROGRAM:\00"
@tokenString = internal constant    [7 x i8]  c"TOKEN:\00"
@twoWordString = internal constant  [8 x i8]  c"%s %s\0D\0A\00"
@dictNavString = internal constant  [15 x i8] c"--> %s (%llu) \00"
@newlineString = internal constant  [3 x i8]  c"\0D\0A\00"
@EIPString = internal constant      [13 x i8] c"EIP: @%llu\0D\0A\00"
@EIPValueString = internal constant [19 x i8] c"EIP: @%llu: %llu\0D\0A\00"

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

define void @printValueInt(%int %value) {
    %string = getelementptr [7 x i8]* @valueString, i32 0, i32 0
    %printf_ret = call i32 (i8*, ... )* @printf(i8* %string, %int %value)
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

define fastcc void @insertToken(%int %index, %int* %token) {
    %insPtr = call fastcc %pntr @getHeap_ptr(%int %index)
    %tokenPtrInt = ptrtoint %int* %token to %int
    call fastcc void @putHeap(%int %index, %int %tokenPtrInt)
    ret void
}

define fastcc void @insertLiteral(%int %index, %int %value) {
    %insPtr = call fastcc %pntr @getHeap_ptr(%int %index)
    call fastcc void @putHeap(%int %index, %int %value)
    ret void
}



@SP0 = weak global %cell.ptr null
@HEAP = weak global %cell.ptr null
@dictPtr = weak global %WORD* null      ; pointer to the last word in the dict
@heapSize = weak global %int 0          ; size of the heap in i8 bytes

define void @kernel(%cell.ptr* %SP.ptr.ptr, %exec.ptr* %EIP.ptr.ptr,
                   %ret.ptr* %RSP.ptr.ptr, %cell* %DATA.ptr) {

    br label %kernel.NEXT

; *****************************************************************************
; the core nucleus
; *****************************************************************************

kernel.NEXT:
    ; load the memory address that %EIP.ptr.ptr resolves to
    %EIP.ptr.NEXT = getelementptr %exec.ptr* %EIP.ptr.ptr, i32 0
    %EIP.ptr.int.NEXT = ptrtoint %exec.ptr* %EIP.ptr.NEXT to %int
    %EIP.NEXT = load %exec.ptr* %EIP.ptr.NEXT
    %EIP.addr.ptr.NEXT = getelementptr %cell.ptr %EIP.NEXT, i32 0
    %EIP.addr.int.NEXT = ptrtoint %cell.ptr %EIP.addr.ptr.NEXT to %addr

    call void @printEIPPtrValue( %cell.ptr* %EIP.ptr.ptr )
    call void @printStackPtrValues( %cell.ptr* %SP.ptr.ptr )

    ; increment and store our EIP
    %EIP.addr.incr.int.NEXT = add %addr %EIP.addr.int.NEXT, 8
    %EIP.addr.incr.ptr.NEXT = inttoptr %addr %EIP.addr.incr.int.NEXT
                                          to %cell.ptr
    store %cell.ptr %EIP.addr.incr.ptr.NEXT, %cell.ptr* %EIP.ptr.ptr

    ; load our instruction value
    %INS.int.NEXT = load %exec* %EIP.addr.ptr.NEXT
    %INS.ptr.NEXT = inttoptr %exec %INS.int.NEXT to %exec*

    ; branch to where our instruction says to go
    indirectbr %exec* %INS.ptr.NEXT,  [ label %kernel.NEXT,
                                        label %kernel.EXEC_DOCOL,
                                        label %kernel.EXEC_DOLIT,
                                        label %kernel.M_AT,
                                        label %kernel.M_BANG,
                                        label %kernel.SP_AT,
                                        label %kernel.SP_POP,
                                        label %kernel.SP_PUSH,
                                        label %kernel.SP_SWAP,
                                        label %kernel.SP_2SWAP,
                                        label %kernel.SP_DUP,
                                        label %kernel.SP_2DUP,
                                        label %kernel.SP_DROP,
                                        label %kernel.SP_2DROP,
                                        label %kernel.SP_OVER,
                                        label %kernel.SP_ROT,
                                        label %kernel.SP_NROT,
                                        label %kernel.ALU_UM_ADD,
                                        label %kernel.ALU_ADD,
                                        label %kernel.ALU_SUB,
                                        label %kernel.ALU_MUL,
                                        label %kernel.ALU_DIV,
                                        label %kernel.ALU_CHAR_SUB,
                                        label %kernel.ALU_CHAR_PLUS,
                                        label %kernel.ALU_CHARS,
                                        label %kernel.ALU_CELL_SUB,
                                        label %kernel.ALU_CELL_PLUS,
                                        label %kernel.ALU_CELLS,
                                        label %kernel.ALU_GTZ,
                                        label %kernel.ALU_AND,
                                        label %kernel.ALU_OR,
                                        label %kernel.ALU_XOR,
                                        label %kernel.DONE ]

; *****************************************************************************
; kernel RSP/execution operations
; *****************************************************************************

kernel.EXEC_RET:
    ; load the memory address that %EIP.ptr.ptr resolves to
    %EIP.ptr.EXEC_RET = getelementptr %exec.ptr* %EIP.ptr.ptr, i32 0
    %EIP.EXEC_RET = load %exec.ptr* %EIP.ptr.EXEC_RET
    %EIP.addr.ptr.EXEC_RET = getelementptr %cell.ptr %EIP.EXEC_RET, i32 0

    ; load the memory address that %RSP.ptr.ptr resolves to
    %RSP.ptr.EXEC_RET = getelementptr %exec.ptr* %RSP.ptr.ptr, i32 0
    %RSP.EXEC_RET = load %exec.ptr* %RSP.ptr.EXEC_RET
    %RSP.addr.ptr.EXEC_RET = getelementptr %cell.ptr %RSP.EXEC_RET, i32 0
    %RSP.addr.int.EXEC_RET = ptrtoint %cell.ptr %RSP.addr.ptr.EXEC_RET
                                   to %addr

    ; load the value under RSP and store it as EIP
    %JUMP.int.EXEC_RET = load %exec* %RSP.addr.ptr.EXEC_RET
    %JUMP.ptr.EXEC_RET = inttoptr %exec %JUMP.int.EXEC_RET to %exec.ptr
    store %exec* %JUMP.ptr.EXEC_RET, %exec.ptr* %EIP.ptr.ptr

    ; increment the RSP, and store it
    %RSP.addr.incr.int.EXEC_RET = add %addr %RSP.addr.int.EXEC_RET, 8
    %RSP.addr.incr.ptr.EXEC_RET = inttoptr %addr %RSP.addr.incr.int.EXEC_RET
                                         to %cell.ptr
    store %cell.ptr %RSP.addr.incr.ptr.EXEC_RET, %cell.ptr* %RSP.ptr.ptr

    br label %kernel.NEXT

kernel.EXEC_DOCOL:
    ; load the memory address that %EIP.ptr.ptr resolves to
    %EIP.ptr.EXEC_DOCOL = getelementptr %exec.ptr* %EIP.ptr.ptr, i32 0
    %EIP.EXEC_DOCOL = load %exec.ptr* %EIP.ptr.EXEC_DOCOL
    %EIP.addr.ptr.EXEC_DOCOL = getelementptr %cell.ptr %EIP.EXEC_DOCOL, i32 0
    %EIP.addr.int.EXEC_DOCOL = ptrtoint %cell.ptr %EIP.addr.ptr.EXEC_DOCOL
                                     to %addr

    ; load the memory address that %RSP.ptr.ptr resolves to
    %RSP.ptr.EXEC_DOCOL = getelementptr %exec.ptr* %RSP.ptr.ptr, i32 0
    %RSP.EXEC_DOCOL = load %exec.ptr* %RSP.ptr.EXEC_DOCOL
    %RSP.addr.ptr.EXEC_DOCOL = getelementptr %cell.ptr %RSP.EXEC_DOCOL, i32 0
    %RSP.addr.int.EXEC_DOCOL = ptrtoint %cell.ptr %RSP.addr.ptr.EXEC_DOCOL
                                     to %addr

    ; load the value under EIP and store it as EIP
    %JUMP.int.EXEC_DOCOL= load %exec* %EIP.addr.ptr.EXEC_DOCOL
    %JUMP.ptr.EXEC_DOCOL = inttoptr %exec %JUMP.int.EXEC_DOCOL to %exec.ptr
    store %exec* %JUMP.ptr.EXEC_DOCOL, %exec.ptr* %EIP.ptr.ptr

    ; increment our old EIP value, which will be the return address
    %EIP.addr.decr.int.EXEC_DOCOL = add %addr %EIP.addr.int.EXEC_DOCOL, 8

    ; decrement the RSP and store the old EIP value there
    %RSP.addr.decr.int.EXEC_DOCOL = sub %addr %RSP.addr.int.EXEC_DOCOL, 8
    %RSP.addr.decr.ptr.EXEC_DOCOL = inttoptr %addr %RSP.addr.decr.int.EXEC_DOCOL
                                         to %cell.ptr
    store %cell.ptr %RSP.addr.decr.ptr.EXEC_DOCOL, %cell.ptr* %RSP.ptr.ptr
    store %cell %EIP.addr.decr.int.EXEC_DOCOL,
          %cell* %RSP.addr.decr.ptr.EXEC_DOCOL

    br label %kernel.NEXT


kernel.EXEC_DOLIT:
    ; load the memory address that %EIP.ptr.ptr resolves to
    %EIP.ptr.EXEC_DOLIT = getelementptr %exec.ptr* %EIP.ptr.ptr, i32 0
    %EIP.EXEC_DOLIT = load %exec.ptr* %EIP.ptr.EXEC_DOLIT
    %EIP.addr.ptr.EXEC_DOLIT = getelementptr %cell.ptr %EIP.EXEC_DOLIT, i32 0
    %EIP.addr.int.EXEC_DOLIT = ptrtoint %cell.ptr %EIP.addr.ptr.EXEC_DOLIT
                                     to %addr

    ; load the value under EIP
    %LITERAL.int.EXEC_DOLIT = load %cell* %EIP.addr.ptr.EXEC_DOLIT

    ; increment and store our EIP
    %EIP.addr.incr.int.EXEC_DOLIT = add %addr %EIP.addr.int.EXEC_DOLIT, 8
    %EIP.addr.incr.ptr.EXEC_DOLIT = inttoptr %addr %EIP.addr.incr.int.EXEC_DOLIT
                                          to %cell.ptr
    store %cell.ptr %EIP.addr.incr.ptr.EXEC_DOLIT, %cell.ptr* %EIP.ptr.ptr

    ; load the memory address that %SP.ptr.ptr resolves to
    %SP.ptr.EXEC_DOLIT = getelementptr %cell.ptr* %SP.ptr.ptr, i32 0
    %SP.EXEC_DOLIT = load %cell.ptr* %SP.ptr.EXEC_DOLIT
    %SP.addr.ptr.EXEC_DOLIT = getelementptr %cell.ptr %SP.EXEC_DOLIT, i32 0
    %SP.addr.int.EXEC_DOLIT = ptrtoint %cell.ptr %SP.addr.ptr.EXEC_DOLIT
                                    to %addr

    ; decrement our stack pointer and store the literal at the new address
    %SP.addr.decr.int.EXEC_DOLIT = sub %addr %SP.addr.int.EXEC_DOLIT, 8
    %SP.addr.decr.ptr.EXEC_DOLIT = inttoptr %addr %SP.addr.decr.int.EXEC_DOLIT
                                         to %cell.ptr
    store %cell.ptr %SP.addr.decr.ptr.EXEC_DOLIT, %cell.ptr* %SP.ptr.ptr
    store %cell %LITERAL.int.EXEC_DOLIT, %cell* %SP.addr.decr.ptr.EXEC_DOLIT

    br label %kernel.NEXT

; *****************************************************************************
; kernel memory operations
; *****************************************************************************

kernel.M_AT:
    ; load the number located at the address on the stack onto the stack
    ;   bx SP_POP
    ;   D# 0 bx [] push

    ; load the memory address that %SP.ptr.ptr resolves to
    %SP.ptr.M_AT = getelementptr %cell.ptr* %SP.ptr.ptr, i32 0
    %SP.M_AT = load %cell.ptr* %SP.ptr.M_AT
    %SP.addr.ptr.M_AT = getelementptr %cell.ptr %SP.M_AT, i32 0
    %SP.addr.int.M_AT = ptrtoint %cell.ptr %SP.addr.ptr.M_AT to %addr

    ; retrieve the address value at SP
    %SOURCE.addr.int.M_AT = load %cell* %SP.addr.ptr.M_AT

    ; convert it to a pointer
    %SOURCE.addr.ptr.M_AT = inttoptr %cell %SOURCE.addr.int.M_AT to %cell*

    ; load the memory at the address pointed at
    %SOURCE.int.M_AT = load %cell* %SOURCE.addr.ptr.M_AT

    ; replace the address on the stack with the number loaded, avoiding any
    ; arithmetic on the stack pointer
    store %cell %SOURCE.int.M_AT, %cell* %SP.addr.ptr.M_AT

    br label %kernel.NEXT


kernel.M_BANG:
    ; pop the number and the address off the stack, and place number at address
    ;   bx pop
    ;   ax pop
    ;   al D# 0 bx [] mov

    ; load the memory address that %SP.ptr.ptr resolves to
    %SP.ptr.M_BANG = getelementptr %cell.ptr* %SP.ptr.ptr, i32 0
    %SP.M_BANG = load %cell.ptr* %SP.ptr.M_BANG
    %SP.addr.ptr.M_BANG = getelementptr %cell.ptr %SP.M_BANG, i32 0
    %SP.addr.int.M_BANG = ptrtoint %cell.ptr %SP.addr.ptr.M_BANG to %addr

    ; retrieve the value at the memory address
    %TARGET.addr.int.M_BANG = load %cell* %SP.addr.ptr.M_BANG

    ; convert it to a pointer
    %TARGET.addr.ptr.M_BANG = inttoptr %cell %TARGET.addr.int.M_BANG
                                    to %cell.ptr

    ; increment our local stack pointer to get the number
    %SP.addr.incr.int.M_BANG = add %addr %SP.addr.int.M_BANG, 8
    %SP.addr.incr.ptr.M_BANG = inttoptr %addr %SP.addr.incr.int.M_BANG
                                     to %cell.ptr
    %DATA.int.M_BANG = load %cell* %SP.addr.incr.ptr.M_BANG

    ; increment our local stack pointer and store it in the SP register now that
    ; we've retrieved the data we need to
    %SP.addr.final.int.M_BANG = add %addr %SP.addr.int.M_BANG, 8
    %SP.addr.final.ptr.M_BANG = inttoptr %addr %SP.addr.final.int.M_BANG
                                      to %cell.ptr
    store %cell.ptr %SP.addr.final.ptr.M_BANG, %cell.ptr* %SP.ptr.ptr

    ; finally, store our number at the target
    store %cell %DATA.int.M_BANG, %cell* %TARGET.addr.ptr.M_BANG

    br label %kernel.NEXT

; *****************************************************************************
; kernel stack operations
; *****************************************************************************

kernel.SP_AT:
    ;   sp bx mov
    ;   bx push
    ;   next

    ; load the memory address that %SP.ptr.ptr resolves to
    %SP.ptr.SP_AT = getelementptr %cell.ptr* %SP.ptr.ptr, i32 0
    %SP.SP_AT = load %cell.ptr* %SP.ptr.SP_AT
    %SP.addr.ptr.SP_AT = getelementptr %cell.ptr %SP.SP_AT, i32 0
    %SP.addr.int.SP_AT = ptrtoint %cell.ptr %SP.addr.ptr.SP_AT to %addr

    ; decrement our integer pointer
    %SP.addr.decr.int.SP_AT = sub %addr %SP.addr.int.SP_AT, 8

    ; resolve our new address as a new pointer
    %SP.addr.decr.ptr.SP_AT = inttoptr %addr %SP.addr.decr.int.SP_AT
                                    to %cell.ptr

    ; store it before we go on
    store %cell.ptr %SP.addr.decr.ptr.SP_AT, %cell.ptr* %SP.ptr.ptr

    ; store our memory address at the new location in the stack
    store %addr %SP.addr.int.SP_AT, %addr* %SP.addr.decr.ptr.SP_AT

    br label %kernel.NEXT


kernel.SP_POP:
	; load the memory address that %SP.ptr.ptr resolves to
    %SP.ptr.SP_POP = getelementptr %cell.ptr* %SP.ptr.ptr, i32 0
    %SP.SP_POP = load %cell.ptr* %SP.ptr.SP_POP
    %SP.addr.ptr.SP_POP = getelementptr %cell.ptr %SP.SP_POP, i32 0
    %SP.addr.int.SP_POP = ptrtoint %cell.ptr %SP.addr.ptr.SP_POP to %addr

    ; store the value at the memory address in the DATA register
    %DATA.int.SP_POP = load %cell* %SP.addr.ptr.SP_POP
    store %cell %DATA.int.SP_POP, %cell* %DATA.ptr

    ; increment our stack integer pointer, and store it in the register
    %SP.addr.incr.int.SP_POP = add %addr %SP.addr.int.SP_POP, 8
    %SP.addr.incr.ptr.SP_POP = inttoptr %addr %SP.addr.incr.int.SP_POP
                                     to %cell.ptr
    store %cell.ptr %SP.addr.incr.ptr.SP_POP, %cell.ptr* %SP.ptr.ptr

    br label %kernel.NEXT


kernel.SP_PUSH:
	; load the memory address that %SP.ptr.ptr resolves to
    %SP.ptr.SP_PUSH = getelementptr %cell.ptr* %SP.ptr.ptr, i32 0
    %SP.SP_PUSH = load %cell.ptr* %SP.ptr.SP_PUSH
    %SP.addr.ptr.SP_PUSH = getelementptr %cell.ptr %SP.SP_PUSH, i32 0
    %SP.addr.int.SP_PUSH = ptrtoint %cell.ptr %SP.addr.ptr.SP_PUSH to %addr

    ; decrement our stack integer pointer, and store it in the register
    %SP.addr.decr.int.SP_PUSH = sub %addr %SP.addr.int.SP_PUSH, 8
    %SP.addr.decr.ptr.SP_PUSH = inttoptr %addr %SP.addr.decr.int.SP_PUSH
                                      to %cell.ptr
    store %cell.ptr %SP.addr.decr.ptr.SP_PUSH, %cell.ptr* %SP.ptr.ptr

    ; store the value in the DATA register at the new memory address
    %DATA.int.SP_PUSH = load %cell* %DATA.ptr
    store %cell %DATA.int.SP_PUSH, %addr* %SP.addr.decr.ptr.SP_PUSH

    br label %kernel.NEXT


kernel.SP_SWAP:
    ; swap top two elements of the stack
    ;   bx pop
    ;   ax pop
    ;   bx push
    ;   ax push
    %SP.ptr.SP_SWAP = getelementptr %cell.ptr* %SP.ptr.ptr, i32 0
    %SP.SP_SWAP = load %cell.ptr* %SP.ptr.SP_SWAP
    %SP.addr.ptr.SP_SWAP = getelementptr %cell.ptr %SP.SP_SWAP, i32 0
    %SP.addr.int.SP_SWAP = ptrtoint %cell.ptr %SP.addr.ptr.SP_SWAP to %addr

    %A.cell = load %cell* %SP.addr.ptr.SP_SWAP

    %SP.addr.incr.int.SP_SWAP = add %addr %SP.addr.int.SP_SWAP, 8
    %SP.addr.incr.ptr.SP_SWAP = inttoptr %addr %SP.addr.incr.int.SP_SWAP
                                      to %cell.ptr

    %B.cell = load %cell* %SP.addr.incr.ptr.SP_SWAP

    store %cell %B.cell, %cell.ptr %SP.addr.ptr.SP_SWAP
    store %cell %A.cell, %cell.ptr %SP.addr.incr.ptr.SP_SWAP

    br label %kernel.NEXT

kernel.SP_2SWAP:
    ; swap top two pairs of elements on the stack
    ;   pop %eax
    ;   pop %ebx
    ;   pop %ecx
    ;   pop %edx
    ;   push %ebx
    ;   push %eax
    ;   push %edx
    ;   push %ecx
    %SP.ptr.SP_2SWAP = getelementptr %cell.ptr* %SP.ptr.ptr, i32 0
    %SP.SP_2SWAP = load %cell.ptr* %SP.ptr.SP_2SWAP

    %A.addr.ptr.SP_2SWAP = getelementptr %cell.ptr %SP.SP_2SWAP, i32 0
    %A.addr.int.SP_2SWAP = ptrtoint %cell.ptr %A.addr.ptr.SP_2SWAP to %addr
    %A.cell.SP_2SWAP = load %cell* %A.addr.ptr.SP_2SWAP

    %B.addr.int.SP_2SWAP = add %addr %A.addr.int.SP_2SWAP, 8
    %B.addr.ptr.SP_2SWAP = inttoptr %addr %B.addr.int.SP_2SWAP to %cell*
    %B.cell.SP_2SWAP = load %cell* %B.addr.ptr.SP_2SWAP

    %C.addr.int.SP_2SWAP = add %addr %B.addr.int.SP_2SWAP, 8
    %C.addr.ptr.SP_2SWAP = inttoptr %addr %C.addr.int.SP_2SWAP to %cell*
    %C.cell.SP_2SWAP = load %cell* %C.addr.ptr.SP_2SWAP

    %D.addr.int.SP_2SWAP = add %addr %C.addr.int.SP_2SWAP, 8
    %D.addr.ptr.SP_2SWAP = inttoptr %addr %D.addr.int.SP_2SWAP to %cell*
    %D.cell.SP_2SWAP = load %cell* %D.addr.ptr.SP_2SWAP

    store %cell %B.cell.SP_2SWAP, %cell* %D.addr.ptr.SP_2SWAP  ; %(edx)
    store %cell %A.cell.SP_2SWAP, %cell* %C.addr.ptr.SP_2SWAP  ; %(ecx)
    store %cell %D.cell.SP_2SWAP, %cell* %B.addr.ptr.SP_2SWAP  ; %(ebx)
    store %cell %C.cell.SP_2SWAP, %cell* %A.addr.ptr.SP_2SWAP  ; %(eax)

    br label %kernel.NEXT

kernel.SP_DUP:
    ; copy the number at the top of the stack onto the top of the stack
    ;   bx pop
    ;   bx push
    ;   bx push 

    ; load the memory address that %SP.ptr.ptr resolves to
    %SP.ptr.SP_DUP = getelementptr %cell.ptr* %SP.ptr.ptr, i32 0
    %SP.SP_DUP = load %cell.ptr* %SP.ptr.SP_DUP
    %SP.addr.ptr.SP_DUP = getelementptr %cell.ptr %SP.SP_DUP, i32 0
    %SP.addr.int.SP_DUP = ptrtoint %cell.ptr %SP.addr.ptr.SP_DUP to %addr

    ; retrieve the value at SP
    %DATA.int.SP_DUP = load %cell* %SP.addr.ptr.SP_DUP

    ; decrement our stack integer pointer, and store it in the register
    %SP.addr.decr.int.SP_DUP = sub %addr %SP.addr.int.SP_DUP, 8
    %SP.addr.decr.ptr.SP_DUP = inttoptr %addr %SP.addr.decr.int.SP_DUP
                                     to %cell.ptr
    store %cell.ptr %SP.addr.decr.ptr.SP_DUP, %cell.ptr* %SP.ptr.ptr

    ; store the value at the new memory address
    store %cell %DATA.int.SP_DUP, %addr* %SP.addr.decr.ptr.SP_DUP

    br label %kernel.NEXT

kernel.SP_2DUP:
    ; copy the top two elements of the stack
    ;   mov (%esp),%eax
    ;   mov 4(%esp),%ebx
    ;   push %ebx
    ;   push %eax

    ; load the memory address that %SP.ptr.ptr resolves to
    %SP.ptr.SP_2DUP = getelementptr %cell.ptr* %SP.ptr.ptr, i32 0
    %SP.SP_2DUP = load %cell.ptr* %SP.ptr.SP_2DUP

    ; load %eax
    %A.addr.ptr.SP_2DUP = getelementptr %cell.ptr %SP.SP_2DUP, i32 0
    %A.addr.int.SP_2DUP = ptrtoint %cell.ptr %A.addr.ptr.SP_2DUP to %addr
    %A.cell.SP_2DUP = load %cell* %A.addr.ptr.SP_2DUP

    ; load %ebx
    %B.addr.int.SP_2DUP = add %addr %A.addr.int.SP_2DUP, 8
    %B.addr.ptr.SP_2DUP = inttoptr %addr %B.addr.int.SP_2DUP to %cell*
    %B.cell.SP_2DUP = load %cell* %B.addr.ptr.SP_2DUP

    ; push %ebx
    %SP.addr.decr.int.SP_2DUP = sub %addr %A.addr.int.SP_2DUP, 8
    %SP.addr.decr.ptr.SP_2DUP = inttoptr %addr %SP.addr.decr.int.SP_2DUP
                                      to %cell*
    store %cell %B.cell.SP_2DUP, %cell* %SP.addr.decr.ptr.SP_2DUP

    ; push %eax
    %SP.addr.decr.decr.int.SP_2DUP = add %addr %SP.addr.decr.int.SP_2DUP, 8
    %SP.addr.decr.decr.ptr.SP_2DUP = inttoptr %addr %SP.addr.decr.decr.int.SP_2DUP
                                           to %cell*
    store %cell %A.cell.SP_2DUP, %cell* %SP.addr.decr.decr.ptr.SP_2DUP

    ; store our new stack pointer
    store %cell* %SP.addr.decr.decr.ptr.SP_2DUP, %cell.ptr* %SP.ptr.ptr

    br label %kernel.NEXT

kernel.SP_DROP:
    ; move the stack pointer to the right, forgetting an element
    ;   bx pop 

    ; load the memory address that %SP.ptr.ptr resolves to
    %SP.ptr.SP_DROP = getelementptr %cell.ptr* %SP.ptr.ptr, i32 0
    %SP.SP_DROP = load %cell.ptr* %SP.ptr.SP_DROP
    %SP.addr.ptr.SP_DROP = getelementptr %cell.ptr %SP.SP_DROP, i32 0
    %SP.addr.int.SP_DROP = ptrtoint %cell.ptr %SP.addr.ptr.SP_DROP to %addr

    ; increment our stack integer pointer, and store it in the register
    %SP.addr.incr.int.SP_DROP = add %addr %SP.addr.int.SP_DROP, 8
    %SP.addr.incr.ptr.SP_DROP = inttoptr %addr %SP.addr.incr.int.SP_DROP
                                      to %cell.ptr
    store %cell.ptr %SP.addr.incr.ptr.SP_DROP, %cell.ptr* %SP.ptr.ptr

    br label %kernel.NEXT

kernel.SP_2DROP:
    ; move the stack pointer two cells to the right, forgetting two elements
    ;   bx pop 
    ;   bx pop 

    ; load the memory address that %SP.ptr.ptr resolves to
    %SP.ptr.SP_2DROP = getelementptr %cell.ptr* %SP.ptr.ptr, i32 0
    %SP.SP_2DROP = load %cell.ptr* %SP.ptr.SP_2DROP
    %SP.addr.ptr.SP_2DROP = getelementptr %cell.ptr %SP.SP_2DROP, i32 0
    %SP.addr.int.SP_2DROP = ptrtoint %cell.ptr %SP.addr.ptr.SP_2DROP to %addr

    ; increment our stack integer pointer, and store it in the register
    %SP.addr.incr.int.SP_2DROP = add %addr %SP.addr.int.SP_2DROP, 16
    %SP.addr.incr.ptr.SP_2DROP = inttoptr %addr %SP.addr.incr.int.SP_2DROP
                                      to %cell.ptr
    store %cell.ptr %SP.addr.incr.ptr.SP_2DROP, %cell.ptr* %SP.ptr.ptr

    br label %kernel.NEXT


kernel.SP_OVER:
    ; copy the number at the top of the stack onto the top of the stack
    ;   bx pop
    ;   ax pop
    ;   ax push
    ;   bx push
    ;   ax push

    ; load the memory address that %SP.ptr.ptr resolves to
    %SP.ptr.SP_OVER = getelementptr %cell.ptr* %SP.ptr.ptr, i32 0
    %SP.SP_OVER = load %cell.ptr* %SP.ptr.SP_OVER
    %SP.addr.ptr.SP_OVER = getelementptr %cell.ptr %SP.SP_OVER, i32 0
    %SP.addr.int.SP_OVER = ptrtoint %cell.ptr %SP.addr.ptr.SP_OVER
                                 to %addr

    ; increment our local SP pointer to grab the value to copy over
    %SP.addr.incr.int.SP_OVER = add %addr %SP.addr.int.SP_OVER, 8
    %SP.addr.incr.ptr.SP_OVER = inttoptr %addr %SP.addr.incr.int.SP_OVER
                                      to %cell.ptr

    ; grab the value now
    %DATA.int.SP_OVER = load %cell* %SP.addr.incr.ptr.SP_OVER

    ; now that we've grabbed our value, increment our SP pointer over the SP
    %SP.addr.decr.int.SP_OVER = sub %addr %SP.addr.incr.int.SP_OVER, 16
    %SP.addr.decr.ptr.SP_OVER = inttoptr %addr %SP.addr.decr.int.SP_OVER
                                      to %cell.ptr

    ; store the value at the new target
    store %cell %DATA.int.SP_OVER, %cell.ptr %SP.addr.decr.ptr.SP_OVER

    ; store our final local stack pointer
    store %cell.ptr %SP.addr.decr.ptr.SP_OVER, %cell.ptr* %SP.ptr.ptr

    br label %kernel.NEXT

kernel.SP_ROT:
    ; rotate the first three elements at the top of the stack
    ;   pop %eax
    ;   pop %ebx
    ;   pop %ecx
    ;   push %ebx
    ;   push %eax
    ;   push %ecx

    ; load the memory address that %SP.ptr.ptr resolves to
    %SP.ptr.SP_ROT = getelementptr %cell.ptr* %SP.ptr.ptr, i32 0
    %SP.SP_ROT = load %cell.ptr* %SP.ptr.SP_ROT
    %SP.addr.ptr.SP_ROT = getelementptr %cell.ptr %SP.SP_ROT, i32 0
    %SP.addr.int.SP_ROT = ptrtoint %cell.ptr %SP.addr.ptr.SP_ROT
                                 to %addr

    ; load %eax
    %A.int.SP_ROT = load %cell* %SP.addr.ptr.SP_ROT

    ; load %ebx
    %SP.addr.incr.int.SP_ROT = add %addr %SP.addr.int.SP_ROT, 8
    %SP.addr.incr.ptr.SP_ROT = inttoptr %addr %SP.addr.incr.int.SP_ROT
                                      to %cell.ptr

    %B.int.SP_ROT = load %cell* %SP.addr.incr.ptr.SP_ROT

    ; load %ecx
    %SP.addr.incr.incr.int.SP_ROT = add %addr %SP.addr.incr.int.SP_ROT, 8
    %SP.addr.incr.incr.ptr.SP_ROT = inttoptr %addr %SP.addr.incr.incr.int.SP_ROT
                                      to %cell.ptr

    %C.int.SP_ROT = load %cell* %SP.addr.incr.incr.ptr.SP_ROT

    ; directly store %eax, %ebx, and %ecx in the appropriate pointers
    store %cell %B.int.SP_ROT, %cell* %SP.addr.incr.incr.ptr.SP_ROT ; %(ecx)
    store %cell %A.int.SP_ROT, %cell* %SP.addr.incr.ptr.SP_ROT      ; %(ebx)
    store %cell %C.int.SP_ROT, %cell* %SP.addr.ptr.SP_ROT           ; %(eax)

    br label %kernel.NEXT

kernel.SP_NROT:
    ; rotate the first three elements at the top of the stack
    ;   pop %eax
    ;   pop %ebx
    ;   pop %ecx
    ;   push %eax
    ;   push %ecx
    ;   push %ebx

    ; load the memory address that %SP.ptr.ptr resolves to
    %SP.ptr.SP_NROT = getelementptr %cell.ptr* %SP.ptr.ptr, i32 0
    %SP.SP_NROT = load %cell.ptr* %SP.ptr.SP_NROT
    %SP.addr.ptr.SP_NROT = getelementptr %cell.ptr %SP.SP_NROT, i32 0
    %SP.addr.int.SP_NROT = ptrtoint %cell.ptr %SP.addr.ptr.SP_NROT
                                 to %addr

    ; load %eax
    %A.int.SP_NROT = load %cell* %SP.addr.ptr.SP_NROT

    ; load %ebx
    %SP.addr.incr.int.SP_NROT = add %addr %SP.addr.int.SP_NROT, 8
    %SP.addr.incr.ptr.SP_NROT = inttoptr %addr %SP.addr.incr.int.SP_NROT
                                      to %cell.ptr

    %B.int.SP_NROT = load %cell* %SP.addr.incr.ptr.SP_NROT

    ; load %ecx
    %SP.addr.incr.incr.int.SP_NROT = add %addr %SP.addr.incr.int.SP_NROT, 8
    %SP.addr.incr.incr.ptr.SP_NROT = inttoptr %addr %SP.addr.incr.incr.int.SP_NROT
                                      to %cell.ptr

    %C.int.SP_NROT = load %cell* %SP.addr.incr.incr.ptr.SP_NROT

    ; directly store %eax, %ebx, and %ecx in the appropriate pointers
    store %cell %A.int.SP_NROT, %cell* %SP.addr.incr.incr.ptr.SP_NROT ; %(ecx)
    store %cell %C.int.SP_NROT, %cell* %SP.addr.incr.ptr.SP_NROT      ; %(ebx)
    store %cell %B.int.SP_NROT, %cell* %SP.addr.ptr.SP_NROT           ; %(eax)

    br label %kernel.NEXT




; *****************************************************************************
; kernel ALU operations
; *****************************************************************************

kernel.ALU_UM_ADD:
    %SP.ptr.ALU_UM_ADD = getelementptr %cell.ptr* %SP.ptr.ptr, i32 0
    %SP.ALU_UM_ADD = load %cell.ptr* %SP.ptr.ALU_UM_ADD
    %SP.addr.ptr.ALU_UM_ADD = getelementptr %cell.ptr %SP.ALU_UM_ADD, i32 0
    %SP.addr.int.ALU_UM_ADD = ptrtoint %cell.ptr %SP.addr.ptr.ALU_UM_ADD
                                    to %addr

    %A.cell.ALU_UM_ADD = load %cell* %SP.addr.ptr.ALU_UM_ADD

    %SP.addr.incr.int.ALU_UM_ADD = add %addr %SP.addr.int.ALU_UM_ADD, 8
    %SP.addr.incr.ptr.ALU_UM_ADD = inttoptr %addr %SP.addr.incr.int.ALU_UM_ADD
                                         to %cell.ptr

    %B.cell.ALU_UM_ADD = load %cell* %SP.addr.incr.ptr.ALU_UM_ADD

    ; do our actual operation, calling the LLVM intrinsic
    %DATA.cell.ALU_UM_ADD = add %cell %A.cell.ALU_UM_ADD, %B.cell.ALU_UM_ADD

    %result.ALU_UM_ADD = call {%int, i1} @llvm_ump(%int %A.cell.ALU_UM_ADD,
                                                   %int %B.cell.ALU_UM_ADD )
    ; store the sum at SP-1
    %sum.int.ALU_UM_ADD = extractvalue {%int, i1} %result.ALU_UM_ADD, 0
    store %cell %sum.int.ALU_UM_ADD, %cell* %SP.addr.ptr.ALU_UM_ADD
    %carry.flag.ALU_UM_ADD = extractvalue {%int, i1} %result.ALU_UM_ADD, 1
    %carry.int.ALU_UM_ADD = zext i1 %carry.flag.ALU_UM_ADD to %int
    store %int %carry.int.ALU_UM_ADD, %cell* %SP.addr.incr.ptr.ALU_UM_ADD

    br label %kernel.NEXT


kernel.ALU_ADD:
    ; load the memory address that %SP.ptr.ptr resolves to
    ;   bx pop
    ;   ax pop
    ;   bx push
    ;   ax push
    %SP.ptr.ALU_ADD = getelementptr %cell.ptr* %SP.ptr.ptr, i32 0
    %SP.ALU_ADD = load %cell.ptr* %SP.ptr.ALU_ADD
    %SP.addr.ptr.ALU_ADD = getelementptr %cell.ptr %SP.ALU_ADD, i32 0
    %SP.addr.int.ALU_ADD = ptrtoint %cell.ptr %SP.addr.ptr.ALU_ADD to %addr

    %A.cell.ALU_ADD = load %cell* %SP.addr.ptr.ALU_ADD

    %SP.addr.incr.int.ALU_ADD = add %addr %SP.addr.int.ALU_ADD, 8
    %SP.addr.incr.ptr.ALU_ADD = inttoptr %addr %SP.addr.incr.int.ALU_ADD
                                      to %cell.ptr

    %B.cell.ALU_ADD = load %cell* %SP.addr.incr.ptr.ALU_ADD

    ; do our actual operation and store it at the stack position for %B
    %DATA.cell.ALU_ADD = add %cell %A.cell.ALU_ADD, %B.cell.ALU_ADD
    store %cell %DATA.cell.ALU_ADD, %cell* %SP.addr.incr.ptr.ALU_ADD

    ; move the stack pointer to %B
    store %cell.ptr %SP.addr.incr.ptr.ALU_ADD, %cell.ptr* %SP.ptr.ptr

    br label %kernel.NEXT

kernel.ALU_SUB:
    ; load the memory address that %SP.ptr.ptr resolves to
    ;   bx pop
    ;   ax pop
    ;   bx push
    ;   ax push
    %SP.ptr.ALU_SUB = getelementptr %cell.ptr* %SP.ptr.ptr, i32 0
    %SP.ALU_SUB = load %cell.ptr* %SP.ptr.ALU_SUB
    %SP.addr.ptr.ALU_SUB = getelementptr %cell.ptr %SP.ALU_SUB, i32 0
    %SP.addr.int.ALU_SUB = ptrtoint %cell.ptr %SP.addr.ptr.ALU_SUB to %addr

    %A.cell.ALU_SUB = load %cell* %SP.addr.ptr.ALU_SUB

    %SP.addr.incr.int.ALU_SUB = add %addr %SP.addr.int.ALU_SUB, 8
    %SP.addr.incr.ptr.ALU_SUB = inttoptr %addr %SP.addr.incr.int.ALU_SUB
                                      to %cell.ptr

    %B.cell.ALU_SUB = load %cell* %SP.addr.incr.ptr.ALU_SUB

    ; do our actual operation and store it at the stack position for %B
    %DATA.cell.ALU_SUB = sub %cell %B.cell.ALU_SUB, %A.cell.ALU_SUB
    store %cell %DATA.cell.ALU_SUB, %cell* %SP.addr.incr.ptr.ALU_SUB

    ; move the stack pointer to %B
    store %cell.ptr %SP.addr.incr.ptr.ALU_SUB, %cell.ptr* %SP.ptr.ptr

    br label %kernel.NEXT


kernel.ALU_MUL:
    ; load the memory address that %SP.ptr.ptr resolves to
    ;   bx pop
    ;   ax pop
    ;   bx push
    ;   ax push
    %SP.ptr.ALU_MUL = getelementptr %cell.ptr* %SP.ptr.ptr, i32 0
    %SP.ALU_MUL = load %cell.ptr* %SP.ptr.ALU_MUL
    %SP.addr.ptr.ALU_MUL = getelementptr %cell.ptr %SP.ALU_MUL, i32 0
    %SP.addr.int.ALU_MUL = ptrtoint %cell.ptr %SP.addr.ptr.ALU_MUL to %addr

    %A.cell.ALU_MUL = load %cell* %SP.addr.ptr.ALU_MUL

    %SP.addr.incr.int.ALU_MUL = add %addr %SP.addr.int.ALU_MUL, 8
    %SP.addr.incr.ptr.ALU_MUL = inttoptr %addr %SP.addr.incr.int.ALU_MUL
                                      to %cell.ptr

    %B.cell.ALU_MUL = load %cell* %SP.addr.incr.ptr.ALU_MUL

    ; do our actual operation and store it at the stack position for %B
    %DATA.cell.ALU_MUL = mul %cell %A.cell.ALU_MUL, %B.cell.ALU_MUL
    store %cell %DATA.cell.ALU_MUL, %cell* %SP.addr.incr.ptr.ALU_MUL

    ; move the stack pointer to %B
    store %cell.ptr %SP.addr.incr.ptr.ALU_MUL, %cell.ptr* %SP.ptr.ptr

    br label %kernel.NEXT


kernel.ALU_DIV:
    ; load the memory address that %SP.ptr.ptr resolves to
    ;   bx pop
    ;   ax pop
    ;   bx push
    ;   ax push
    %SP.ptr.ALU_DIV = getelementptr %cell.ptr* %SP.ptr.ptr, i32 0
    %SP.ALU_DIV = load %cell.ptr* %SP.ptr.ALU_DIV
    %SP.addr.ptr.ALU_DIV = getelementptr %cell.ptr %SP.ALU_DIV, i32 0
    %SP.addr.int.ALU_DIV = ptrtoint %cell.ptr %SP.addr.ptr.ALU_DIV to %addr

    %A.cell.ALU_DIV = load %cell* %SP.addr.ptr.ALU_DIV

    %SP.addr.incr.int.ALU_DIV = add %addr %SP.addr.int.ALU_DIV, 8
    %SP.addr.incr.ptr.ALU_DIV = inttoptr %addr %SP.addr.incr.int.ALU_DIV
                                      to %cell.ptr

    %B.cell.ALU_DIV = load %cell* %SP.addr.incr.ptr.ALU_DIV

    ; do our actual operation and store it at the stack position for %B
    %DATA.cell.ALU_DIV = sdiv %cell %B.cell.ALU_DIV, %A.cell.ALU_DIV
    store %cell %DATA.cell.ALU_DIV, %cell* %SP.addr.incr.ptr.ALU_DIV

    ; move the stack pointer to %B
    store %cell.ptr %SP.addr.incr.ptr.ALU_DIV, %cell.ptr* %SP.ptr.ptr

    br label %kernel.NEXT


kernel.ALU_CHAR_SUB:
    ; decrement the number at the top of the stack by the width of a cell
    %SP.ptr.ALU_CHAR_SUB = getelementptr %cell.ptr* %SP.ptr.ptr, i32 0
    %SP.ALU_CHAR_SUB = load %cell.ptr* %SP.ptr.ALU_CHAR_SUB
    %SP.addr.ptr.ALU_CHAR_SUB = getelementptr %cell.ptr %SP.ALU_CHAR_SUB, i32 0
    %SP.addr.int.ALU_CHAR_SUB = ptrtoint %cell.ptr %SP.addr.ptr.ALU_CHAR_SUB
                                      to %addr

    %A.cell.ALU_CHAR_SUB = load %cell* %SP.addr.ptr.ALU_CHAR_SUB
    %DATA.cell.ALU_CHAR_SUB = sub %cell %A.cell.ALU_CHAR_SUB, 1
    store %cell %DATA.cell.ALU_CHAR_SUB, %cell* %SP.addr.ptr.ALU_CHAR_SUB

    br label %kernel.NEXT


kernel.ALU_CHAR_PLUS:
    ; decrement the number at the top of the stack by the width of a cell
    %SP.ptr.ALU_CHAR_PLUS = getelementptr %cell.ptr* %SP.ptr.ptr, i32 0
    %SP.ALU_CHAR_PLUS = load %cell.ptr* %SP.ptr.ALU_CHAR_PLUS
    %SP.addr.ptr.ALU_CHAR_PLUS = getelementptr %cell.ptr %SP.ALU_CHAR_PLUS, i32 0
    %SP.addr.int.ALU_CHAR_PLUS = ptrtoint %cell.ptr %SP.addr.ptr.ALU_CHAR_PLUS
                                       to %addr

    %A.cell.ALU_CHAR_PLUS = load %cell* %SP.addr.ptr.ALU_CHAR_PLUS
    %DATA.cell.ALU_CHAR_PLUS = add %cell %A.cell.ALU_CHAR_PLUS, 1
    store %cell %DATA.cell.ALU_CHAR_PLUS, %cell* %SP.addr.ptr.ALU_CHAR_PLUS

    br label %kernel.NEXT


kernel.ALU_CHARS:
    ; no-op at present, as multiplying by 1 does nothing

    br label %kernel.NEXT


kernel.ALU_CELL_SUB:
    ; decrement the number at the top of the stack by the width of a cell
    %SP.ptr.ALU_CELL_SUB = getelementptr %cell.ptr* %SP.ptr.ptr, i32 0
    %SP.ALU_CELL_SUB = load %cell.ptr* %SP.ptr.ALU_CELL_SUB
    %SP.addr.ptr.ALU_CELL_SUB = getelementptr %cell.ptr %SP.ALU_CELL_SUB, i32 0
    %SP.addr.int.ALU_CELL_SUB = ptrtoint %cell.ptr %SP.addr.ptr.ALU_CELL_SUB
                                      to %addr

    %A.cell.ALU_CELL_SUB = load %cell* %SP.addr.ptr.ALU_CELL_SUB
    %DATA.cell.ALU_CELL_SUB = sub %cell %A.cell.ALU_CELL_SUB, 8
    store %cell %DATA.cell.ALU_CELL_SUB, %cell* %SP.addr.ptr.ALU_CELL_SUB

    br label %kernel.NEXT


kernel.ALU_CELL_PLUS:
    ; decrement the number at the top of the stack by the width of a cell
    %SP.ptr.ALU_CELL_PLUS = getelementptr %cell.ptr* %SP.ptr.ptr, i32 0
    %SP.ALU_CELL_PLUS = load %cell.ptr* %SP.ptr.ALU_CELL_PLUS
    %SP.addr.ptr.ALU_CELL_PLUS = getelementptr %cell.ptr %SP.ALU_CELL_PLUS,
                                               i32 0
    %SP.addr.int.ALU_CELL_PLUS = ptrtoint %cell.ptr %SP.addr.ptr.ALU_CELL_PLUS
                                       to %addr

    %A.cell.ALU_CELL_PLUS = load %cell* %SP.addr.ptr.ALU_CELL_PLUS
    %DATA.cell.ALU_CELL_PLUS = add %cell %A.cell.ALU_CELL_PLUS, 8
    store %cell %DATA.cell.ALU_CELL_PLUS, %cell* %SP.addr.ptr.ALU_CELL_PLUS

    br label %kernel.NEXT


kernel.ALU_CELLS:
    ; decrement the number at the top of the stack by the width of a cell
    %SP.ptr.ALU_CELLS = getelementptr %cell.ptr* %SP.ptr.ptr, i32 0
    %SP.ALU_CELLS = load %cell.ptr* %SP.ptr.ALU_CELLS
    %SP.addr.ptr.ALU_CELLS = getelementptr %cell.ptr %SP.ALU_CELLS, i32 0
    %SP.addr.int.ALU_CELLS = ptrtoint %cell.ptr %SP.addr.ptr.ALU_CELLS
                                   to %addr

    %A.cell.ALU_CELLS = load %cell* %SP.addr.ptr.ALU_CELLS
    %DATA.cell.ALU_CELLS = mul %cell %A.cell.ALU_CELLS, 8
    store %cell %DATA.cell.ALU_CELLS, %cell* %SP.addr.ptr.ALU_CELLS

    br label %kernel.NEXT


kernel.ALU_GTZ:
    ; decrement the number at the top of the stack by the width of a cell
    %SP.ptr.ALU_GTZ = getelementptr %cell.ptr* %SP.ptr.ptr, i32 0
    %SP.ALU_GTZ = load %cell.ptr* %SP.ptr.ALU_GTZ
    %SP.addr.ptr.ALU_GTZ = getelementptr %cell.ptr %SP.ALU_GTZ, i32 0
    %SP.addr.int.ALU_GTZ = ptrtoint %cell.ptr %SP.addr.ptr.ALU_GTZ
                                 to %addr

    %A.cell.ALU_GTZ = load %cell* %SP.addr.ptr.ALU_GTZ
    %DATA.flag.ALU_GTZ = icmp sgt %cell %A.cell.ALU_GTZ, 0
    %DATA.int.ALU_GTZ = zext i1 %DATA.flag.ALU_GTZ to %int

    store %cell %DATA.int.ALU_GTZ, %cell* %SP.addr.ptr.ALU_GTZ

    br label %kernel.NEXT


kernel.ALU_AND:
    ; load the memory address that %SP.ptr.ptr resolves to
    %SP.ptr.ALU_AND = getelementptr %cell.ptr* %SP.ptr.ptr, i32 0
    %SP.ALU_AND = load %cell.ptr* %SP.ptr.ALU_AND
    %SP.addr.ptr.ALU_AND = getelementptr %cell.ptr %SP.ALU_AND, i32 0
    %SP.addr.int.ALU_AND = ptrtoint %cell.ptr %SP.addr.ptr.ALU_AND to %addr

    %A.cell.ALU_AND = load %cell* %SP.addr.ptr.ALU_AND

    %SP.addr.incr.int.ALU_AND = add %addr %SP.addr.int.ALU_AND, 8
    %SP.addr.incr.ptr.ALU_AND = inttoptr %addr %SP.addr.incr.int.ALU_AND
                                      to %cell.ptr

    %B.cell.ALU_AND = load %cell* %SP.addr.incr.ptr.ALU_AND

    ; do our actual operation and store it at the stack position for %B
    %DATA.cell.ALU_AND = and %cell %A.cell.ALU_AND, %B.cell.ALU_AND
    store %cell %DATA.cell.ALU_AND, %cell* %SP.addr.incr.ptr.ALU_AND

    ; move the stack pointer to %B
    store %cell.ptr %SP.addr.incr.ptr.ALU_AND, %cell.ptr* %SP.ptr.ptr

    br label %kernel.NEXT


kernel.ALU_OR:
    ; load the memory address that %SP.ptr.ptr resolves to
    ;   bx pop
    ;   ax pop
    ;   bx push
    ;   ax push
    %SP.ptr.ALU_OR = getelementptr %cell.ptr* %SP.ptr.ptr, i32 0
    %SP.ALU_OR = load %cell.ptr* %SP.ptr.ALU_OR
    %SP.addr.ptr.ALU_OR = getelementptr %cell.ptr %SP.ALU_OR, i32 0
    %SP.addr.int.ALU_OR = ptrtoint %cell.ptr %SP.addr.ptr.ALU_OR to %addr

    %A.cell.ALU_OR = load %cell* %SP.addr.ptr.ALU_OR

    %SP.addr.incr.int.ALU_OR = add %addr %SP.addr.int.ALU_OR, 8
    %SP.addr.incr.ptr.ALU_OR = inttoptr %addr %SP.addr.incr.int.ALU_OR
                                     to %cell.ptr

    %B.cell.ALU_OR = load %cell* %SP.addr.incr.ptr.ALU_OR

    ; do our actual operation and store it at the stack position for %B
    %DATA.cell.ALU_OR = or %cell %A.cell.ALU_OR, %B.cell.ALU_OR
    store %cell %DATA.cell.ALU_OR, %cell* %SP.addr.incr.ptr.ALU_OR

    ; move the stack pointer to %B
    store %cell.ptr %SP.addr.incr.ptr.ALU_OR, %cell.ptr* %SP.ptr.ptr

    br label %kernel.NEXT


kernel.ALU_XOR:
    ; load the memory address that %SP.ptr.ptr resolves to
    ;   bx pop
    ;   ax pop
    ;   bx push
    ;   ax push
    %SP.ptr.ALU_XOR = getelementptr %cell.ptr* %SP.ptr.ptr, i32 0
    %SP.ALU_XOR = load %cell.ptr* %SP.ptr.ALU_XOR
    %SP.addr.ptr.ALU_XOR = getelementptr %cell.ptr %SP.ALU_XOR, i32 0
    %SP.addr.int.ALU_XOR = ptrtoint %cell.ptr %SP.addr.ptr.ALU_XOR to %addr

    %A.cell.ALU_XOR = load %cell* %SP.addr.ptr.ALU_XOR

    %SP.addr.incr.int.ALU_XOR = add %addr %SP.addr.int.ALU_XOR, 8
    %SP.addr.incr.ptr.ALU_XOR = inttoptr %addr %SP.addr.incr.int.ALU_XOR
                                      to %cell.ptr

    %B.cell.ALU_XOR = load %cell* %SP.addr.incr.ptr.ALU_XOR

    ; do our actual operation and store it at the stack position for %B
    %DATA.cell.ALU_XOR = xor %cell %A.cell.ALU_XOR, %B.cell.ALU_XOR
    store %cell %DATA.cell.ALU_XOR, %cell* %SP.addr.incr.ptr.ALU_XOR

    ; move the stack pointer to %B
    store %cell.ptr %SP.addr.incr.ptr.ALU_XOR, %cell.ptr* %SP.ptr.ptr

    br label %kernel.NEXT

kernel.DONE:
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
    %forthFn.ptr.int = load %int* %forthFn.ptr.ptr
    ;%forthFn.ptr.int = ptrtoint %FNPTR %forthFn.ptr to %int

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

define i64* @lookupDictionary(i8* %wordString) {
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
    %forthFn.ptr.int = load i64* %forthFn.ptr.ptr
    %forthKernel.ptr = inttoptr i64 %forthFn.ptr.int to %cell*
    ret i64* %forthKernel.ptr
notFound:
    ; we didn't find anything, so we return null
    ret i64* null
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
    %forthFn.ptr = call i64* @lookupDictionary(i8* %currToken.ptr)

    ; load our current heap index for inserting a pointer or a literal
    %currHeapIdx.value = load %int* %currHeapIdx.ptr

    ; check if we have a function pointer, or a null pointer
    %is_fnPtr_null = icmp eq i64* %forthFn.ptr, null
    br i1 %is_fnPtr_null, label %checkLiteral, label %insertFn

insertFn:
    ; insert our function pointer into our heap
    call fastcc void @insertToken(%int %currHeapIdx.value, i64* %forthFn.ptr)

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
    %_LIT.addr.ptr = load i8** @kernel.EXEC_DOLIT.addr
    %_LIT.addr.int = ptrtoint i8* %_LIT.addr.ptr to %int
    call fastcc void @insertLiteral(%int %currHeapIdx.value,
                                    %int %_LIT.addr.int)
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

    ; clean up by terminating our compiled output with DONE
    %DONE.addr.ptr = load i8** @kernel.DONE.addr
    %DONE.addr.int = ptrtoint i8* %DONE.addr.ptr to %int

    call fastcc void @insertLiteral(%int %currHeapIdx.value.done,
                                    %int %DONE.addr.int)

    ret void
}

define void @registerDictionary(i8* %wordString, %WORD* %newDictEntry,
                                i8** %wordPtr) {
    %dictPtr = load %WORD** @dictPtr

    %newDictEntry.prevEntry = getelementptr %WORD* %newDictEntry, i32 0, i32 0
    %newDictEntry.wordPtr = getelementptr %WORD* %newDictEntry, i32 0, i32 1
    %newDictEntry.wordString = getelementptr %WORD* %newDictEntry, i32 0, i32 2
    %wordPtr.int.ptr = load i8** %wordPtr
    %wordPtr.int = ptrtoint i8* %wordPtr.int.ptr to %int

    store %WORD* %dictPtr, %WORD** %newDictEntry.prevEntry
    store %int %wordPtr.int, %int* %newDictEntry.wordPtr
    store i8* %wordString, i8** %newDictEntry.wordString

    ; move our dictionary pointer to the newly defined word, the new tail
    store %WORD* %newDictEntry, %WORD** @dictPtr

    ret void
}

define void @repl(%cell.ptr* %SP.ptr.ptr, %exec.ptr* %EIP.ptr.ptr,
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

    ; load our heap pointer, which is stored as a pointer
    %heap.ptr = load %pntr* @HEAP
    %heap.value.ptr = getelementptr %pntr %heap.ptr, %int 0
    store %pntr %heap.value.ptr, %exec.ptr* %EIP.ptr.ptr

    call void @kernel(%cell.ptr* %SP.ptr.ptr, %exec.ptr* %EIP.ptr.ptr,
                      %ret.ptr* %RSP.ptr.ptr, %int* %DATA.ptr)

    ; reset our input buffer pointer to 0
    store i16 0, i16* %inputBufferIdx.ptr

    br label %prompt

    ret void
}

define %int @main() {
	%SP = alloca %cell.ptr
	%SP0 = alloca %cell.ptr
	%EIP = alloca %cell.ptr
	%RSP = alloca %cell.ptr
	%DATA = alloca %cell

	%heap.ptr = alloca %cell, i32 1024
	%heap.addr = ptrtoint %cell* %heap.ptr to %int
    store %pntr %heap.ptr, %pntr* @HEAP

	%SP.ptr =  getelementptr %cell.ptr %heap.ptr, i32 1023
	%SP0.ptr = getelementptr %cell.ptr %heap.ptr, i32 1023
	store %cell.ptr %SP.ptr, %cell.ptr* %SP
	store %cell.ptr %SP0.ptr, %cell.ptr* @SP0
	store %cell 0, %cell.ptr %SP.ptr

	%EIP.ptr = getelementptr %cell.ptr %heap.ptr, i32 0
	store %cell.ptr %EIP.ptr, %cell.ptr* %EIP
	%RSP.ptr = getelementptr %cell.ptr %heap.ptr, i32 511
	store %cell.ptr %RSP.ptr, %cell.ptr* %RSP

    ; DOLIT - @DOLIT
    %ptr_lit = getelementptr [ 6 x i8 ]* @str_lit, i32 0
    %i8_lit = bitcast [ 6 x i8 ]* %ptr_lit to i8*
    %dictEntry.lit = alloca %WORD
    call void @registerDictionary( i8* %i8_lit,  
                                   %WORD* %dictEntry.lit,
                                   i8** @kernel.EXEC_DOLIT.addr )

    ; .s - @DISPSTACK
    ; %ptr_dispStack = getelementptr [ 3 x i8 ]* @str_dispStack, i32 0
    ; %i8_dispStack = bitcast [ 3 x i8 ]* %ptr_dispStack to i8*
    ; %dictEntry.dispStack = alloca %WORD
    ;call void @registerDictionary( i8* %i8_dispStack, 
    ;                               %WORD* %dictEntry.dispStack,
    ;                               %FNPTR @DISPSTACK )

    ; / - @DIV
    %ptr_div = getelementptr [ 2 x i8 ]* @str_div, i32 0
    %i8_div = bitcast [ 2 x i8 ]* %ptr_div to i8*
    %dictEntry.div = alloca %WORD
    call void @registerDictionary( i8* %i8_div, 
                                   %WORD* %dictEntry.div,
                                   i8** @kernel.ALU_DIV.addr )

    ; * - @MUL
    %ptr_mul = getelementptr [ 2 x i8 ]* @str_mul, i32 0
    %i8_mul = bitcast [ 2 x i8 ]* %ptr_mul to i8*
    %dictEntry.mul = alloca %WORD
    call void @registerDictionary( i8* %i8_mul, 
                                   %WORD* %dictEntry.mul,
                                   i8** @kernel.ALU_MUL.addr )

    ; - - @SUB
    %ptr_sub = getelementptr [ 2 x i8 ]* @str_sub, i32 0
    %i8_sub = bitcast [ 2 x i8 ]* %ptr_sub to i8*
    %dictEntry.sub = alloca %WORD
    call void @registerDictionary( i8* %i8_sub,  
                                   %WORD* %dictEntry.sub,
                                   i8** @kernel.ALU_SUB.addr )

    ; + - @ADD
    %ptr_add = getelementptr [ 2 x i8 ]* @str_add, i32 0
    %i8_add = bitcast [ 2 x i8 ]* %ptr_add to i8*
    %dictEntry.add = alloca %WORD
    call void @registerDictionary( i8* %i8_add,  
                                   %WORD* %dictEntry.add,
                                   i8** @kernel.ALU_ADD.addr )

    ; UM+ - @UMPLUS
    %ptr_umplus = getelementptr [ 4 x i8 ]* @str_umplus, i32 0
    %i8_umplus = bitcast [ 4 x i8 ]* %ptr_umplus to i8*
    %dictEntry.umplus = alloca %WORD
    call void @registerDictionary( i8* %i8_umplus,  
                                   %WORD* %dictEntry.umplus,
                                   i8** @kernel.ALU_UM_ADD.addr )

    ; swap - @SWAP
    %ptr_swap = getelementptr [ 5 x i8 ]* @str_swap, i32 0
    %i8_swap = bitcast [ 5 x i8 ]* %ptr_swap to i8*
    %dictEntry.swap = alloca %WORD
    call void @registerDictionary( i8* %i8_swap,  
                                   %WORD* %dictEntry.swap,
                                   i8** @kernel.SP_SWAP.addr )

    ; 2swap - @2SWAP
    %ptr_2swap = getelementptr [ 6 x i8 ]* @str_2swap, i32 0
    %i8_2swap = bitcast [ 6 x i8 ]* %ptr_2swap to i8*
    %dictEntry.2swap = alloca %WORD
    call void @registerDictionary( i8* %i8_2swap,  
                                   %WORD* %dictEntry.2swap,
                                   i8** @kernel.SP_2SWAP.addr )

    ; dup - @DUP
    %ptr_dup = getelementptr [ 4 x i8 ]* @str_dup, i32 0
    %i8_dup = bitcast [ 4 x i8 ]* %ptr_dup to i8*
    %dictEntry.dup = alloca %WORD
    call void @registerDictionary( i8* %i8_dup,  
                                   %WORD* %dictEntry.dup,
                                   i8** @kernel.SP_DUP.addr )

    ; 2dup - @2DUP
    %ptr_2dup = getelementptr [ 5 x i8 ]* @str_2dup, i32 0
    %i8_2dup = bitcast [ 5 x i8 ]* %ptr_2dup to i8*
    %dictEntry.2dup = alloca %WORD
    call void @registerDictionary( i8* %i8_2dup,  
                                   %WORD* %dictEntry.2dup,
                                   i8** @kernel.SP_2DUP.addr )

    ; drop - @DROP
    %ptr_drop = getelementptr [ 5 x i8 ]* @str_drop, i32 0
    %i8_drop = bitcast [ 5 x i8 ]* %ptr_drop to i8*
    %dictEntry.drop = alloca %WORD
    call void @registerDictionary( i8* %i8_drop,  
                                   %WORD* %dictEntry.drop,
                                   i8** @kernel.SP_DROP.addr )

    ; 2drop - @2DROP
    %ptr_2drop = getelementptr [ 6 x i8 ]* @str_2drop, i32 0
    %i8_2drop = bitcast [ 6 x i8 ]* %ptr_2drop to i8*
    %dictEntry.2drop = alloca %WORD
    call void @registerDictionary( i8* %i8_2drop,  
                                   %WORD* %dictEntry.2drop,
                                   i8** @kernel.SP_2DROP.addr )

    ; rot - @ROT
    %ptr_rot = getelementptr [ 4 x i8 ]* @str_rot, i32 0
    %i8_rot = bitcast [ 4 x i8 ]* %ptr_rot to i8*
    %dictEntry.rot = alloca %WORD
    call void @registerDictionary( i8* %i8_rot,  
                                   %WORD* %dictEntry.rot,
                                   i8** @kernel.SP_ROT.addr )

    ; -rot - @NROT
    %ptr_nrot = getelementptr [ 5 x i8 ]* @str_nrot, i32 0
    %i8_nrot = bitcast [ 5 x i8 ]* %ptr_nrot to i8*
    %dictEntry.nrot = alloca %WORD
    call void @registerDictionary( i8* %i8_nrot,  
                                   %WORD* %dictEntry.nrot,
                                   i8** @kernel.SP_NROT.addr )

    ; SP@ -- @SP_AT
    %ptr_sp_at = getelementptr [ 4 x i8 ]* @str_sp_at, i32 0
    %i8_sp_at = bitcast [ 4 x i8 ]* %ptr_sp_at to i8*
    %dictEntry.sp_at = alloca %WORD
    call void @registerDictionary( i8* %i8_sp_at,  
                                   %WORD* %dictEntry.sp_at,
                                   i8** @kernel.SP_AT.addr )

    ; SP! -- @SP_POP
    %ptr_sp_bang = getelementptr [ 4 x i8 ]* @str_sp_bang, i32 0
    %i8_sp_bang = bitcast [ 4 x i8 ]* %ptr_sp_bang to i8*
    %dictEntry.sp_bang = alloca %WORD
    call void @registerDictionary( i8* %i8_sp_bang,  
                                   %WORD* %dictEntry.sp_bang,
                                   i8** @kernel.SP_POP.addr )

    ; C@ -- @C_AT
    %ptr_c_at = getelementptr [ 3 x i8 ]* @str_c_at, i32 0
    %i8_c_at = bitcast [ 3 x i8 ]* %ptr_c_at to i8*
    %dictEntry.c_at = alloca %WORD
    call void @registerDictionary( i8* %i8_c_at,  
                                   %WORD* %dictEntry.c_at,
                                   i8** @kernel.M_AT.addr )

    ; C! -- @C_BANG
    %ptr_c_bang = getelementptr [ 3 x i8 ]* @str_c_bang, i32 0
    %i8_c_bang = bitcast [ 3 x i8 ]* %ptr_c_bang to i8*
    %dictEntry.c_bang = alloca %WORD
    call void @registerDictionary( i8* %i8_c_bang,  
                                   %WORD* %dictEntry.c_bang,
                                   i8** @kernel.M_BANG.addr )

    ; CHAR- - @CHAR_MIN
    %ptr_char_min = getelementptr [ 6 x i8 ]* @str_char_min, i32 0
    %i8_char_min = bitcast [ 6 x i8 ]* %ptr_char_min to i8*
    %dictEntry.char_min = alloca %WORD
    call void @registerDictionary( i8* %i8_char_min,  
                                   %WORD* %dictEntry.char_min,
                                   i8** @kernel.ALU_CHAR_SUB.addr )

    ; DECR - alias for %CHAR_MIN
    %ptr_decr = getelementptr [ 5 x i8 ]* @str_decr, i32 0
    %i8_decr = bitcast [ 5 x i8 ]* %ptr_decr to i8*
    %dictEntry.decr = alloca %WORD
    call void @registerDictionary( i8* %i8_decr,  
                                   %WORD* %dictEntry.decr,
                                   i8** @kernel.ALU_CHAR_SUB.addr )

    ; CHAR+ - @CHAR_PLUS
    %ptr_char_plus = getelementptr [ 6 x i8 ]* @str_char_plus, i32 0
    %i8_char_plus = bitcast [ 6 x i8 ]* %ptr_char_plus to i8*
    %dictEntry.char_plus = alloca %WORD
    call void @registerDictionary( i8* %i8_char_plus,  
                                   %WORD* %dictEntry.char_plus,
                                   i8** @kernel.ALU_CHAR_PLUS.addr )

    ; INCR - alias for %CHAR_PLUS
    %ptr_incr = getelementptr [ 5 x i8 ]* @str_incr, i32 0
    %i8_incr = bitcast [ 5 x i8 ]* %ptr_incr to i8*
    %dictEntry.incr = alloca %WORD
    call void @registerDictionary( i8* %i8_incr,  
                                   %WORD* %dictEntry.incr,
                                   i8** @kernel.ALU_CHAR_PLUS.addr )

    ; CHARS - @CHARS
    %ptr_chars = getelementptr [ 6 x i8 ]* @str_chars, i32 0
    %i8_chars = bitcast [ 6 x i8 ]* %ptr_chars to i8*
    %dictEntry.chars = alloca %WORD
    call void @registerDictionary( i8* %i8_chars,  
                                   %WORD* %dictEntry.chars,
                                   i8** @kernel.ALU_CHARS.addr )

    ; CELL- - @CELL_MIN
    %ptr_cell_min = getelementptr [ 6 x i8 ]* @str_cell_min, i32 0
    %i8_cell_min = bitcast [ 6 x i8 ]* %ptr_cell_min to i8*
    %dictEntry.cell_min = alloca %WORD
    call void @registerDictionary( i8* %i8_cell_min,  
                                   %WORD* %dictEntry.cell_min,
                                   i8** @kernel.ALU_CELL_SUB.addr )

    ; CELL+ - @CELL_PLUS
    %ptr_cell_plus = getelementptr [ 6 x i8 ]* @str_cell_plus, i32 0
    %i8_cell_plus = bitcast [ 6 x i8 ]* %ptr_cell_plus to i8*
    %dictEntry.cell_plus = alloca %WORD
    call void @registerDictionary( i8* %i8_cell_plus,  
                                   %WORD* %dictEntry.cell_plus,
                                   i8** @kernel.ALU_CELL_PLUS.addr )

    ; CELLS - @CELLS
    %ptr_cells = getelementptr [ 6 x i8 ]* @str_cells, i32 0
    %i8_cells = bitcast [ 6 x i8 ]* %ptr_cells to i8*
    %dictEntry.cells = alloca %WORD
    call void @registerDictionary( i8* %i8_cells,  
                                   %WORD* %dictEntry.cells,
                                   i8** @kernel.ALU_CELLS.addr )

    ; 0< - @GTZ
    %ptr_nonzero = getelementptr [ 3 x i8 ]* @str_nonzero, i32 0
    %i8_nonzero = bitcast [ 3 x i8 ]* %ptr_nonzero to i8*
    %dictEntry.nonzero = alloca %WORD
    call void @registerDictionary( i8* %i8_nonzero,  
                                   %WORD* %dictEntry.nonzero,
                                   i8** @kernel.ALU_GTZ.addr )

    ; AND - @AND
    %ptr_and = getelementptr [ 4 x i8 ]* @str_and, i32 0
    %i8_and = bitcast [ 4 x i8 ]* %ptr_and to i8*
    %dictEntry.and = alloca %WORD
    call void @registerDictionary( i8* %i8_and,  
                                   %WORD* %dictEntry.and,
                                   i8** @kernel.ALU_AND.addr )

    ; OR - @OR
    %ptr_or = getelementptr [ 3 x i8 ]* @str_or, i32 0
    %i8_or = bitcast [ 3 x i8 ]* %ptr_or to i8*
    %dictEntry.or = alloca %WORD
    call void @registerDictionary( i8* %i8_or,  
                                   %WORD* %dictEntry.or,
                                   i8** @kernel.ALU_OR.addr )

    ; XOR - @XOR
    %ptr_xor = getelementptr [ 4 x i8 ]* @str_xor, i32 0
    %i8_xor = bitcast [ 4 x i8 ]* %ptr_xor to i8*
    %dictEntry.xor = alloca %WORD
    call void @registerDictionary( i8* %i8_xor,  
                                   %WORD* %dictEntry.xor,
                                   i8** @kernel.ALU_XOR.addr )
 
    ; ** test our dictionary navigation
    call void @printDictionary()


    ; ** compile our forth program
    %ptr_testProgram = getelementptr[ 18 x i8 ]* @str_testProgram, i32 0
    %i8_testProgram = bitcast [ 18 x i8 ]* %ptr_testProgram to i8*
    call void @compile(i8* %i8_testProgram, %int 0)

	call void @kernel( %cell.ptr* %SP, %exec.ptr* %EIP,
                       %ret.ptr* %RSP, %cell* %DATA)

	call void @printStackPtrValues( %cell.ptr* %SP )

    call void @repl( %cell.ptr* %SP, %exec.ptr* %EIP,
                     %ret.ptr* %RSP, %cell* %DATA)

	ret %int 0
}