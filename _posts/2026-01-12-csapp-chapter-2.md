---
title: CS:APP Chapter 2
description: 2. Representing and Manipulating Information
layout: post
date: 2026-01-12
media_subpath: /pics/2026-01-12-csapp-chapter-2/
image:
    path: https://csapp.cs.cmu.edu/3e/images/csapp3e-cover.jpg
categories: computer-system
tags: [CS:APP]
math: true
---

# 2. Representing and Manipulating Information
## 2.1 Information Storage
Rather than accessing individual bits in memory, most computers use block of 8 bits, or **bytes**, as the smallest addressable unit of memory. A machine-level program views memory as a very large array of bytes, referred to as **virtual memory**. Every byte of memory is identified by a unique number, known as its **address**, and the set of all possible addresses is known as the **virtual address space**.

![Specifying C Version](2-1.png)
_Figure 2.1 Specifying different versions of C to GCC. - CS:APP_

---

### 2.1.1 Hexadecimal Notation
![Hex](2-2.png)

A single byte consists of 8 bits. In **binary** notation, its value ranges from 00000000₂ to 11111111₂. When viewed as a **decimal** integer, its value ranges from 0₁₀ to 255₁₀. Written in **hexadecimal**, the value of a single byte can range from 00₁₆ to FF₁₆.

In C, numeric constants starting with **0x** or **0X** are interpreted as being in hexadecimal.

![Decimal to Hexadecimal](decimal-to-hex.png)

Converting between decimal and hexadecimal representation requires using multiplication or division to handle the general case. To convert a decimal number $x$ to hexadecimal, we can repeatedly divide $x$ by 16, giving a quotient $q$ and a remainder $r$, such that

$$
x = q · 16 + r
$$

---

### 2.1.2 Data Sizes
For a machine with a $w$-bit word size, the virtual addresses can range from 0 to $2^w-1$, giving the program access to at most $2^w$ bytes.

Most 64-bit machines can also run programs compiled for use on 32-bit machines, a form of backward compatibility.

```bash
# This 32-bit program will run correctly on either 32-bit or a 64-bit machine.
gcc -m32 prog.c

# This 64-bit program will only run correctly on a 64-bit machine.
gcc -m64 prog.c
```

Computers and compilers support multiple data formats using different ways to encode data, such as integers and floating point, as well as different lengths.

![2-3](2-3.png)

To avoid the vagaries of relying on "typical" sizes and different compiler setthings, ISO C99 introduced a class of data types where the data sizes are fixed regardless of compiler and machine settings. Among these are data types `int32_t` and `int64_t`, having exactly 4 and 8 bytes. Using fixed-size integer types is the best way for programmers to have close control over data representations.

Most of the data types encode signed values, unless prefixed by the keyword `unsigned` or using the specific unsigned declaration for fixed-size data types. The exception to this is data type `char`. Although most compilers and machines treat these as signed signed data, the C standard does not guarantee this. The programmer should use the declaration `signed char` to guarantee a 1-byte signed value.

![char](char.png)

All of the following declarations have identical meaning:

```c
unsigned long
unsigned long int
long unsigned
long unsigned int
```

A pointer uses the full word size of the program.

Most machines also support two different floating-point formats: single precision, declared in C as `float`, and double precision, declared in C as `double`.

One aspect of program portability is to make it insensitive to the exact sizes of the different data types. The C standards set lower bounds on the numeric ranges of the different data types, but there are no upper bounds (except with the fixed-size types). Many hidden word size dependencies have arisen as bugs in migrating 32-bit programs to new 64-bit machines.

---

### 2.1.3 Addressing and Byte Ordering
For program objects that span multiple bytes, we must establish two conventions: what the address of the object will be, and how we will order the bytes in memory. In virtually all machines, a multi-byte object is stored as a contiguous sequence of bytes, with the address of the object given by the smallest address of the bytes used.

For ordering the bytes representing an object, there are two common conventions.

![Endian](endian.png)

