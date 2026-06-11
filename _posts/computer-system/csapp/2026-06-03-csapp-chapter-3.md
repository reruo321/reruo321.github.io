---
title: CS:APP Chapter 3
description: 3. Machine-Level Representation of Programs
layout: post
date: 2026-06-03
media_subpath: /pics/computer-system/csapp/csapp-chapter-3/
image:
    path: ../../../../assets/img/thumbnails/csapp3e-cover.jpg
categories: [computer-system, csapp]
tags: [CS:APP]
math: true
---

> DISCLAIMER: This post is written by a non-native English speaking student. It may contain any incorrect information or improper expressions.
{: .prompt-warning }

# 3. Machine-Level Representation of Programs
## 3.1 A Historical Perspective
Each successive processor has been designed to be backward compatible.

* Intel: Intel Architecture 32-bit (IA32) → Intel 64 (x86-64)
* Intel 64 = x86-64 = x64 = AMD64
* Moore's Law: The prediction that number of transistors per chip would double every year for the next 10 years. ― This is dead because doubling has slowed to roughly every 2.5~3 years today.

---

## 3.2 Program Encodings
```bash
gcc -0g -o p p1.c p2.c
```

The `gcc` command invokes an entire sequence of programs to turn the source code into executable code.

1. **C preprocessor**: Expands source code + files specified with `#include` commands + macros specified with `#define` declarations.
2. **Compiler**: Generates assembly code versions of `p1.c` and `p2.c`, `p1.s` and `p2.s`.
3. **Assembler**: Converts the assembly code into binary object-code files `p1.o` and `p2.o`. Object code is one form of machine code.
4. **Linker**: Merges two object-code files along with code implementing library functions (e.g., `printf`) and generates the final executable code file `p`.

* **Object code**: Contains binary representations of all of the instructions, but the addresses of global values are not yet filled in.
* **Executable code**: Exact form of code that is executed by the processor.

---

### 3.2.1 Machine-Level Code
Among different forms of abstraction that computer systems employ, these are especially important for machine-level programming.

1. **Instruction Set Architecture(ISA)**: Defines the format and behavior of a machine-level program. Most ISAs, including x86-64, describe the behavior of a program as if each instruction is executed in sequence.
2. **Virtual Address**: The memory addresses used by a machine-level program. The actual implementation of the memory system involves a combination of multiple hardware memories and operating system software.

The assembly-code representation is very close to machine code, while it is in a more readable textual format, as compared to the binary format of machine code.
The machine code for x86-64 differs greatly from the original C code.

* Parts of the processor state are visible that normally are hidden from the C programmer.
* Whereas C provides a model in which objects of different data types can be declared and allocated in memory, machine code views the memory as simply a large byte-addressable array.

The program memory contains the executable machine code for the program. It is addressed using virtual addresses. At any given time, only limited subranges of virtual addresses are considered valid.

#### The Machine Code for x86-64

* The program counter (PC, `%rip`) indicates the address in memory of the next instruction to be executed.
* The integer "register file" contains 16 named locations storing 64-bit values. They can hold addresses or integer data.
* The condition code registers hold status information about the most recently executed arithmetic or logical instruction. These are used to implemet conditional changes in the control or data flow, such as is required to implement `if` and `while` statements.
* A set of vector registers can each hold one or more integer or floating-point values.

#### ISA in Modern Computer System
The execution units do **dynamic execution (Out-of-order execution)** to execute multiple instructions concurrently, and the temporary results for the instructions are put in a reorder buffer.

Meanwhile, the retirement unit watches the reorder buffer, takes only the finished results, and permanently write them to the architectural registers/memory in the exact sequential order of the original program. This is called **in-order retirement**.

Therefore, the instructions seem to be executed one by one in order, even if they are actually be executed concurrently in the computer system.

