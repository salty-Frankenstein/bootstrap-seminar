# usage: gdb -x stage4.gdb ./stage4

# ----- 自动设置断点 -----
# b *0x10094

# for string test
b *0x1010a

# 自动运行
run < stage4/tests/test.txt
# run

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