count = 0
print("输入回车计数一次，输入 r 回车重新开始，输入 q 回车退出。")

while True:
    key = input()
    if key.lower() == 'q':
        print("程序结束。")
        break
    elif key.lower() == 'r':
        count = -1
        print("计数已重置为 0。")
    count += 1
    print(f"你已经按了 {count} 次。")

