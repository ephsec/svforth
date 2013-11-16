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

@kernel.SP_AT.addr = internal constant i8* blockaddress(@kernel, %kernel.SP_AT)
@kernel.TEST.addr = internal constant i8* blockaddress(@kernel, %kernel.TEST)
@kernel.TEST.1.addr = internal constant i8* blockaddress(@kernel, %kernel.TEST.1)
@kernel.TEST.2.addr = internal constant i8* blockaddress(@kernel, %kernel.TEST.2)
@kernel.TEST.3.addr = internal constant i8* blockaddress(@kernel, %kernel.TEST.3)

declare i32 @printf(i8*, ... )

@SPValuesString = internal constant [33 x i8] c"SP: @%llu=%llu SP0: @%llu=%llu\0D\0A\00"

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
	%A.ptr = alloca %cell
	%B.ptr = alloca %cell
	%RETTMP.ptr = alloca i8*

	%KRNRET.ptr = alloca %fnaddr

	%kernel.SP_AT.addr = load i8** @kernel.SP_AT.addr
	%kernel.TEST.addr = load i8** @kernel.TEST.addr
	%kernel.TEST.1.addr = load i8** @kernel.TEST.1.addr
	%kernel.TEST.2.addr = load i8** @kernel.TEST.2.addr
	%kernel.TEST.3.addr = load i8** @kernel.TEST.3.addr

	br label %kernel.TEST

kernel.TEST:
	; set our return address
	store %fnaddr %kernel.TEST.1.addr, %fnaddr* %KRNRET.ptr
	; set our data register
	store %cell 100, %cell* %DATA.ptr
	; jump to our target function
	br label %kernel.SP_PUSH
kernel.TEST.1:
	; set our data register
	store %cell 200, %cell* %DATA.ptr
	; set our return address again
	store %fnaddr %kernel.TEST.2.addr, %fnaddr* %KRNRET.ptr
	br label %kernel.SP_PUSH
kernel.TEST.2:
	store %fnaddr %kernel.TEST.3.addr, %fnaddr* %KRNRET.ptr
	br label %kernel.SP_SWAP
kernel.TEST.3:
	; yay, we're done, so return
	ret void

kernel.SP_AT:
	; load the memory address that %SP.ptr.ptr resolves to
    %SP.ptr.SP_AT = getelementptr %cell.ptr* %SP.ptr.ptr, i32 0
    %SP.SP_AT = load %cell.ptr* %SP.ptr.SP_AT
    %SP.addr.ptr.SP_AT = getelementptr %cell.ptr %SP.SP_AT, i32 0
    %SP.addr.int.SP_AT = ptrtoint %cell.ptr %SP.addr.ptr.SP_AT to %addr

    ; decrement our integer pointer
    %SP.addr.decr.int.SP_AT = sub %addr %SP.addr.int.SP_AT, 8

    ; resolve our new address as a new pointer
    %SP.addr.decr.ptr.SP_AT = inttoptr %addr %SP.addr.decr.int.SP_AT to %cell.ptr

    ; store it before we go on
    store %cell.ptr %SP.addr.decr.ptr.SP_AT, %cell.ptr* %SP.ptr.ptr

    ; store our memory address at the new location in the stack
    store %addr %SP.addr.int.SP_AT, %addr* %SP.addr.decr.ptr.SP_AT

    ; we're done, return control to whoever called us
    %KRNRET.SP_AT = load %fnaddr* %KRNRET.ptr

    ; here, we have to tell the assembler where the possible return points are
    indirectbr %fnaddr %KRNRET.SP_AT, [ label %kernel.TEST.1,
                                          label %kernel.TEST.2,
                                          label %kernel.TEST.3 ]

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
    %SP.addr.incr.ptr.SP_POP = inttoptr %addr %SP.addr.incr.int.SP_POP to %cell.ptr
    store %cell.ptr %SP.addr.incr.ptr.SP_POP, %cell.ptr* %SP.ptr.ptr

    ; we're done, return control to whoever called us
    %KRNRET.SP_POP = load %fnaddr* %KRNRET.ptr

    ; here, we have to tell the assembler where the possible return points are
    indirectbr %fnaddr %KRNRET.SP_POP, [ label %kernel.TEST.1,
                                          label %kernel.TEST.2,
                                          label %kernel.TEST.3 ]

kernel.SP_PUSH:
	; load the memory address that %SP.ptr.ptr resolves to
    %SP.ptr.SP_PUSH = getelementptr %cell.ptr* %SP.ptr.ptr, i32 0
    %SP.SP_PUSH = load %cell.ptr* %SP.ptr.SP_PUSH
    %SP.addr.ptr.SP_PUSH = getelementptr %cell.ptr %SP.SP_PUSH, i32 0
    %SP.addr.int.SP_PUSH = ptrtoint %cell.ptr %SP.addr.ptr.SP_PUSH to %addr

    ; decrement our stack integer pointer, and store it in the register
    %SP.addr.decr.int.SP_PUSH = sub %addr %SP.addr.int.SP_PUSH, 8
    %SP.addr.decr.ptr.SP_PUSH = inttoptr %addr %SP.addr.decr.int.SP_PUSH to %cell.ptr
    store %cell.ptr %SP.addr.decr.ptr.SP_PUSH, %cell.ptr* %SP.ptr.ptr

    ; store the value in the DATA register at the new memory address
    %DATA.int.SP_PUSH = load %cell* %DATA.ptr
    store %cell %DATA.int.SP_PUSH, %addr* %SP.addr.decr.ptr.SP_PUSH

    ; we're done, return control to whoever called us
    %KRNRET.SP_PUSH = load %fnaddr* %KRNRET.ptr

    ; here, we have to tell the assembler where the possible return points are
    indirectbr %fnaddr %KRNRET.SP_PUSH, [ label %kernel.TEST.1,
                                          label %kernel.TEST.2,
                                          label %kernel.TEST.3 ]

kernel.SP_SWAP:
	; load the memory address that %SP.ptr.ptr resolves to
    %SP.ptr.SP_SWAP = getelementptr %cell.ptr* %SP.ptr.ptr, i32 0
    %SP.SP_SWAP = load %cell.ptr* %SP.ptr.SP_SWAP
    %SP.addr.ptr.SP_SWAP = getelementptr %cell.ptr %SP.SP_SWAP, i32 0
    %SP.addr.int.SP_SWAP = ptrtoint %cell.ptr %SP.addr.ptr.SP_SWAP to %addr

    %A.cell = load %cell* %SP.addr.ptr.SP_SWAP

    %SP.addr.decr.int.SP_SWAP = sub %addr %SP.addr.int.SP_SWAP, 8
    %SP.addr.decr.ptr.SP_SWAP = inttoptr %addr %SP.addr.decr.int.SP_SWAP to %cell.ptr

    %B.cell = load %cell* %SP.addr.decr.ptr.SP_SWAP

    store %cell %B.cell, %cell.ptr %SP.addr.ptr.SP_SWAP
    store %cell %A.cell, %cell.ptr %SP.addr.decr.ptr.SP_SWAP

    ; we're done, return control to whoever called us
    %KRNRET.SP_SWAP = load %fnaddr* %KRNRET.ptr

    ; here, we have to tell the assembler where the possible return points are
    indirectbr %fnaddr %KRNRET.SP_SWAP, [ label %kernel.TEST.1,
                                          label %kernel.TEST.2,
                                          label %kernel.TEST.3 ]
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