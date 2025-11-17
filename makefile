stage1/stage1.o: stage1/stage1.asm
	nasm -f elf32 -g -F dwarf stage1/stage1.asm -o stage1/stage1.o

stage1/stage1: stage1/stage1.o
	ld -m elf_i386 stage1/stage1.o -o stage1/stage1

# the REAL stage1 bin, written "by HAND"
stage1/stage1_1: stage1/stage1
	stage1/stage1 < stage1/stage1-linked.hex > stage1/stage1_1

test-stage1: stage1/stage1 stage1/stage1-linked.hex stage1/stage1_1
	chmod +x stage1/stage1_1
	stage1/stage1_1 < stage1/stage1-linked.hex > stage1/stage1_2
	@if diff -q stage1/stage1_1 stage1/stage1_2 >/dev/null; then \
		printf "\033[32m✓ Test stage1 passed!\033[0m\n"; \
	else \
		printf "\033[31m✗ Test stage1 failed!\033[0m\n"; \
	fi
	
stage2/stage2.o: stage2/stage2.asm
	nasm -f elf32 -g -F dwarf stage2/stage2.asm -o stage2/stage2.o

stage2/stage2: stage2/stage2.o
	ld -m elf_i386 stage2/stage2.o -o stage2/stage2

# build stage2 bin using the REAL version of stage1 bin
# also they should be equivalent if `test-stage1` is passed
test-stage2: stage2/stage2 stage1/stage1_1 stage2/stage2-linked.hex stage2/stage2.hex
	stage1/stage1_1 < stage2/stage2-linked.hex > stage2/stage2_1
	chmod +x stage2/stage2_1
	stage2/stage2_1 < stage2/stage2.hex > stage2/stage2_2
	@if diff -q stage2/stage2_1 stage2/stage2_2 >/dev/null; then \
		printf "\033[32m✓ Test stage2 passed!\033[0m\n"; \
	else \
		printf "\033[31m✗ Test stage2 failed!\033[0m\n"; \
	fi

test: test-stage1 test-stage2

clean-stage1:
	rm -f stage1/stage1 stage1/stage1.o stage1/stage1_1 stage1/stage1_2

clean-stage2: clean-stage1
	rm -f stage2/stage2 stage2/stage2.o stage2/stage2_1 stage2/stage2_2

clean: clean-stage1 clean-stage2
