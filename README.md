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
- [ ] `@`
- [ ] `!`
- [ ] `@b`
- [ ] `!b`

Input/Output

- [ ] `get-char`
- [ ] `put-char`
- [ ] `put-string`

String Manipulation
- [ ] `read`
- [ ] `unread`
- [ ] `string==`
- [ ] `parse-number`

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

- [ ] `head@`
- [ ] `free@`
- [ ] `old-esp@`
- [ ] `fd-in@`
- [ ] `fd-out@`
- [ ] `stack-min@`
- [ ] `stack-size`
- [ ] `stack-curr@`

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

