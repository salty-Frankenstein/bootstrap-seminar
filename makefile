stage1/stage1.o: stage1/stage1.asm
	nasm -f elf32 -g -F dwarf stage1/stage1.asm -o stage1/stage1.o

# the golden version of stage1
stage1/stage1: stage1/stage1.o
	ld -m elf_i386 stage1/stage1.o -o stage1/stage1

# the REAL stage1 bin, written "by HAND"
stage1/stage1_1: stage1/stage1
	stage1/stage1 < stage1/stage1-linked.hex > stage1/stage1_1
	chmod +x stage1/stage1_1

# the hand-written version complies itself
test-stage1: stage1/stage1-linked.hex stage1/stage1_1
	stage1/stage1_1 < stage1/stage1-linked.hex > stage1/stage1_2
	@if diff -q stage1/stage1_1 stage1/stage1_2 >/dev/null; then \
		printf "\033[32m✓ Test stage1 passed!\033[0m\n"; \
	else \
		printf "\033[31m✗ Test stage1 failed!\033[0m\n"; \
	fi
	
stage2/stage2.o: stage2/stage2.asm
	nasm -f elf32 -g -F dwarf stage2/stage2.asm -o stage2/stage2.o

# the golden version of stage2
stage2/stage2: stage2/stage2.o
	ld -m elf_i386 stage2/stage2.o -o stage2/stage2

# the hand-written version of stage2 is compiled by REAL stage1
stage2/stage2_1: stage1/stage1_1 stage2/stage2-linked.hex 
	stage1/stage1_1 < stage2/stage2-linked.hex > stage2/stage2_1
	chmod +x stage2/stage2_1

# stage2 should be able to LINK itself
# which should be equivalent to the hand-written version
test-stage2: stage2/stage2_1 stage2/stage2.hex
	stage2/stage2_1 < stage2/stage2.hex > stage2/stage2_2
	@if diff -q stage2/stage2_1 stage2/stage2_2 >/dev/null; then \
		printf "\033[32m✓ Test stage2 passed!\033[0m\n"; \
	else \
		printf "\033[31m✗ Test stage2 failed!\033[0m\n"; \
	fi

stage3/stage3.o: stage3/stage3.asm
	nasm -f elf32 -g -F dwarf stage3/stage3.asm -o stage3/stage3.o

# the golden version of stage3
stage3/stage3: stage3/stage3.o
	ld -m elf_i386 stage3/stage3.o -o stage3/stage3

# use REAL stage2 to LINK and get stage3 binary
stage3/stage3_1: stage2/stage2_1 stage3/stage3.hex
	stage2/stage2_1 < stage3/stage3.hex > stage3/stage3_1
	chmod +x stage3/stage3_1

# first, stage3 should compile the "stage2 version" of itself just as stage2
# also, it should support strings, output the same program
test-stage3: stage3/stage3_1 stage2/stage2_1
	stage2/stage2_1 < stage3/stage3.hex > stage3/out1
	chmod +x stage3/out1
	stage3/stage3_1 < stage3/stage3.hex > stage3/out2
	@if diff -q stage3/out1 stage3/out2 >/dev/null; then \
		stage3/stage3_1 < stage3/stage3-str.hex > stage3/out3;	\
		if diff -q stage3/out1 stage3/out3 >/dev/null; then \
			printf "\033[32m✓ Test stage3 passed!\033[0m\n"; \
		else \
			printf "\033[31m✗ Test stage3 failed!\033[0m\n"; \
		fi \
	else \
		printf "\033[31m✗ Test stage3 failed!\033[0m\n"; \
	fi

stage4/stage4: stage3/stage3_1 stage4/stage4.hex
	stage3/stage3_1 < stage4/stage4.hex > stage4/stage4
	chmod +x stage4/stage4

test-stage4: stage4/stage4
	gdb -x ./stage4/stage4.gdb stage4/stage4

stage5/stage5: stage3/stage3_1 stage5/stage5.hex
	stage3/stage3_1 < stage5/stage5.hex > stage5/stage5
	chmod +x stage5/stage5

test-stage5: stage5/stage5
	gdb -x ./stage5/stage5.gdb stage5/stage5

test: test-stage1 test-stage2 test-stage3

clean-stage1:
	rm -f stage1/stage1 stage1/stage1.o stage1/stage1_1 stage1/stage1_2

clean-stage2: clean-stage1
	rm -f stage2/stage2 stage2/stage2.o stage2/stage2_1 stage2/stage2_2

clean-stage3: clean-stage2
	rm -f stage3/stage3 stage3/stage3.o stage3/stage3_1 stage3/out1 stage3/out2 stage3/out3

clean-stage4: clean-stage3
	rm -f stage4/stage4

clean-stage5: clean-stage3
	rm -f stage5/stage5

clean: clean-stage1 clean-stage2 clean-stage3 clean-stage4 clean-stage5
