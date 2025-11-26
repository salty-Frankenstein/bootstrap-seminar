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

tui focus cmd

# print top 5 numbers on the stack
define fs
  x/5wx $edi
end

# 手动ni跳过call
define cn
    # 下一条指令地址
    set $next = $eip + 5
    # 临时断点
    tbreak *$next
    # 继续运行
    continue
end