---
title: CS:APP Chapter 1
description: 1. A Tour of Computer Systems
layout: post
date: 2026-01-09
media_subpath: /pics/2026-01-09-csapp-chapter-1/
image:
    path: https://csapp.cs.cmu.edu/3e/images/csapp3e-cover.jpg
categories: computer-system
tags: [CS:APP]
math: true
---

# 1. A Tour of Computer Systems
## 1.2 Compilation System
![Compilation System](compilation-system.png)
_The compilation system. - CS:APP_

Understanding the compilation system is important for three reasons:

1. Optimizing program performance.
2. Understanding link-time errors.
3. Avoiding security holes.

### Phases
1. **Preprocessing phase**: The preprocessor (`cpp`) modifies the original C program according to directives that begin with the '#' character (such as `#include <stdio.h>`).
2. **Compilation phase**: The compiler (`cc1`) translates the text file `hello.i` into the text file `hello.s`, which contains an assembly-language program. Assembly language is useful because it provides a common output language for different compilers for different high-level languages.
3. **Assembly phase**: The assembler (`as`) translates `hello.s` into machine-language instructions, packages them in a form known as a relocatable object program, and stores the result in the binary object file `hello.o`.
4. **Linking phase**: The linker (`ld`) merges the object file `hello.o` with other object files, including those providing functions like `printf` from the standard C library (which comes with every C compiler installation). The result is the `hello` file, which is a binary executable object file (or simply executable) that is ready to be loaded into memory and executed by the system.

### Practice
I'll use my Ubuntu 22.04 virtual machine for many CS:APP experiments.

![Ubuntu](practice/compilation-system/1.png)

To examine the compilation system, you can use either of these two methods:

A. Use `cpp`, `cc1`, `as`, and `ld` as the book guides.

B. Use `gcc`. It is the **GNU Compiler Collection** with many compilers, so it is handier and you'll use it a lot soon.

Before you begin, you need to check whether you have the tools on your system by typing these:
```bash
# For the first method:
cpp --version
as --version
ld --version

# For the second method:
gcc --version
```

If you miss something, run these commands:
```bash
sudo apt update
sudo apt install build-essential
```

![Tools Check](practice/compilation-system/2.png)

And write a simple C source code `hello.c` with your favorite editor. I'll use Vim for it.

```c
#include <stdio.h>

int main() {
	printf("Hello, world!\n");
	return 0;
}
```

* Small tips for Ubuntu: Type `ls` on the terminal shows files in the directory. Especially `ls -al` shows all files (including files starting with '.') in long listing format. Type `cd /path/to/go` to go to `/path/to/go`.

* Small tips for Vim: Type `vim hello.c` on the terminal. It tries to open `hello.c`, or create the file if it does not exist. Press `i` key, write the source, press `ESC`, and type `:wq`. It will save the source and immediately exit Vim.

![hello.c](practice/compilation-system/3.png)

#### A. Using separate tools

1) Use the C preprocessor `cpp`. It will include the header file `stdio.h`, recognized in the context of a preprocessor directive starting with `#`.

```bash
cpp hello.c > hello.i
```

Options:
* `> hello.i`: Save output to `hello.i`.

![cpp](practice/compilation-system/4.png)

It will produce `hello.i`. When you open it, you will see `stdio.h` source is included.

![hello.i](practice/compilation-system/5.png)

![hello.i](practice/compilation-system/5a.png)

2) Use `cc1` to compile `hello.i`.

To find the directory of the compiler `cc1` from the GCC library, run this command:

```bash
find /usr/lib/gcc -name cc1
# /usr/lib/gcc/x86_64-linux-gnu/11/cc1
```
```bash
/usr/lib/gcc/x86_64-linux-gnu/11/cc1 hello.i -o hello.s -quiet -Og
```

Options:
* `-o hello.s`: Save output to `hello.s`.
* `-quiet`: Hide extra messages.
* `-Og`: Optimize for debugging.

Or you can use `gcc` here.

```bash
gcc -S hello.i -o hello.s -Og
```

Options:
* `-S`: Stop at assembly.
* `-o hello.s`: Save output to `hello.s`.
* `-Og`: Optimize for debugging.

![cc1](practice/compilation-system/6.png)

![hello.s](practice/compilation-system/7.png)

It will produce `hello.s`. When you open it, you will see a bunch of instructions in assembly language.

