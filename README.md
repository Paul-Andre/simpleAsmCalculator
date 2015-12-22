# simpleAsmCalculator

A toy calculator for 32bit integers written in assembly.

Assemble and link instructions for x86 linux:
```bash
nasm -felf calculator.asm
ld -o calculator calculator.o
```

For x64 linux, it should be something like the following, though I haven't tested it yet:
```bash
nasm -felf32 calculator.asm
ld -0 calculator -m32 calculator.o
```

It uses 32-bit signed integers, lets you control the order of operations with parantheses and supports the following binary operations:
* add: "+"
* subtract: "-"
* multiply: "*"
* high word of multiplication: "**"
* divide: "/"
* modulo: "%" or "//"
* exponent: "^"
* bit-wise or: "|"
* bit-wise and: "&"
* bit-wise xor: "$xor"
