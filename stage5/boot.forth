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

# some useful helpers
: head head@ @ ; ( -- addr )
: =head head@ swap ! ; ( addr --)
: fd-in fd-in@ @ ; ( -- fd )
: =fd-in fd-in@ swap ! ; ( fd -- )
: fd-out fd-out@ @ ; ( -- fd )
: =fd-out fd-out@ swap ! ; ( fd -- )

# a helper to define words manually
# usage: define-word word-name
: define-word
0 emit-byte read emit-string head emit-word current-pos =head
; 

# define multiplication
define-word *
0x8B emit-byte 0x47 emit-byte 4 emit-byte     # mov eax, [edi+4]
0x0F emit-byte 0xAF emit-byte 0x07 emit-byte  # imul eax, [edi]
0x81 emit-byte 0xC7 emit-byte 4 emit-word     # add edi, 4
0x89 emit-byte 0x07 emit-byte                 # mov [edi], eax
0xC3 emit-byte

# define division
define-word /
0x8B emit-byte 0x47 emit-byte 4 emit-byte     # mov eax, [edi+4]
0x99 emit-byte                                # cdq
0xF7 emit-byte 0x3F emit-byte                 # idiv [edi]
0x81 emit-byte 0xC7 emit-byte 4 emit-word     # add edi, 4
0x89 emit-byte 0x07 emit-byte                 # mov [edi], eax
0xC3 emit-byte

# define modulus
define-word %
0x8B emit-byte 0x47 emit-byte 4 emit-byte     # mov eax, [edi+4]
0x99 emit-byte                                # cdq
0xF7 emit-byte 0x3F emit-byte                 # idiv [edi]
0x81 emit-byte 0xC7 emit-byte 4 emit-word     # add edi, 4
0x89 emit-byte 0x17 emit-byte                 # mov [edi], edx
0xC3 emit-byte

# define shifr right 4
define-word shr4
0xC1 emit-byte 0x2F emit-byte 0x4 emit-byte    # shr [edi], 4
0xC3 emit-byte

# define relational operator
: define-rel # usage: opcode define-rel word-name
  define-word 
  0x8B emit-byte 0x47 emit-byte 4 emit-byte     # mov eax, [edi+4]
  0x8B emit-byte 0x0F emit-byte                 # mov ecx, [edi]
  0x81 emit-byte 0xC7 emit-byte 4 emit-word     # add edi, 4
  0x39 emit-byte 0xC8 emit-byte                 # cmp eax, ecx
  0x0F emit-byte emit-byte 7 emit-word          # j? label
  0xC7 emit-byte 0x07 emit-byte 0 emit-word     # mov [edi], 0
  0xC3 emit-byte                                # ret
  # label:
  0xC7 emit-byte 0x07 emit-byte 1 emit-word     # mov [edi], 1
  0xC3 emit-byte                                # ret
;

0x8C define-rel <
0x8E define-rel <=
0x8F define-rel >
0x8D define-rel >=
0x82 define-rel u<
0x86 define-rel u<=
0x87 define-rel u>
0x83 define-rel u>=