![hello.s](practice/compilation-system/8.png)

3) Use `as` to assemble `hello.s`.

```bash
as hello.s -o hello.o
```

Options:
* `-o hello.o`: Save output to `hello.o`.

![as](practice/compilation-system/9.png)

It will produce `hello.o`. From this phase a binary file is created instead of a text file. Therefore, if you open it with a text editor, you will see lots of unreadable garbled characters. 
But...

![binary](practice/compilation-system/10.png)

Surprise! You can read it using `objdump`! It is used as a disassembler to view an object file or an executable in assembly form.

```bash
objdump -d hello.o
```

Options:
* `-d hello.o`: Disassemble `hello.o`.

![objdump](practice/compilation-system/objdump1.png)

4) Use `ld` to link `ld` with library and create the final executable, `hello`.

To find the directory of the codes for linking, run this command:

```bash
find /lib64/ -name ld-linux-x86-64.so.2
find /usr/lib -name crt1.o
find /usr/lib -name crti.o
find /usr/lib -name crtn.o
```

```bash
ld -o hello -dynamic-linker /lib64/ld-linux-x86-64.so.2 /usr/lib/x86_64-linux-gnu/crt1.o /usr/lib/x86_64-linux-gnu/crti.o hello.o /usr/lib/x86_64-linux-gnu/crtn.o -lc
```

Options:
* `-o hello`: Save output to `hello`.
* `-dynamic-linker /lib64/ld-linux-x86-64.so.2`: Sets the dynamic linker (program interpreter) to `/lib64/ld-linux-x86-64.so.2`.
* `/usr/lib/x86_64-linux-gnu/crt1.o`: **C RunTime startup code** (provides the program entry point). It contains the `_start` function, which sets up argc/argv/environment and eventually calls `__libc_start_main` (which handles more initialization before jumping to `main()`).
* `/usr/lib/x86_64-linux-gnu/crti.o`: **CRT Initialization prologue**. It contains the prologue of the `_init` function (in the `.init` section) and the beginning of the `_fini` function (in the `.fini` section).[^1]
* `hello.o`: The file to link.
* `/usr/lib/x86_64-linux-gnu/crtn.o`: **CRT Initialization epilogue**. It contains the epilogue of the `_init` and `_fini` functions (finishing the `.init` and `.fini` sections started by crti.o).
* `-lc` Link with `libc` (standard C library). We bring the `printf` definition from the library. This links with the standard C library (`libc`), providing functions like `printf`. It uses `libc.so.6` (a symlink to the real file like `libc-x.xx-so`).

The kernel loads the dynamic linker (`/lib64/ld-linux-x86-64.so.2`).
The dynamic linker then loads shared libraries[^2] (such as `libc.so.6`) and resolves symbols at runtime.
(Note: The `crt1.o`, `crti.o`, and `crtn.o` files are **statically linked** into the executable during the linking phase — they become part of `hello` itself.)

Or simply use `gcc`!

```bash
gcc hello.o -o hello
```

Option:
* `-o hello`: Save output to `hello`.

![ld](practice/compilation-system/12.png)

It will produce `hello`. It is a binary executable, so you can see the instructions with `objdump` or execute the program.

![binary](practice/compilation-system/13.png)

```bash
objdump -d hello
```

![objdump](practice/compilation-system/objdump2.png)

```bash
./hello
```

![hello](practice/compilation-system/14.png)

#### B. Using GCC

As I said above, GCC is **GNU Compiler Collection**. That means we can simplify all phases with just one line!

```bash
gcc hello.c -o hello
```

You can also see verbose (what GCC internally does) with `-v` option.

```bash
gcc -v hello.c -o hello
```

![gcc](practice/compilation-system/f1.png)

![verbose](practice/compilation-system/f2.png)

---

## 1.4 Hardware Organization
![Hardware Organization](hardware-organization.png)
_Hardware organization of a typical system. - CS:APP_

### Buses
**Buses** are electrical conduits that run throughout the system. They typically carry fixed-size chunks of bytes known as **words**. Most machines today have word sizes of either 4 bytes (32 bits) or 8 bytes (64 bits).

### I/O Devices
**Input/Output (I/O) devices** are the system's connection to the external world. Each I/O device is connected to the I/O bus by either a controller or an adapter. While a controller is a chipset in the device itself or on the system's main printed circuit board, an adapter is a card that plugs into a slot on the motherboard.

