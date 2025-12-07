: define-operator
  0 emit-byte
  read
  emit-string
  head@ @ emit-word
  head@ free@ @ !

  0x8B emit-byte
  0x07 emit-byte

  emit-byte

  0x47 emit-byte
  4 emit-byte
  0x81 emit-byte
  0xC7 emit-byte
  4 emit-word
  0xC3 emit-byte
;

0x01 define-operator +
0x29 define-operator -
0x21 define-operator and
0x09 define-operator or
0x31 define-operator xor

: current-pos free@ @ ;

: if
  drop

  0x8B emit-byte 0x07 emit-byte
  0x81 emit-byte 0xC7 emit-byte 4 emit-word
  0x81 emit-byte 0xF8 emit-byte 0 emit-word
  0x0F emit-byte 0x84 emit-byte 

  current-pos
  0 emit-word

  1
; immediate

: else
  drop

  0xE9 emit-byte
  current-pos

  0 emit-word
  swap
  dup
  4 + current-pos swap - !
  1
; immediate

: fi 
  drop
  dup
  4 + current-pos swap - !
  1
; immediate

: return 
  0xC3 emit-byte
; immediate

: ==
  - if 0 else 1 fi
;

: consume-until
  dup
  get-char 
  dup 0xFFFFFFFF ==
  if drop return 
  else 
    == if drop return
    else consume-until
    fi
  fi
;

: ( 0x29 consume-until ; immediate
: # 0x0A consume-until ; immediate

( now we can use comments )
0x1 0x2 + 

# this is also a comment 
3 ==