**NOTE: Endianness only matters for multi-byte values.** This means while multi-byte data types such as `int`, `short`, `long`, `float`, and `double` are affected by endianness, `char` and string sequences of 1-byte characters are not affected by it.

Byte ordering becomes an issue in these three situtations:

#### When Byte Ordering Matters 1
When binary data are communicated over a network between different machine. The sending machine should convert its internal representation to the network standard, and the receiving machine convert the network standard to its internal representation.

#### When Byte Ordering Matters 2
When looking at the byte sequences representing integer data, inspecting machine-level programs.

```gas
4004d3: 01 05 43 0b 20 00     add %eax, 0x200b43 (%rip)
```

Having bytes appear in reverse order is a common occurrence when reading machine-level program representations generated for little-endian machines such as this one. The value `0x200b43` is represented as `43 0b 20 00` in the instruction.

#### When Byte Ordering Matters 3
When programs are written that circumvent the normal type system. In the C language, this can be done using a cast or a `union` to allow an object to be referenced according to a different data type from which it was created. Such coding tricks are strongly discouraged for most application programming, but they can be quite useful and even necessary for system-level programming.

![2-5-2-6](2-5-2-6.png)

As we can see from the Figure 2.6, only the Sun machine has different byte ordering from Linux 32, Linux 64, and Windows. Since 12,345 is 0x3039 in hexadecimal representation, we can confirm the Sun machine is a big-endian machine, while the others are little-endian machines.

Here's the example C source to check the byte representation in our system:

```c
#include <stdio.h>

typedef unsigned char *byte_pointer;

void show_bytes(byte_pointer start, size_t len) {
    size_t i;
    for (i = 0; i < len; i++)
        printf(" %.2x", start[i]);
    printf("\n");
}

void show_int(int x) {
    show_bytes((byte_pointer) &x, sizeof(int));
}

void show_float(float x) {
    show_bytes((byte_pointer) &x, sizeof(float));
}

void show_pointer(void *x) {
    show_bytes((byte_pointer) &x, sizeof(void *));
}

void test_show_bytes(int val) {
    int ival = val;
    float fval = (float) ival;
    int *pval = &ival;
    show_int(ival);
    show_float(fval);
    show_pointer(pval);
}

int main() {

    test_show_bytes(12345);

    return 0;
}
```

Compile it and run the program.

```bash
gcc byte.c -o byte
./byte
```

![Byte](byte_c.png)

My Ubuntu 22.04 shows the same byte ordering of "Linux 64" for `int` and `float` types, as in the Figure 2.6 table.

Meanwhile, integer and the floating-point data encoding the same numeric value 12,345 have some matching bits.

![Matching Bits](integer-floating-point.png)

---

### 2.1.4 Representing Strings
A string in C is encoded by an array of characters terminated by the null (having value 0) character. Each character is represented by some standard encoding, with the most common being the ASCII character code.

---

### 2.1.5 Representing Code
Different machine types use different and incompatible instructions and encodings. Even identical processors running different operating systems have differences in their coding conventions and hence are not binary compatible.

---

### 2.1.6. Introduction to Boolean Algebra
The simplest Boolean algebra is defined over thw two-element set {0, 1}.

![Boolean Algebra](2-7.png)

| Boolean Operation | Logical Operation  | Symbol |
| ----------------- | ------------------ | ------ |
| ~                 | NOT                | ¬      |
| &                 | AND                | ∧      |
| \|                | OR                 | ∨      |
| ^                 | XOR (EXCLUSIVE-OR) | ⊕     |

The Boolean operations `~`, `&`, and `|` operating on bit vectors of length $w$ form a Boolean algebra, for any integer $w > 0$. Boolean algebra has many of the same properties as arithmetic over integers.
* Boolean operation `&` distributes over `|`. So $a·(b+c) = (a·b)+(a·c)$ is also applied to Boolean algebra, `a & (b | c) = (a & b) | (a & c)`.
* Boolean operation `|` distributes over `&`. While we cannot say that $a+(b·c) = (a+b)·(a+c)$ holds for all integers, we can write `a | (b & c) = (a | b) & (a | c)`.