: put-number-digit ( number -- LSD number' ) # print the least significant digit
  dup 10 % 0x30 + swap 10 / 
;

: hex-digit dup 10 < if 0x30 + else 0x37 + fi ;

: put-hex-digit dup 0x0F and hex-digit swap shr4 ;

: put-number'  ( number -- digits ) # convert to digits recursively
  put-number-digit
  dup 0 == if drop return else fi
  put-number'
;

: put-hex'
  put-hex-digit
  dup 0 == if drop return else fi
  put-hex'
;

: put-number-rec ( number -- ) # print number helper
  dup 0xFFFFFFFF == if return else put-char fi
  put-number-rec
;

: put-number ( number -- ) # print number in decimal, signed
  dup 0 < if 0 swap - 0x2D put-char else fi   # print '-' if negative
  0xFFFFFFFF swap put-number' put-number-rec drop
;

: put-hex ( number -- ) # print number in hexadecimal
  0x30 put-char 0x78 put-char    # print "0x"
  0xFFFFFFFF swap put-hex' put-number-rec drop
;

: cr 0x0A put-char ;
: space 0x20 put-char ;
: . put-number cr ;
: .x put-hex cr ;

# global variable definition

# first, we need a pointer to the free memory to be allocated
: free-var@ 0x200024 ;
: free-var free-var@ @ ; 
: =free-var free-var@ swap ! ;

# make it point to the next free memory location
0x200028 =free-var

: allocate-var  ( -- addr ) # allocate 4 bytes for a variable
  free-var dup 4 + =free-var
; 

# then, we can define global variables
: define-var  # usage: define-var var-name
  drop
  # make a constructor word for the variable
  define-word
  # allocate 4 bytes for the variable, it returns the address of the variable
  0x81 emit-byte 0xEF emit-byte 4 emit-word  # sub edi, 4
  0xC7 emit-byte 0x07 emit-byte 
  allocate-var dup emit-word                 # get the addr of the variable: mov [edi], addr
  0 !                                        # initialize it to 0
  0xC3 emit-byte                             # ret
  1
; immediate

: defvar  # usage: defvar varname@ varname =varname
  drop
  # first, make a word to get the address of the variable
  define-word
  # allocate 4 bytes for the variable, it returns the address of the variable
  0x81 emit-byte 0xEF emit-byte 4 emit-word  # sub edi, 4
  0xC7 emit-byte 0x07 emit-byte 
  allocate-var dup emit-word                 # get the addr of the variable: mov [edi], addr
  dup 0 !                                    # initialize it to 0, make sure addr is still on stack
  0xC3 emit-byte                             # ret

  # then, make a word to get the value of the variable
  define-word
  0x81 emit-byte 0xEF emit-byte 4 emit-word    # sub edi, 4
  0x8B emit-byte 0x05 emit-byte dup emit-word  # mov eax, [addr]
  0x89 emit-byte 0x07 emit-byte                # mov [edi], eax
  0xC3 emit-byte                               # ret

  # finally, make a word to set the value of the variable
  define-word
  0x8B emit-byte 0x07 emit-byte                # mov eax, [edi]
  0x81 emit-byte 0xC7 emit-byte 4 emit-word    # add edi, 4
  0x89 emit-byte 0x05 emit-byte emit-word      # mov [addr], eax
  0xC3 emit-byte                               # ret

  1
; immediate

defvar stack-max@@ stack-max@ =stack-max@   # define a global variable stack-max
stack-curr@ =stack-max@                     # initialize it to be the maximum address of stack
defvar data-top@@ data-top@ =data-top@      # define a global variable data-top
0x600000 =data-top@                         # initialize it to be the start address of data segment

: print-stack-rec ( addr -- ) # print stack recursively
  dup 4 - stack-curr@ <=
  if drop return else fi
  dup @ put-number space
  4 - print-stack-rec
;

: print-stack-rec-x ( addr -- ) # print stack recursively, hexadecimal
  dup 4 - stack-curr@ <=
  if drop return else fi
  dup @ put-hex space
  4 - print-stack-rec-x
;

: print-stack
  0x28 put-char space
  stack-max@ 4 - print-stack-rec
  0x29 put-char cr
;

: print-stack-x
  0x28 put-char space
  stack-max@ 4 - print-stack-rec-x
  0x29 put-char cr
;

: print-words-rec
  dup word-name put-string cr
  4 - @ dup
  if else return fi
  print-words-rec
;

: print-words head print-words-rec ;

: '     # start a character literal
  drop get-char 1
; immediate

: read-string     # read a string literal
  get-char
  dup 0x22 == if drop return else fi
  data-top@ swap !b data-top@ 1 + =data-top@  # store the character and advance data-top
  read-string
; 

: "     # string literal
  drop 
  data-top@  # get the starting address, and return
  read-string
  1
; immediate
