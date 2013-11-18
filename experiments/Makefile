EXECUTABLE=forth-kernel
BUGPOINT=bugpoint-3.3 -run-int
LLVMOPT=opt-3.3 -Oz -S
LLVMAS=llvm-as-3.3 -regalloc=greedy
LLVMC=llc-3.3
#LLVMC=llc-3.3 -regalloc=iterativescan

all: forth-kernel.ll
	$(LLVMAS) forth-kernel.ll
	$(LLVMC) forth-kernel.bc
	clang -o $(EXECUTABLE) $(EXECUTABLE).s
	time ./$(EXECUTABLE)

optimize:
	$(LLVMOPT) forth-kernel.ll > forth-kernel.opt.ll
	$(LLVMAS) forth-kernel.opt.ll
	$(LLVMC) forth-kernel.opt.bc
	clang -o $(EXECUTABLE).opt $(EXECUTABLE).opt.s
	time ./$(EXECUTABLE).opt

bugpoint:
	$(LLVMOPT) forth.ll > forth.opt.ll
	$(LLVMAS) forth.opt.ll
	$(LLVMC) forth.opt.bc
	$(BUGPOINT) forth.opt.bc
	clang -o $(EXECUTABLE).opt $(EXECUTABLE).opt.s
	time ./$(EXECUTABLE).opt

clean:
	rm $(EXECUTABLE)
	rm forth.s
	rm forth.bc
	rm forth.opt.ll
	rm forth.opt.bc
	rm forth.opt.s
	rm $(EXECUTABLE).opt
