# bootstrap seminar

Bootstrapping a Programming Language from Nothing

- Hex to Bin
- Labels
- Strings

## Forth implementation

### Core Language
Stack Manipulation
- [x] `dup`
- [x] `drop`
- [x] `swap`

Memory Access
- [x] `@`
- [x] `!`
- [x] `@b`
- [x] `!b`

Input/Output

- [x] `get-char`
- [x] `put-char`
- [x] `put-string`

String Manipulation
- [x] `read`
- [ ] `unread`
- [x] `string==`
- [x] `parse-number`

Interpreter Functionality
- [ ] `find-word`
- [ ] `word-name`
- [ ] `execute`
- [ ] `read-eval-print`

Code Generation
- [ ] `:`
- [ ] `;`
- [ ] `immediate`
- [ ] `emit-byte`
- [ ] `emit-word`
- [ ] `emit-offset`

Information

- [x] `head@`
- [x] `free@`
- [x] `old-esp@`
- [x] `fd-in@`
- [x] `fd-out@`
- [x] `stack-min@`
- [x] `stack-size`
- [x] `stack-curr@`

### Standard Libaray (TODO)


## Makefile

Build & Test:
```shell
make test
```

Clean up:
```shell
make clean
```