When we consider operations `~`, `&`, and `^` operating on bit vectos of length $w$, we get a different mathematical form, known as a **Boolean ring**.
* One property of integer arithmetic is that every value $x$ has an additive inverse $-x$, such as $x + -x = 0$. A similar property holds for Boolean rings, where `^` is the "addition" operation, but in this case each element is its own additive. That is, `a ^ a = 0` for any value `a`, where we use 0 here to represent a bit vector of all zeros. And so `(a ^ b) ^ a = b`.

One useful application of bit vectors is to represent finite sets.
* `~`: Complement
* `&`: Intersection
* `|`: Union

---

### 2.1.7 Bit-Level Operations in C
One useful features of C is that it supports **bitwise** Boolean operations. The symbols we have used for the Boolean operations are exactly those used by C, and these can be applied to any "integral" data type.

---

### 2.1.8 Logical Operations in C
C also provides a set of **logical** operators.
* `!`: NOT
* `&&`: AND
* `||`: OR

Their behavior is quite different from bit-level operations' behavior. The logical operations treat any nonzero argument as representing TRUE and argument 0 as representing FALSE.

And the logical operators do not evaluate their second argument if the result of the expression can be determined by evaluating the first argument. Thus, for example, the expression `a && 5/a` will never cause a division by zero, and the expression `p && *p++` will never cause the dereferencing of a null pointer.

---

### 2.1.9 Shift Operations in C

C also provides a set of **shift** operations for shifting bit patterns to the left and to the right.

* `x << k`: **Left shift**. `x` is shifted `k` bits to the left, dropping off the `k` most significant bits and filling the right end with `k` zeros.
* `x >> k`: **Right shift**. Two forms of right shift are supported by machines. 
    1. **Logical**: Fills the left end with `k` zeros.
    2. **Arithmetic**: Fills the left end with `k` repetitions of the most significant bit. This is useful for operating on signed integer data.

Although the C standards do not precisely define which type of right shift should be used with signed numbers, almost all compiler/machine combinations use **arithmetic right shifts** for signed data. In contrast to C, Java has precise definition of the right shifts. `x >> k` shifts `x` arithmetically by `k` positions, while `x >>> k` shifts it logically.

For a data type consisting of $w$ bits, what should be the effect of shifting by some value $k≥w$? The C standars carefully avoid stating that. On many machines, the shift instructions consider only the lower $log_2w$ bits of the shift amount when shifting a $w$-bit value, and so the shift amount is computed as $k$ mod $w$. While the behavior is not guaranteed in C. Java, on the other hand, specifically requires that shift amounts should be computed in the modular fashion.

```c
int       lval = 0xFEDCBA98  << 32;   // 32 mod 32 = 0, << 0 (lval = 0xFEDCBA98)
unsigned  uval = 0xFEDCBA98u >> 40;   // 40 mod 32 = 8, >> 8 (uval = 0x00FEDCBA)
```

**CAUTION:** In C, addition (and subtraction) have higher precedence than shifts. So `1 << 2 + 3 << 4` is equivaluent to `1 << (2+3) << 4`. **When in doubt, put in parentheses!**

---

## 2.2 Integer Representations

![Terminology](2-8.png)

### 2.2.1 Integral Data Types
![2-9](2-9.png)

![2-10](2-10.png)

![2-11](2-11.png)

C supports a variety of integral data types ― ones that represent finite ranges of integers. Based on the byte allocations, the different sizes allow different ranges of values to be represented. The only machine-dependent range indicated is for size designator `long`. Most 64-bit programs use an 8-byte representation, giving a much wider range of values than the 4-byte representation used with 32-bit programs.

One important feature to note in figures is that the ranges are not symmetric ― the range of negative numbers extends one further than the range of positive numbers.

