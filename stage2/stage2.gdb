# usage: gdb -x stage2.gdb ./a.out


layout src
layout regs

# ----- 自动设置全局变量监视 -----
display/x (unsigned int) curnum
display/x (unsigned int) fileoffset
display/x (unsigned int) viraddr
display/x (unsigned int) fixupidx

# ----- 自动设置断点 -----
b _start
# b mask
# b 32 
# b loop
# b 167
# b 67

# 自动运行
run < stage2-linked.hex