* [Out-of-order execution - Wikipedia](https://en.wikipedia.org/wiki/Out-of-order_execution)

---

### 3.2.2 Code Examples
```bash
gcc -0g -S mstore.c
```

The GCC option `-S` generates an assembly file and go no further.

```bash
gcc -0g -c mstore.c
```

The GCC option `-c` both compiles and assembles the code.

```bash
objdump -d mstore.o
```

The OBJDUMP option `-d` disassembles executable sections of a binary file.

Several features about machine code and its disassembled representation are worth noting:

* x86-64 instructions can range in length from 1 to 15 bytes.
    * Bytes: Commonly used instructions < Less common instructions
    * Bytes: Instructions with fewer operands < Instructions with more operands

* The instruction format uses a unique decoding of the bytes into machine instructions from a given starting position.
    * Example: `pushq %rbx` can start with byte value 53.

* The disassembler uses a slightly different naming convention for the instructions that does the assembly code generated by GCC.
    * Example: GCC (`movq`, `pushq`) vs Disassembler (`mov`, `push`)
    * Example: GCC (`call`, `ret`) vs Disassembler (`callq`, `retq`)

Generating the actual executable code requires running a linker on the set of object-code files, where a function `main` must be included.

```bash
gcc -0g -o prog main.c mstore.c
objdump -d prog
```

![exprog](exprog.png)

##### Differences:

1. The linker has shifted the location of the code to a different range of addresses.
2. The linker has filled in the address that the `callq` instruction should use in calling the function `mult2`.
3. Two additional `nop`s have added. They will have no effect on the program, but they have been inserted to grow the code for the function to 16 bytes. It enables a better placement of the next block of code in terms of memory system performance.

---

### 3.2.3 Notes on Formatting
* **Directive**: The line beginning with `.`.

#### ATT vs Intel Assembly-code Formats
```bash
gcc -0g -S -masm=intel mstore.c
```

* The Intel code omits the size designation suffixes.
* The Intel code omits the `%` character in front of register names.
* The Intel code has a different way of describing locations in memory.
    * Example: Intel `DWORD PTR [rbx]` vs ATT `(%rbx)`
* Instructions with multiple operands list them in the reverse order.

---

## 3.3 Data Formats
Intel uses the term "word" to refer to a 16-bit data type.

* **Word**: 16-bit data type
* **Double (Word), DWORD, Long Word**: 32-bit data type
* **Quad (Word), QWORD**: 64-bit data type

![3-1](3-1.png)

##### Notes
* Note 1: Assembly-code suffix `l` for `int` is derived from "long word", which is 32 bit as double word. Another `l` for `double` is from "long float".
* Note 2: Assembly-code suffix `s` for `float` stands for "single", as in single-precision floating-point.
* Note 3: In the Linux/macOS model LP64, both `long` and `long long` is 64 bits. Meanwhile, in the Windows model LLP64, `long` is 32 bits and `long long` is 64 bits.

---

## 3.4 Accessing Information
An x86-64 CPU contains a set of 16 general-purpose registers storing 64-bit values.

![3-2](3-2.png)

* **`%rsp`**: Stack pointer, indicates the end position in the run-time stack.

`%rsp` is the only register with zero flexibility that the CPU (hardware) itself actively relies on to execute basic structural instructions. If it gets a random value, the program would instantly crash the moment a function call or a `push` happened.

The other 15 registers have more flexibility in their uses. While they have calling convention (rules to use the registers), they are not restricted by hardware. So the CPU does not care at all what we put in `%rax` or `%rdi`. Also, the registers are free to use by the compiler as any other usages, when their roles are not needed.

#### Registers by Calling Convention

* **`%rsp`**: Stack pointer
* **`%rax`**: Return value
* **`%rbx`**, **`%rbp`**, **`%r12`**, **`%r13`**, **`%r14`**, **`%r15`**: Callee saved
* **`%r10`**, **`%r11`**: Caller saved
* **`%rdi`**, **`%rsi`**, **`%rdx`**, **`%rcx`**, **`%r8`**, **`%r9`**: 1st ~ 6th argument

##### Callee Save and Caller Save
Calling convention to determine which function is responsible for backing up CPU registers before a new function is called, preventing data loss.

* **Callee Save**: The function being called
* **Caller Save**: The function making the call.

##### Example Code

```c
int compute_square(int x) {
    int result = x * x;
    return result;
}

int multiply_and_add(int a, int b) {
    int local_var = a * 2;       // We need to keep this safe!
    int square = compute_square(b); 
    return local_var + square;
}
```

```att
multiply_and_add:
    # 'a' is in %edi, 'b' is in %esi (standard argument rules)
    
    imull   $2, %edi            # a = a * 2
    movl    %edi, %r10          # Store local_var in %r10 (Caller-Saved!)

    # --- PREPARING TO CALL THE CALLEE ---
    pushq   %r10                # !! CALLER SAVES: Push %r10 onto the stack 
                                # because compute_square might overwrite it!
    
    movl    %esi, %edi          # Put 'b' into %edi as the argument for the callee
    call    compute_square      # Call the function (The return value comes back in %eax)
    
    # --- RETURNING FROM CALLEE ---
    popq    %r10                # !! CALLER RESTORES: Bring back our safe local_var
    
    addl    %eax, %r10          # local_var + square
    movl    %r10, %eax          # Put final result in %eax to return
    ret
```

```att
compute_square:
    # 'b' is passed in %edi
    
    # --- ENTERING CALLEE ---
    pushq   %rbx                # !! CALLEE SAVES: Back up the original %rbx onto the stack
                                # to protect the Caller's old data!
    
    movl    %edi, %ebx          # Now %rbx is free for us to use safely. Copy 'b' to %ebx
    imull   %ebx, %ebx          # b * b
    movl    %ebx, %eax          # Put the result into %eax (the standard return register)
    
    # --- EXITING CALLEE ---
    popq    %rbx                # !! CALLEE RESTORES: Put the Caller's original data 
                                # back into %rbx before returning!
    ret
```

---

### 3.4.1 Operand Specifiers
#### Types
1. **Immediate** ($\\$Imm$): Constant value.
2. **Register** ($r_a$): Contents of a register $a$. $R[r_a]$ is the reference, which is the value of the register $a$.
3. **Memory** ($M_b[Addr]$): In which we access some memory location according to a computed address.

![3-3](3-3.png)

---

### 3.4.2 Data Movement Instructions
#### Summary
* `movb`, `movw`, `movl`, `movq`
* `movzbw`, `movzbl`, `movzbq`, `movzwl`, `movzwq`
* `movsbw`, `movsbl`, `movsbq`, `movswl`, `movswq`, `movslq`

#### MOV
![mov](mov.png)

* **MOV Source**: Immediate, Register, Memory
* **MOV Destination**: Register, Memory
* The size of the register (but not memory!) must match the size designated by the last character of the instruction ('b', 'w', 'l', or 'q').
* For most cases, the `MOV` instructions will only update the specific register bytes or memory locations indicated by the destination operand.
* When `movl` has a register as the destination, it will set the high-order 4 bytes of the register to 0, because of the convention and backward compatibility for 32-bit code.

#### movabsq
* **movabsq**: Move absolute quad word (immediate) to register.

#### Zero-Extending Data Movement Instructions
![3-5](3-5.png)

Instructions in the `MOVZ` class fill out the remaining bytes of the destination with zeros.

Note that `movl` already acts the same as `movzlq`.

#### Sign-Extending Data Movement Instructions
![3-6](3-6.png)

Instructions in the `MOVS` class fill out the remaining bytes of the destination by sign extension, replicating copies of the most significant bit of the source operand.

The `cltq` instruction is specific to registers `%eax` and `%rax`.

---

### 3.4.3 Data Movement Example
![3-7](3-7.png)

* Pointers in C are simply addresses. Dereferencing a pointer = Copying the pointer into a register, and then using it in a memory reference.
* Local variables are often kept in registers rather than stored in memory locations. Register access is much faster than memory access.

---

### 3.4.4 Pushing and Popping Stack Data
![3-8](3-8.png)

![3-9](3-9.png)

The stack top is always considered to be the address indicated by `%rsp`.

```att
pushq %rbp
```
is the same as

```att
subq $8, %rsp
movq %rbp, (%rsp)
```
And
```att
popq %rax
```
is the same as

```att
movq (%rsp), %rax
addq $8, %rsp
```

`pushq` and `popq` take just 1 byte (2 bytes when using `%r8` ~ `%r15`), their equivalent code take 7~8 bytes.

---

## 3.5 Arithmetic and Logical Operations
![3-10](3-10.png)

### 3.5.1 Load Effective Address
`leaq` is actually a variant of the `movq` instruction. It reads from memory to a register, but it does not reference memory at all.

![leaq](leaq.png)

---

### 3.5.2 Unary and Binary Operations
`incq` and

---

## Problems
### Problem 3.1
![Problem](practice/3-1.png)

### Problem 3.2
![Problem](practice/3-2.png)

### Problem 3.3
![Problem](practice/3-3.png)

### Problem 3.4
![Problem](practice/3-4.png)

### Problem 3.5
```c
void decode1(long *xp, long *yp, long *zp){
    long x = *xp;
    long y = *yp;
    long z = *zp;

    *xp = y;
    *yp = z;
    *zp = x;
}
```