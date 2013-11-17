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
@kernel.SP_DUP.addr = internal constant i8* 
                                blockaddress(@kernel, %kernel.SP_DUP)
@kernel.SP_DROP.addr = internal constant i8* 
                                blockaddress(@kernel, %kernel.SP_DROP)
@kernel.SP_OVER.addr = internal constant i8* 
                                blockaddress(@kernel, %kernel.SP_OVER)
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
@kernel.ALU.XOR.addr = internal constant i8* 
                                blockaddress(@kernel, %kernel.ALU_XOR)

;@kernel.SP_AT.addr = internal constant i8* blockaddress(@kernel, %kernel.SP_AT)
;@kernel.TEST.addr = internal constant i8* blockaddress(@kernel, %kernel.TEST)
;@kernel.TEST.1.addr = internal constant i8* blockaddress(@kernel, %kernel.TEST.1)
;@kernel.TEST.2.addr = internal constant i8* blockaddress(@kernel, %kernel.TEST.2)
;@kernel.TEST.3.addr = internal constant i8* blockaddress(@kernel, %kernel.TEST.3)

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


@valueString = internal constant    [7 x i8]  c"%llu\0D\0A\00"
@SPValuesString = internal constant [33 x i8] c"SP: @%llu=%llu SP0: @%llu=%llu\0D\0A\00"

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


@SP0 = weak global %cell.ptr null


define void @kernel(%cell.ptr* %SP.ptr.ptr, %exec.ptr* %EIP.ptr.ptr,
                   %ret.ptr* %RSP.ptr.ptr, %cell* %DATA.ptr) {

    br label %kernel.NEXT

; *****************************************************************************
; the core nucleus
; *****************************************************************************

kernel.NEXT:
    ; load the memory address that %EIP.ptr.ptr resolves to
    %EIP.ptr.NEXT = getelementptr %exec.ptr* %EIP.ptr.ptr, i32 0
    %EIP.NEXT = load %exec.ptr* %EIP.ptr.NEXT
    %EIP.addr.ptr.NEXT = getelementptr %cell.ptr %EIP.NEXT, i32 0

    ; load our instruction value
    %INS.int.NEXT = load %exec* %EIP.addr.ptr.NEXT
    %INS.ptr.NEXT = inttoptr %exec %INS.int.NEXT to %exec*

    ; branch to where our instruction says to go
    indirectbr %exec* %INS.ptr.NEXT,  [ label %kernel.NEXT,
                                        label %kernel.NEXT,
                                        label %kernel.EXEC_DOCOL,
                                        label %kernel.EXEC_DOLIT,
                                        label %kernel.M_AT,
                                        label %kernel.M_BANG,
                                        label %kernel.SP_AT,
                                        label %kernel.SP_POP,
                                        label %kernel.SP_PUSH,
                                        label %kernel.SP_SWAP,
                                        label %kernel.SP_DUP,
                                        label %kernel.SP_DROP,
                                        label %kernel.SP_OVER,
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
                                        label %kernel.ALU_XOR ]

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

    ; decrement and store our EIP
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
	; load the memory address that %SP.ptr.ptr resolves to
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

}

define %int @main() {
	%SP = alloca %cell.ptr
	%SP0 = alloca %cell.ptr
	%EIP = alloca %cell.ptr
	%RSP = alloca %cell.ptr
	%DATA = alloca %cell

	%heap.ptr = alloca %cell, i32 1024
	%heap.addr = ptrtoint %cell* %heap.ptr to %int

	%SP.ptr =  getelementptr %cell.ptr %heap.ptr, i32 1023
	%SP0.ptr = getelementptr %cell.ptr %heap.ptr, i32 1023
	store %cell.ptr %SP.ptr, %cell.ptr* %SP
	store %cell.ptr %SP0.ptr, %cell.ptr* @SP0
	store %cell 0, %cell.ptr %SP.ptr

	%EIP.ptr = getelementptr %cell.ptr %heap.ptr, i32 0
	store %cell.ptr %EIP.ptr, %cell.ptr* %EIP
	%RSP.ptr = getelementptr %cell.ptr %heap.ptr, i32 511
	store %cell.ptr %RSP.ptr, %cell.ptr* %RSP

	call void @printStackPtrValues( %cell.ptr* %SP )

	call void @kernel( %cell.ptr* %SP, %exec.ptr* %EIP,
                       %ret.ptr* %RSP, %cell* %DATA)

	call void @printStackPtrValues( %cell.ptr* %SP )

	ret %int 0
}