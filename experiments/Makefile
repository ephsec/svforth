EXECUTABLE=forth
LLVMOPT=opt-3.3 -std-link-opts -S
LLVMAS=llvm-as-3.3
LLVMC=llc-3.3

all: forth.ll
	$(LLVMAS) forth.ll
	$(LLVMC) forth.bc
	gcc -o $(EXECUTABLE) $(EXECUTABLE).s
	./$(EXECUTABLE)

optimize:
	$(LLVMOPT) forth.ll > forth.opt.ll
	$(LLVMAS) forth.opt.ll
	$(LLVMC) forth.opt.bc
	gcc -o $(EXECUTABLE).opt $(EXECUTABLE).opt.s
	./$(EXECUTABLE)

clean:
	rm $(EXECUTABLE)
	rm forth.s
	rm forth.bc
	rm forth.opt.ll
	rm forth.opt.bc
	rm forth.opt.s
	rm $(EXECUTABLE).opt
