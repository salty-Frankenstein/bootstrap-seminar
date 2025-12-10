# bootstrap seminar

Bootstrapping a Programming Language from Nothing

## Basic Hex editing
- Hex to Bin
- Labels
- Strings

## Forth implementation

### Core Language
A `string` is a 32bit pointer.

Stack Manipulation
- [x] `dup`: `( n -- n n )`
- [x] `drop`: `( n -- )`
- [x] `swap`: ` ( n1 n2 -- n2 n1 )`

Memory Access
- [x] `@`: ` ( addr -- value )` read address
- [x] `!`: ` ( addr value -- )` write address
- [x] `@b`: `( addr -- byte )` read byte
- [x] `!b`: `( addr byte -- )` write byte

Input/Output

- [x] `get-char`: `( -- char )` read a char from input stream
- [x] `put-char`: `( char -- )` write a char to output stream
- [x] `put-string`: `( string -- )` write a string to output stream

String Manipulation
- [x] `read`: `( -- string )` read a line from input stream into the string buffer
- [ ] `unread`: 
- [x] `string==`: `( string1 string2 -- flag )` compare two strings, return 1 if equal, 0 if not equal
- [x] `parse-number`: `( string -- number ok )` parse a number from string, support decimal and hexadecimal (prefix 0x). Return the number and `ok=1` if successful, `ok=0` if not a number.
- [x] `parse-digit`: `( char -- digit )` parse a digit, return -1 if not a digit
- [x] `string-copy`: `( src dest -- len )` copy a string from `src` to `dest`, return its length, null terminator included.

Interpreter Functionality
- [x] `find-word`: `( string -- wordptr immediate )` find a word by its name, return the pointer to the word and immediate flag, if not found, return `0 0`.
- [x] `word-name`: `( wordptr -- string )` get the name of a word
- [x] `execute`: `( wordptr -- )` execute a word by its pointer
- [x] `read-eval-print`: `( -- )` the REPL loop, return when EOF

Code Generation
- [x] `:`: `( -- )` start a new word definition
- [x] `;`: `( -- )` end a word definition
- [x] `immediate`: `( -- )` make the current word immediate
- [x] `emit-byte`: `( byte -- )` emit a byte to free text space
- [x] `emit-word`: `( word -- )` emit a 4-byte word to free text space
- [x] `emit-offset`: `( offset -- )` emit a 4-byte offset to free text space
- [x] `emit-string`: `( string -- )` emit a string to free text space

Information

- [x] `head@`: `( -- addr )` get the lastes defined word address
- [x] `free@`: `( -- addr )` get the free text space pointer
- [x] `old-esp@`: `( -- addr )` get the original esp
- [x] `fd-in@`: `( -- fd )` get the input file descriptor
- [x] `fd-out@`: `( -- fd )` get the output file descriptor
- [x] `stack-min@`: `( -- addr )` get the minimum address of the forth stack
- [x] `stack-size`: `( -- size )` get the size of the forth stack
- [x] `stack-curr@`: `( -- addr )` get the current top address of the forth stack

### Standard Libaray 

Arithmetic Operations

- [x] `+`, `-`, `*`, `/`, `%`, `and`, `or`, `xor`
- [x] `==`, `<`, `<=`, `>`, `>=`, `u<`, `u<=`, `u>`, `u>=`

Control Flow

- [x] `if`, `else`, `fi`
- [x] `return`

Comments

- [x] `(`, `#`

I/O

- [x] `put-number`, `put-hex`, `cr`, `space`
- [x] `.`, `.x` 

Global Variables

- [x] `define-var`

Debugging

- [x] `print-stack`

Information about the Interpreter

- [x] `head`, `=head`, `current-pos`, `fd-in`, `=fd-in`, `fd-out`, `=fd-out`
- [x] `stack-max@` 

## Makefile

Build & Test:
```shell
make test
```

Clean up:
```shell
make clean
```