Guaranteed ranges for C integer data types are influenced by two important historical reasons:
1. **Portability** across all possible machines, such as 8-bit CPUs, 12-bit, or 16-bit machines.
2. Support for **one's complement** representation used in early computers (in addition to two's complement used in modern systems). This is why the minimum guaranteed negative range is set to **$-(2^{w_{min}-1}-1)$** instead of $-(2^{w_{min}-1})$.

### 2.2.2 Unsigned Encodings
![2-12](2-12.png)

#### Equation (2.1)

![b2u](b2u.png)

#### Equation (2.2)
![b2u_map](b2u_map.png)

#### Uniqueness of Unsigned Encoding
![b2u_umax](b2u_umax.png)

![b2u_u2b](b2u_u2b.png)

### 2.2.3 Two's-Complement Encodings
![2-13](2-13.png)

#### Equation (2.3)
![b2t](b2t.png)

#### Equation (2.4)
![b2t_map](b2t_map.png)

#### Uniqueness of Two's-Complement Encoding

![b2t_t2b](b2t_t2b.png)

#### B2T Tip
![b2t_trick](b2t_trick.png)

![2-14](2-14.png)

* **The two's-complement range is asymmetric**: **$\|TMin\| = \|TMax\| + 1$**. This asymmetry arises because half the bit patterns represent negative numbers, while half **including 0** represent nonnegative numbers.
* **The maximum unsigned value is just over twice the maximum two's-complement value**: **$UMax = 2TMax + 1$**.
* **Representations of constants -1 and 0**: -1 has the same bit representation as $UMax$ ― a string of all ones. 0 is represented as a string of all zeros.

#### More on fixed-size integer types
![2-15](2-15.png)

For some programs, it is essential that data types be encoded using representations with specific sizes.

* Example: when writing programs to enable a machine to communicate over the Internet according to a standard protocol.

The C standards do not require single integers to be represented in two's complement form, but nearly all machines do so. Programmers who are concerned with maximizing portability across all possible machines should not assume any particular range of representable values nor should they assume any particular representation of signed numbers. On the other hand, many programmers are written assuming a two's-complement representation of signed numbers, and the "typical" ranges, and these prorgrams are portable across a broad range of machines and compilers. The file `<limits.h>` in the C library defines a set of constants delimiting the ranges of the different integer data types for the particular machine on which the compiler is running. Meanwhile, the Java standard is quite specific about integer data type ranges and representations.

