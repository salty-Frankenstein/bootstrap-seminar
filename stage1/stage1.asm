;; esi : current number
;; edi : loop var for the main loop, how many bytes to be put
;; ebp : loop var for the nested read byte loop
init:
    mov esi, 0
    mov edi, 0
    jmp loop

;; clear the comments
clear:
    ;; read 1 byte
    push 0
    mov ecx, esp
    ;; sys_read(fd=0, buf=ecx, count=1)
    mov eax, 3
    mov ebx, 0
    mov edx, 1
    int 0x80

    ;; if ch != '\n' goto clear
    pop eax
    cmp eax, 0x0A
    jne clear
    
loop:
    mov ebp, 0

readbyte:
    ;; read 1 byte
    push 0
    ;; sys_read(fd=0, buf=ecx, count=1)
    mov eax, 3
    mov ebx, 0
    mov ecx, esp
    mov edx, 1
    int 0x80

    ;; if EOF done
    cmp eax, 0
    je done

    ;; get char
    pop eax

    ;; if ch == ';' goto clear
    cmp eax, 0x3B
    je clear

    ;; if ch <= 0x20 (white) goto emit
    cmp eax, 0x20 
    jbe emit

    ;; if ch < 0x40 (digits) goto mask
    cmp eax, 0x40
    jb mask

    ;; ch -= 7
    sub eax, 0x7

mask:
    and eax, 0xF
    ;; esi = (esi << 4) | eax
    shl esi, 4
    or esi, eax

    add ebp, 1
    cmp ebp, 2
    jb readbyte  ;; 2 digits = 1 byte

    add edi, 1    
    jmp loop

emit:
    ;; if it reads nothing
    cmp edi, 0
    je loop

    ;; emit byte
    mov eax, esi
    and eax, 0xFF   ;; lower byte
    shr esi, 8

    ;; write byte
    push eax
    mov eax, 4
    mov ebx, 1
    mov ecx, esp
    mov edx, 1
    int 0x80
    pop eax

    sub edi, 1
    cmp edi, 0
    ja emit
    jmp loop

done:
    mov eax, 1
    mov ebx, 0
    int 0x80

