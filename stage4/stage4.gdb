# usage: gdb -x stage4.gdb ./stage4

# ----- 自动设置断点 -----
b *0x10094
# b mask
# b 32 
# b loop
# b 167
# b 67

# 自动运行
# run < stage2-linked.hex
run

layout asm
layout regs