For more C tips on the fixed-size integer types, see [here](#fixed-size-integer-types).

### 2.2.4 Conversions between Signed and Unsigned
![2-16](2-16.png)

![2-17](2-17.png)

![2-18](2-18.png)

C allows casting between numeric data types. The expression `(unsigned) x` converts the value of `x` to an unsigned value, and `(int) u` converts the value of `u` to a signed integer. Converting a negative value to unsigned in the most implementations of C is based on a bit-level perspective.

![cast](cast.png)

#### Equation (2.5)
![conversion](conversion.png)

#### Equation (2.6)
![b2u_t2b](b2u_t2b.png)

#### Equation (2.7)
![u2t](u2t.png)

#### Equation (2.8)
![u2t Derivation](u2t-derivation.png)

### 2.2.5 Signed versus Unsigned in C
Although the C standard does not specify a particular representation of signed numbers, almost all machines use two's complement. Generally, most numbers are signed by default. C allows conversion between unsigned and signed.

Conversions can happen due to explicit casting:

```c
int tx, ty;
unsigned ux, uy;

tx = (int) ux;
uy = (unsigned) ty;
```

Or implicitly:

```c
int tx, ty;
unsigned ux, uy;

tx = ux; /* Cast to signed */
uy = ty; /* Cast to unsigned */
```

`printf` does not make use of any type information, and so it is possible to print a value of type `int` with directive `%u` and a value of type `unsigned` with directive `%d`.

```c
int x = -1;
unsigned u = 2147483648; /* 2 to the 31th */

printf("x = %u = %d\n", x, x);
printf("u = %u = %d\n", u, u);
```

When compiled as a 32-bit program, it prints the following:
```
x = 4294967295 = -1
u = 2147483648 = -2147483648
```

![2-19](2-19.png)
_Figure 2.19 Effects of C promotion rules. - CS:APP_

When an operation is performed where one operand is signed and the other is unsigned, C implicitly casts the signed argument to unsigned and performs the operations assuming the numbers are nonnegative.

### 2.2.6 Expanding the Bit Representation of a Number
![Zero Extension](zero-extension.png)

![Sign Extension](sign-extension.png)

```c
short sx = -12345;   /* -12345   */
unsigned uy = sx;    /* Mystery! */

printf("uy = %u:\t", uy);
show_bytes((byte_pointer) &uy, sizeof(unsigned));
```

When the code above is run on a big-endian machine, it prints:

```
uy = 4294954951:     ff ff cf c7
```

This shows that, when converting from `short` to `unsigned`, the program first changes the size and then the type.

### 2.2.7 Truncating Numbers
![trunc_u](trunc_u.png)

![trunc_two](trunc_two.png)

#### Equation (2.9)
![Equation 2.9](eq2-9.png)

#### Equation (2.10)
![Equation 2.10](eq2-10.png)

### 2.2.8 Advice on Signed versus Unsigned
The implicit casting of signed to unsigned leads to some nonintuitive behavior. Nonintuitive features often lead to program bugs, and ones involving the nuances of implicit casting can be especially difficult to see. See [Problem 2.25](#problem-225) and [Problem 2.26](#problem-226) for example subtle errors.

One way to avoid such bugs is to never use unsigned numbers. However, unsigned values are very useful in these two situations:
1. When we want to think of words as just collections of bits with no numeric interpretation.
    * Example: Flags
2. When implementing mathematical packages for modular arithmetic and for multiprecision arithmetic, in which numbers are represented by arrays of words.
    * Modular arithmetic: `mod`
        * Example: Clock (11 + 2 = 1 o'clock ∵ 13 mod 12 = 1)
    * Multiprecision arithmetic: processing big numbers that exceed the bit length a CPU can hold.
        * Easier to process addition and multiplication than signed numbers because of easier carry/borrow and natural wrap-around (UMin underflows to UMax, UMax overflows to UMin).
        * Example: 1024-bit number (often in encryption) - `uint64_t bignum[16];`

```c
// Addition of two (4 × 64)-bit big numbers
void add_big(uint64_t a[4], uint64_t b[4], uint64_t result[4]) {
    uint64_t carry = 0;
    for (int i = 0; i < 4; i++) {
        uint64_t sum = a[i] + b[i] + carry;
        result[i] = sum;           // lower 64 bits
        carry = (sum < a[i]) ? 1 : 0;   // if unsigned overflow → carry flag becomes ON
    }
    // if any carry remains → use bigger array OR overflows
}
```

---

## 2.3 Integer Arithmetic
Understanding the nuances of finite nature of computer arithmetic (such as difference between `x < y` and `x-y < 0`) can help programmers write more reliable code.

### 2.3.1 Unsigned Addition
#### Equation (2.11)
![Equation 2.11](eq2-11.png)

#### Detecting Overflow of Unsigned Addition
![Overflow Detection](overflow-detection.png)

#### Equation (2.12)
![Equation 2.12](eq2-12.png)

#### Aside: Security Vulnerability in getpeername
```c
/*
 * Illustration of code vulnerability similar to that found in
 * FreeBSD's implementation of getpeername()
*/

/* Declaration of library function memcpy */
void *memcpy(void *dest, void *src, size_t n);

/* Kernel memory region holding user-accessible data */
#define KSIZE 1024
char kbuf[KSIZE];

/* Copy at most maxlen bytes from kernel region to user buffer */
int copy_from_kernel(void *user_dest, int maxlen) {
    /* Byte count len is minimum of buffer size and maxlen */
    int len = KSIZE < maxlen ? KSIZE : maxlen;
    memcpy(user_dest, kbuf, len);
    return len;
}
```

This was issued as "FreeBSD-SA-02:38.signed-error". If a malicious programmer writes code that calls `copy_from_kernel` with a negative value of `maxlen`, `memcpy` will treat the `unsigned n` as a very large positive number, and attemp to copy that many bytes from the kernel region to the user's buffer. It will not actually work because of invalid addresses in the process. However, the program could read regions of the kernel memory for which it is not authorized.

The bug can be fixed by declaring both things:
1. Parameter `maxlen` to `copy_from_kernel` to be of type `size_t`, to be consistent with parameter `n` of `memcpy`.
2. Local variable `len` and the return value to be of type `size_t`. Although fixing `maxlen` might be okay to hide the issue, the compiler will give warnings like "comparison between signed and unsigned integer expressions". Fixing others ensures safety and consistency.

### 2.3.2 Two's-Complement Addition
#### Equation (2.13)
![Equation 2.13](eq2-13.png)

#### Equation (2.14)
![Equation 2.14](eq2-14.png)

#### Detecting Overflow of Two's-Complement Addition
![Overflow Detection](overflow-detection-two.png)

### 2.3.3 Two's-Complement Negation
#### Equation (2.15)
![Equation 2.15](eq2-15.png)

#### Web Aside DATA: TNEG
There are several clever ways to determine the two's-complement negation of a value represented at the bit level.
1. Complement the bits and then increment the result. (`~x + 1`)
2. Complement each bit to the left of bit position $k$, where $k$ is the position of the rightmost 1.

![TNEG](tneg.png)

### 2.3.4 Unsigned Multiplication
#### Equation (2.16)
![Equation 2.16](eq2-16.png)

### 2.3.5 Two's-Complement Multiplication
#### Equation (2.17)
![Equation 2.17](eq2-17.png)

#### Bit-level Equivalence of Unsigned and Two's-Complement Multiplication
![bit-eq-multiplication](bit-eq-multiplication.png)

#### Equation (2.18)
![Equation 2.18](eq2-18.png)

#### Aside: Security Vulnerability in the XDR Library
![malloc](malloc.png)

### 2.3.6 Multiplying by Constants
![power-of-2](power-of-2.png)

![power-of-2-u](power-of-2-u.png)

![power-of-2=t](power-of-2-t.png)

Note that multiplying by a power of 2 can cause overflow with either unsigned or two's-complement arithmetic. Also, integer multiplication is more costly than shifting and adding.

### 2.3.7 Dividing by Powers of 2
![div-power-u](div-power-u.png)

![div-power-t-d](div-power-t-d.png)

![div-power-t-u](div-power-t-u.png)

### 2.3.8 Final Thoughts on Integer Arithmetic
* The "integer" arithmetic performed by computers is really a form of modular arithmetic.
* The two's-complement representation provides a clever way to represent both negative and positive values, while using the same bit-level implementations as are used to perform unsigned arithmetic
* Some of the conventions in the C language can yield some surprising results, and these can be sources of bugs that are hard to recognize or understand.
* The `unsigned` data type, while conceptually straightforward, can lead to behaviors that even experienced programmers do not expect. It can also arise in unexpected ways.

---

## 2.4 Floating Point
### 2.4.1 Fractional Binary Numbers
![eq2-19](eq2-19.png)

### 2.4.2 IEEE Floating-Point Representation
![precision](precision.png)

![floating-point](floating-point.png)

### 2.4.3 Example Numbers
#### 8-bit Floating Point Example
![8bit-floating-point](8bit-floating-point.png)

### 2.4.4

### 

---

## Tips on C

### Pointer

```c
// p is a pointer variable, pointing to an object of type T.
T *p;

// Declaration of a pointer to an object of type char.
char *p;
```

### typedef
```c
// Giving a name to a data type using the typedef declaration
typedef int *int_pointer;
int_pointer ip;

// Or directly declare it as
int *ip;
```

### printf
`printf`, `fprintf`, and `sprintf` has the first argument as a format string, while any remaining arguments are values to be printed.

* Character sequence starting with `%`: How to format the next argument
    * Integer
        * `%d`: Signed decimal
        * `%u`: Unsigned decimal
        * `%x`: Hexadecimal
    * `%f`: Floating-point number
    * `%c`: Character

### Pointers and Arrays
In C, we can dereference a pointer with array notation, and we can reference array elements with pointer notation.

```c
typedef unsigned char *byte_pointer;

void show_bytes(byte_pointer start, size_t len) {
    int i;
    for (i = 0; i < len; i++)
        printf(" %.2x", start[i]);   // HERE
    printf("\n");
}
```

In the example, the reference `start[i]` indicates that we want to read the byte that is `i` positions beyond the location pointed to by start.

### Pointer Creation and Casting
```c
show_bytes((byte_pointer) &x, sizeof(int));      // &x: int *
show_bytes((byte_pointer) &x, sizeof(float));    // &x: float *
show_bytes((byte_pointer) &x, sizeof(void *));   // &x: void **
```

The C "address of" operator `&` creates a pointer. The expression in the `&x` creates a point to the location holding the object indicated by variable `x`. Data type `void *` is a special kind of pointer with no associated type information.

The cast (`byte_pointer`) `&x` converts all those pointers of three types (`int`, `float`, `void *`) to data of type `unsigned char`. It simply direct the compiler to refer to the data being pointed to according to the new data type.

### Signed and Unsigned Numbers
Both C and C++ support (the default) signed and unsigned numbers. However, Java supports only signed numbers.

### Fixed-size Integer Types
The ISO C99 standard introduces the class of integer types in the file `stdint.h`. There is also a set of macros defining the minimum and maximum values for each value of $N$, such as `INT32_MIN`, `INT32_MAX`, and `UINT32_MAX`.

Formatted printing with fixed-width types requires use of macros that expand into format strings in a system-dependent manner. `inttypes.h` provides the portable `printf`/`scanf` format macros.

```c
printf("x = %" PRId32 ", y = %" PRIu64 "\n", x, y);
```

When compiled as a 64-bit program, macro `PRId32` expands to the string "d", while `PRId64` expands to the pair of strings "l" "u". When the C preprocessor enconters a sequence of string constants separated only by spaces (or other whitespace characters), it concatenates them together. Thus, the above call to `printf` becomes:

```c
printf("x = %d, y = %lu\n", x, y);
```

| Integer Type | Macro (decimal) | Macro (HEX) | Macro (Octal) |
| ------------ | --------------- | ----------- | ------------- |
| `int8_t`     | `PRId8`         | `PRIx8`     | `PRIo8`       |
| `uint8_t`    | `PRIu8`         | `PRIx8`     | `PRIo8`       |
| `int16_t`    | `PRId16`        | `PRIx16`    | `PRIo16`      |
| `uint16_t`   | `PRIu16`        | `PRIx16`    | `PRIo16`      |
| `int32_t`    | `PRId32`        | `PRIx32`    | `PRIo32`      |
| `uint32_t`   | `PRIu32`        | `PRIx32`    | `PRIo32`      |
| `int64_t`    | `PRId64`        | `PRIx64`    | `PRIo64`      |
| `uint64_t`   | `PRIu64`        | `PRIx64`    | `PRIo64`      |

* For HEX macros, use `x` for lowercase alphabets or `X` for uppercase alphabets.

#### What the Macros Actually Expand to

| Macro    | Linux/macOS (64-bit)    | Windows (MSVC, 64-bit)    |
| -------- | ----------------------- | ------------------------- |
| `PRId32` | `d`                     | `d`                       |
| `PRIu32` | `u`                     | `u`                       |
| `PRId64` | `lld`                   | `I64d`                    |
| `PRIu64` | `llu`                   | `I64u`                    |
| `PRIx64` | `llx`                   | `I64x`                    |

* Using `X` instead of `x` for `PRIx64` expands it to `llX`/`I64X`.
* No difference between 32-bit and 64-bit compilation on the same OS, same macro.

### DATA: TMIN
A curious interaction between the asymmetry of the two's-complement representation and the conversion rules of C forces us to write $TMin_{32}$ in the unusual way.

```c
/* Minimum and maximum values a 'signed int' can hold. */
#define INT_MAX   2147483647
#define INT_MIN   (-INT_MAX - 1)
```

---

## Other Tips
### ASCII Table
`man ascii` on the terminal generates an ASCII table.

### SDL
Visual Studio will block you to compile and run some programs with specific warnings, if SDL(Security Development Lifecycle) is enabled.

Check [the official Microsoft Learn document](https://learn.microsoft.com/en-us/cpp/build/reference/sdl-enable-additional-security-checks?view=msvc-180) first to confirm that you are intentionally making such warnings. To disable SDL, follow these figures. Note that I am using Visual Studio 2026. 

![sdl_enabled](sdl_enabled.png)

1) Right-click your project name, and click 'Properties'.

![sdl_disable](sdl_disable.png)

2) Select the Configuration Properties > C/C++ > General, and set the SDL checks to 'No(/sdl-)'. Choose Apply. 

![sdl_result](sdl_result.png)

Done!

---

## Problems
### Problem 2.1
![Problem](practice/2-1.png)

### Problem 2.2
![Problem](practice/2-2.png)

### Problem 2.3
![Problem](practice/2-3.png)

### Problem 2.4
![Problem](practice/2-4.png)

### Problem 2.5
![Problem](practice/2-5.png)

### Problem 2.6
![Problem](practice/2-6.png)

### Problem 2.7
![Problem](practice/2-7.png)

### Problem 2.8
![Problem](practice/2-8.png)

### Problem 2.9
![Problem](practice/2-9.png)

### Problem 2.10
![Problem](practice/2-10.png)

### Problem 2.11
![Problem](practice/2-11.png)

### Problem 2.12
![Problem](practice/2-12.png)

### Problem 2.13
![Problem](practice/2-13.png)

### Problem 2.14
![Problem](practice/2-14.png)

### Problem 2.15
![Problem](practice/2-15.png)

### Problem 2.16
![Problem](practice/2-16.png)

### Problem 2.17
![Problem](practice/2-17.png)

### Problem 2.18
![Problem](practice/2-18.png)

### Problem 2.19
![Problem](practice/2-19.png)

### Problem 2.20
![Problem](practice/2-20.png)

### Problem 2.21
![Problem](practice/2-21.png)

### Problem 2.22
![Problem](practice/2-22.png)

### Problem 2.23
![Problem](practice/2-23.png)

### Problem 2.24
![Problem](practice/2-24.png)

### Problem 2.25
<!-- ![Problem](practice/2-25.png) -->

### Problem 2.26
<!-- ![Problem](practice/2-26.png) -->

### Problem 2.37
See [above](#aside-security-vulnerability-in-the-xdr-library) for the XDR code.

### Problem 2.42
Answer:

```c
int div16(int x) {
	int alpha = (x >> 31) & 15;
	return (x + alpha) >> 4;
}
```

Full validation:

```c
#include <stdio.h>
#include <limits.h>

#define SIXTEEN 16

int div16(int x) {
	int alpha = (x >> 31) & 15;
	return (x + alpha) >> 4;
}

int main() {
	int prev = INT_MIN;
	int total = 0;
	int wrong = 0;

	for (int k = 0; k < 100001; ++k) {
		++total;
		int i = -50000 + k;
		int answer = i / SIXTEEN;
		int d = div16(i);
		if (prev == INT_MIN)
			prev = answer;
		else if (prev != answer) {
			printf("\n");
			prev = answer;
		}

		printf("%11d / 16\t%10d\t%10d ----- ", i, answer, d);
		if (answer == d)
			printf("Correct!\n");
		else {
			printf("Oh.....\n");
			++wrong;
		}
	}

	printf("\n> Test Result: %d / %d\n", (total - wrong), total);
	if (!wrong)
		printf("WOW! Perfect!\n");
	else
		printf("Oh...... Something is wrong.\n");

	return 0;
}
```