### Main Memory
The **main memory** is a temporary storage device that holds both a program and the data it manipulates while the processor is executing the program. Physically, it consists of a collection of dynamic random access memory (DRAM) chips. Logically, it is organized as a linear array of bytes.

### Processor
The **central processing unit (CPU)** or simply **processor** is the engine that interprets (or executes) instructions stored in main memory.

#### Program Counter
The **program counter (PC)** is a word-size storage device (or register) at the processor's core. It points at (contains the address of) some machine-language instruction in main memory.

#### Register File
The **register file** is a small storage device that consists of a collection of word-size registers, each with its own unique name.

#### Arithmetic Logic Unit
The **arithmetic logic unit (ALU)** computes new data and address values.

### Running the hello Program
Look at the Figure 1.5 from Page 11 for more details. It uses **direct memory access (DMA)**, a technique that transfers data directly from disk to main memory without passing through the processor.

1. When we type `./hello`, the shell reads each character into a register, and then stores it in memory.
2. When we hit the ENTER key, the shell executes instructions to copy the code and data in the executable `hello` file from disk to main memory. 
3. The processor begins executing the machine-language instructions in the main routine of the `hello` program.

---

## 1.5 Caches Matter
![Memory Hierarchy](memory-hierarchy.png)
_An example of a memory hierarchy. - CS:APP_

Because of physical laws, larger storage devices are slower than smaller storage devices. And faster devices are more expensive to build than their slower counterparts.

The main idea of a memory hierarchy is that storage at one level serves as a cache for storage at the next lower level.

---

## 1.7 The Operating System Manages the Hardware

![Computer System](computer-system.png)
_Layered view of a computer system - CS:APP_

![OS](operating-system.png)
_Abstractions provided by an operating system - CS:APP_

Our `hello` program did not directly access the main memory or any I/O devices (keyboard, display, or disk). Rather, it relied on the services provided by the operating system. That is, all attempts by an application program to manipulate the hardware must go through the operating system.

The operating system has two primary purposes:

1. To protect the hardware from misuse by runaway applications.
2. To provide applications with simple and uniform mechanisms for manipulating complicated and often wildly different low-level hardware devices.

### Processes
![Context Switching](process-context-switching.png)
_Process context switching - CS:APP_

A **process** is the operating system's abstraction for a running program. Multiple processes can run concurrently on the same system, and each process appears to have exclusive use of the hardware. By concurrently, we mean that the instructions of one process are interleaved with the instructions of another process.

Traditional systems could only execute one program at a time, while newer multi-core processors can execute several programs simultaneously. In either case, a single CPU can appear to execute multiple processes concurrently by having the processor switch among them. The operating system performs this interleaving with a mechanism known as **context switching**.

The transition from one process to another is managed by the operating system **kernel**. The kernel is the portion of the operating system code that is always resident in memory. When an application program requires some action by the operating system, it executes a special system call instruction, transferring control to the kernel. The kernel then performs the requested operation and returns back to the application program.

### Threads
In modern systems a process can actually consist of multiple execution units called **threads**, each running in the context of the process and sharing the same code and global data. They are typically more efficient than processes, and sharing data between multiple threads is easier than between multiple processes.

### Virtual Memory
![Process Virtual Address Space](process-virtual-address-space.png)
_Process virtual address space. - CS:APP_

**Virtual memory** is an abstraction that provides each process with the illusion that it has exclusive use of the main memory. Each process has the same uniform view of memory, which is known as its virtual address space.

* **Program Code**: Code begins at the same fixed address for all processes. It is fixed in size once the process begins running.
* **Program Data**: Data locations follow the code, and it corresponds to global C variables. It is fixed in size once the process begins running.
* **Heap**: The runtime heap expands and contracts dynamically at run time as a result of calls to C standard library routines such as `malloc` and `free`. 
* **Shared Libraries**: Code and data for shared libraries such as C standard library and the math library.
* **Stack**: The compiler uses the user stack to implement function calls.
* **Kernel Virtual Memory**: Application programs must invoke the kernel to read or write the contents of the kernel virtual memory region, or to directly call functions defined in the kernel code.

