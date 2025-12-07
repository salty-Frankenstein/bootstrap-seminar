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

0x1 0x2 +
0x2 -
