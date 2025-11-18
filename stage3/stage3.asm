global _start

section .data
fileoffset:    dd 0        ; fileoffset, the next empty byte of out
viraddr:       dd 0        ; 
curnum:        dd 0        ; 
fixupidx:      dd 0        ; index of the fixup table

section .bss
out:  resb 0x20000   
label:  resb 0x20000   
fixup:  resb 0x8000000  

section .text

_start:
    ;; edi: bytes rea
    mov edi, 0
    jmp loop

clearcomment:
    call readbyte
    cmp eax, 0x0A       ;; if ch != '\n' goto clear
    jne clearcomment

loop:
    mov ebp, 0          ;; loop variable: read number twice

startread:
    call readbyte

    cmp eax, 0x3B       ;; if ch == ';' goto clear
    je clearcomment

    cmp eax, 0x40       ;; if ch != '@' goto notat
    jne notat
    mov eax, [curnum]   ;; viraddr <- curnum
    mov [viraddr], eax
    mov dword [curnum], 0
    mov edi, 0          ;; size of curnum = 0 !!
    jmp loop

notat:
    cmp eax, 0x3A           ;; if ch != ':' goto notcolon
    jne notcolon

    call readlabel          ;; the result hash is in esi
    shl esi, 3              ;; an entry has 8 bytes
    mov eax, [fileoffset]   ;; label[hash].file <- fileoffset 
    mov [esi+label], eax    
    mov eax, [viraddr]      ;; label[hash].vir <- viraddr
        
    mov [esi+label+4], eax  
    jmp loop

notcolon:
    mov ecx, eax            ;; here we handle '=' and '-'
    push eax                ;; save eax == ch
    xor ecx, 0x2D
    and ecx, 0xFFFFFFEF
    cmp ecx, 0
    jne not2D3D             ;; if ch != 2D or 3D

    call readlabel
    mov eax, [fixupidx]     ;; fixup[fixupidx].out <- fileoffset
    mov ebx, [fileoffset]
    mov [eax+fixup], ebx

    shl esi, 3              ;; vaddridx of hash 
    add esi, label+4        
                
    add eax, 4              ;; fixup[fixupidx].label <- vaddridx
    add [eax+fixup], esi
    
    add dword [fixupidx], 8 ;; point to the next entry

    ;; if ch == 0x2D, relative substract from output in advance
    pop eax
    xor eax, 0x2D           ;; now eax is either 3D or 2D
    shr eax, 4              ;; 0 or 1
    sub eax, 1              ;; mask
    mov ebx, [viraddr]      ;; ebx <- viraddr + 4
    add ebx, 4
    and ebx, eax            ;; assign only when eax == 2D
    mov eax, [fileoffset]
    sub [eax+out], ebx

    add dword [fileoffset], 4       ;; point to the next number
    add dword [viraddr], 4          ;; update viraddr!!
    jmp loop

not2D3D:
    cmp eax, 0x24           ;; if ch != '$' goto notdollar
    jne notdollar

    call readlabel
    mov eax, [fixupidx]     ;; fixup[fixupidx].out <- fileoffset
    mov ebx, [fileoffset]
    mov [eax+fixup], ebx

    shl esi, 3              ;; fileaddridx of hash 
    add esi, label
    
    add eax, 4              ;; fixup[fixupidx].label <- fileidx
    add [eax+fixup], esi
    
    add dword [fixupidx], 8          ;; point to the next entry
    
    add dword [fileoffset], 4       ;; point to the next number
    add dword [viraddr], 4          ;; update viraddr!!
    jmp loop

notdollar:
    cmp eax, 0x22           ;; if ch == "\"" goto readstring
    je readstring

    ;; the origin logic of stage 1
    cmp eax, 0x20           ;; if ch <= 0x20(white) goto emit
    jbe emit

    cmp eax, 0x40           ;; if ch < 0x40 (digits) goto mask
    jb mask

    sub eax, 0x7            ;; ch -= 7

mask:
    and eax, 0xF
    shl dword [curnum], 4         ;; esi = (esi << 4) | eax
    or [curnum], eax

    add ebp, 1
    cmp ebp, 2
    jb startread            ;; 2 digits = 1 byte

    add edi, 1              ;; byte read + 1
    jmp loop

emit:
    cmp edi, 0              ;; if it reads nothing
    je loop

    mov eax, [fileoffset]   ;; write 1 byte
    mov ebx, [curnum]
    mov [eax+out], bl       ;; out[fileoffset] = curnum
    shr dword [curnum], 8

    add dword [fileoffset], 1     ;; point to next byte
    add dword [viraddr], 1        ;; update viraddr

    sub edi, 1              ;; count byte to emit
    cmp edi, 0
    ja emit
    jmp loop

readbyte:   ; read a byte, return in eax
    push 0
    mov eax, 3
    mov ebx, 0
    mov ecx, esp
    mov edx, 1
    int 0x80

    ; HACK: if read EOF, do fixup
    cmp eax, 0
    je done

    ;; get char
    pop eax
    ret

readstring:         ;; read a string
    call readbyte
    
    cmp eax, 0x22    ;; if ch == "\"" goto loop
    je loop

    cmp eax, 0x5C    ;; if ch == "\\" read another
    jne putchar
    call readbyte

putchar:
    mov ebx, [fileoffset]   ;; out[fileoffset] <- ch
    mov [ebx+out], eax
    add dword [fileoffset], 1     ;; fileoffset++; viraddr++
    add dword [viraddr], 1
    jmp readstring

readlabel:          ;; read a label, get the hash value
                    ;; return in esi
                    ;; a label is up to 4 bytes
    mov esi, 0
inner:
    call readbyte

    cmp eax, 0x20   ;; if ch == is white goto iswhite
    jbe iswhite

    and eax, 0x3F
    shl esi, 6      ;; esi = (esi << 6) | eax
    or esi, eax
    
    jmp inner

iswhite:
    ret
    
done:                   ;; after reading fill fixup
    mov edi, fixup      ;; edi: index, base
    mov ecx, [fixupidx] ;; ecx: boundary
    add ecx, fixup

fixuploop:
    mov eax, [edi]      ;; eax <- output pointer
    mov ebx, [edi+4]    ;; ebx <- label pointer

    mov ebx, [ebx]
    add [eax+out], ebx  ;; [outputptr] += [labelptr]

    add edi, 8          ;; point to the next entry
    cmp edi, ecx        ;; if edi < fixupidx goto fixuploop
    jb fixuploop

output:                 ;; then output
    mov eax, 4          ;; use one write call to output everything
    mov ebx, 1
    mov ecx, out
    mov edx, [fileoffset]
    int 0x80

    ;; exit(0)
    mov eax, 1
    mov ebx, 0
    int 0x80

