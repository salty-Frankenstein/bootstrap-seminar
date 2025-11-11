def to_twos_complement_hex(num, bits=32):
    """
    将有符号十进制整数转换为指定位宽的十六进制补码表示。
    例如：-22 -> FFFFFFEA
    """
    if num < 0:
        num = (1 << bits) + num  # 负数转补码
    # 限制在指定位宽范围内
    num &= (1 << bits) - 1
    # 转成大写十六进制，不带 0x 前缀
    return f"{num:0{bits // 4}X}"


# 示例使用
if __name__ == "__main__":
    while True:
        s = input("请输入一个有符号10进制数（或输入 q 退出）：")
        if s.lower() == 'q':
            print("程序结束。")
            break
        try:
            val = int(s)
            hex_str = to_twos_complement_hex(val)
            print(f"{val} 的32位十六进制补码为：{hex_str}")
        except ValueError:
            print("请输入一个有效的整数！")

