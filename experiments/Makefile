EXECUTABLE=forth
LLVMAS=llvm-as-3.3
LLVMC=llc-3.3

all: forth.ll
	$(LLVMAS) forth.ll
	$(LLVMC) forth.bc
	gcc -o $(EXECUTABLE) $(EXECUTABLE).s
	./$(EXECUTABLE)

clean:
	rm $(EXECUTABLE)
	rm forth.s
	rm forth.bc
