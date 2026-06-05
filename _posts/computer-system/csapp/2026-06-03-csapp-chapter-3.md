---
title: CS:APP Chapter 3
description: 3. Machine-Level Representation of Programs
layout: post
date: 2026-04-20
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

### 3.2.1 Machine-Level Code
Among different forms of abstraction that computer systems employ, these are especially important for machine-level programming.

1. **Instruction Set Architecture(ISA)**: Defines the format and behavior of a machine-level program. Most ISAs, including x86-64, describe the behavior of a program as if each instruction is executed in sequence.
2. **Virtual Address**: The memory addresses used by a machine-level program. The actual implementation of the memory system involves a combination of multiple hardware memories and operating system software.

The assembly-code representation is very close to machine code, while it is in a more readable textual format, as compared to the binary format of machine code.

#### The Machine Code for x86-64
The machine code for x86-64 differs greatly from the original C code. Parts of the processor state are visible that normally are hidden from the C programmer.

* The program counter (PC, `%rip`) indicates the address in memory of the next instruction to be executed.
* The integer "register file" contains 16 named locations storing 64-bit values. They can hold addresses or integer data.
* The condition code registers hold status information about the most recently executed arithmetic or logical instruction. These are used to implemet conditional changes in the control or data flow, such as is required to implement `if` and `while` statements.
* A set of vector registers can each hold one or more integer or floating-point values.

#### ISA in Modern Computer System
The execution units do **dynamic execution (Out-of-order execution)** to execute multiple instructions concurrently, and the temporary results for the instructions are put in a reorder buffer.

Meanwhile, the retirement unit watches the reorder buffer, takes only the finished results, and permanently write them to the architectural registers/memory in the exact sequential order of the original program. This is called **in-order retirement**.

Therefore, the instructions seem to be executed one by one in order, even if they are actually be executed concurrently in the computer system.

* [Out-of-order execution - Wikipedia](https://en.wikipedia.org/wiki/Out-of-order_execution)