### Files
A file is a sequence of bytes. Every I/O device is modeled as a file. All input and output in the system is performed by reading and writing files, using a small set of system calls known as Unix I/O. The notion of a file is very powerful because it provides applications with a uniform view of all the varied I/O devices that might be contained in the system.

---

## 1.8 Systems Communicate with Other Systems Using Networks
In practice, modern systems are often linked to other systems by networks. As shown in the telnet example (Figure 1.18), the exchange between clients and servers is typical of all network applications.

---

## 1.9.1 Amdahl's Law (암달의 법칙)
The main idea of Amdahl's law is that when we speed up one part of a system, the effect on the overall system performance depends on both how significant this part was and how much it sped up.

* $ T_{old} $: Time to execute some application in a system
* $ T_{new} $: The overall execution time
* $ \alpha $: The fraction of the computation that can be sped up
* $ k $: A factor to improve the performance of some part of the system

$$
\begin{array}{aligned}
T_{new} &=& (1-\alpha)T_{old} + (\alpha T_{old})/k \\
	&=& T_{old}[(1-\alpha) + \alpha/k]
\end{array}
$$

From this, we can compute the speedup $ S = T_{old} / T_{new} $ as

$$
S = \frac{1}{(1-\alpha) + \alpha / k}
$$

---

## 1.9.2 Concurrency and Parallelism
* **Concurrency**: The general concept of a system with multiple, simultaneous activities.
* **Parallelism**: The use of concurrency to make a system run faster.

### Thread-Level Concurrency
![Processor Configurations](processor-configurations.png)
![Multi-core Processor](multi-core.png)

With threads, we can have multiple control flows executing within a single process.

* **Uniprocessor**: A single processor computing even if that processor had to switch among multiple tasks.
* **Multiprocessor**: A system consisting of multiple processors all under the control of a single operating system kernel.
* **Multi-core Processor**: Several CPUs (referred to as "cores") integrated onto a single integrated-circuit chip. The Figure 1.17 shows a typical multi-core processor where the chip has four CPU cores.
* **Hyperthreaded Processor**: It is sometimes called **simultaneous multi-threading (SMT)**. It is a technique that allows a single CPU to execute multiple flows of control. It decides which of its threads to execute on a cycle-by-cycle basis, unlike a conventional processor, which requires around 20,000 clock cycles to switch between different threads.

#### Advantage of Multiprocessing
1. It reduces the need to simulate concurrency when performing multiple tasks.
2. It can run a single application program faster, but only if that program is expressed in terms of multiple threads that can effectively execute in parallel.

### Instruction-Level Parallelism
Modern processors can execute multiple instructions at one time.

* **Pipelining**: The actions required to execute an instruction are partitioned into different steps and the processor hardware is organized as a series of stages, each performing one of these steps.
* **Superscalar Processor**: Processor that can sustain execution rates faster than 1 instruction per cycle.

### Single-Instruction, Multiple-Data (SIMD) Parallelism
Many modern processors have special hardware that allows a single instruction to cause multiple operations to be performed in parallel.

---

## 1.9.3 The Importance of Abstraction in Computer Systems
![Computer System](os-computer-system.png)

A → B: A provides an abstraction of B

* **Processor** side: The Instruction Set Architecture (ISA) → Actual processor hardware
* **Operating System** side:
	* Files → I/O devices
	* Virtual memory → Program memory (main memory + disk)
	* Processes → A running program (with CPU + memory)
	* Virtual machine → The entire computer system

---

## Problems
### Problem 1.1
![Amdahl](practice/1-1.png)

### Problem 1.2
![Amdahl](practice/1-2.png)

---

## Notes
[^1]: The `.init` section contains executable code that runs **before** `main()` to initialize the process (e.g., calling global constructors in C++). The `.fini` section contains executable code that runs **after** `main()` returns (or on normal exit) for cleanup (e.g., calling global destructors).
[^2]: A **shared library** (.so file on Linux) is a library of executable code that can be loaded into memory and used by **multiple programs** (processes) at the same time. For example, `libc.so.6` contains `printf()` and is used by Firefox, Chrome, your `hello` program — almost everything! It saves memory because all processes map the **same physical RAM pages** for the read-only code part. (Note: Windows uses **DLL** files for the same idea. On Linux, we use **.so** files — "Shared Object". The **SONAME** is a special field inside the .so file that acts as its official name, e.g., `libc.so.6`.)