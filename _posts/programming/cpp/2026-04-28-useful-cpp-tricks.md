---
title: Useful C++ Tricks
description: Learn some C++ tricks for programming tests or practical developments.
layout: post
date: 2026-04-28
media_subpath: /pics/programming/cpp/2026-04-28-useful-cpp-tricks/
image:
    path: cpp.png
categories: programming
tags: [programming, C++]
math: true
---

## ⏩ Global Variable
**Global variables** are allocated in the BSS/Data segment of the program's memory. They are fast than on the stack (small and can overflow) and on the heap (which requires slow system calls via `new` or `malloc`). They are useful for speeding up your code on the programming tests.

They can be used for these data structures where the maximum constraints are given:

1. Large fixed-size lookup tables
2. Difference arrays
3. Graph adjacency lists

Meanwhile, there are some situations NOT to use global variables:

1. Do not put simple loop counters (`int i`) or temporary variables. They are faster on local because of the benefits from CPU registers or the fast stack.
2. Do not use globals if the problem constraints are dynamic or unknown, or you can get a Segment Fault.

Also if you take tests on some platforms such as LeetCode and SWEA, you should be careful on clearing or filling the globals. They run the same class instance or solution process for multiple test cases. Therefore, forgetting the clearing would break the latter test cases!

### Global Variables in Real World
Although using global variables are recommended in programming tests, almost real-world scenarios prefer to avoid them.

1. In multithreaded environments, global variables have high chance to cause **data races**. (Race condition)
2. In C++, **the initialization order of global variables defined in different translation units (different `.cpp` files) is undefined.** So if a global object relies on another global object, sometimes the program will initialized well; other times, it will crash.
3. **They harm the isolation of unit tests.** First, it will occur "state pollution" that a test changing its global variable affects the next test. Second, it will block your "parallel testing" since your tests will all fight over the same global state.
4. **Global variables destroy the concept of encapsulation.** Local scope is better for code readability and maintainability, because while you will have a hard time to examine every single line for global scope, you can just check the local scope for a problematic function.

But there are couple of cases that globals are truly acceptable in production C++:

1. **True compile-time constants**: Global `constexpr` variables like `constexpr double PI = 3.14159;` are perfectly safe because they are immutable.
2. **Read-only configuration/hardware registers**: In embedded systems, mapping a global pointer to a specific, unchanging hardware register is standard practice.

## ⏩ Lambda Expression
![Lambda Expression](lambda_expression_in_c_.webp)
_Lambda Expression in C++ - GeeksforGeeks_

### Capture clause
**Capture clause** helps to caputre external variables from the enclosing scope. It's on the right side of the `=`.
* `[]`: Use only its own parameters or global/static variables.
* `[&]`: Capture all external variables by reference.
* `[=]`: Capture all external variables by value.
* `[a, &b]`: Capture 'a' by value and 'b' by reference.

#### Example
```cpp
#include <iostream>
#include <vector>
using namespace std;

void print(const vector<int>& v)
{
    for (auto x : v)
        cout << x << " ";
    cout << endl;
}

int main()
{
    vector<int> v1, v2;

    //  Capture all by reference
    auto byRef = [&](int m) {
        v1.push_back(m);
        v2.push_back(m);
    };

    //  Capture all by value
    auto byVal = [=](int m) mutable {
        v1.push_back(m);
        v2.push_back(m);
    };

    //  Capture v1 by reference and v2 by value
    auto mixed = [&v1, v2](int m) mutable {
        v1.push_back(m);
        v2.push_back(m);
    };

    // Case 1: byRef — modifies both v1 and v2
    byRef(20);

    // Case 2: byVal — modifies only copies (originals unchanged)
    byVal(234);

    // Case 3: mixed — modifies only v1 (since v2 is captured by value)
    mixed(10);

    print(v1);
    print(v2);

    return 0;
}
```
In the example, `byVal` and `byRef` can capture all external variables from the enclosing scope, the main function.

### IIFE
**IIFE(Immediately Invoked Function Expression)** immediately runs statements inside a lambda expression then destroys it. The destruction prevents the expression to be called again accidently. It can be attached as `()` right after to the definition of a lambda expression.

#### Example
```cpp
static const int fast_io = [](){
    ios::sync_with_stdio(false);
    cin.tie(NULL);
    cout.tie(NULL);
    return 0;
}();
```

Before the main function, the code immediately runs three performance optimizations inside a lambda expression, and then destroys. It is useful for optimizing resources like LeetCode solutions.

```cpp
int result = [](int a, int b) {
    return a + b;
}(5, 10);
```

Another example shows arguments can be passed into the parentheses for the immediate invocation, where `a = 5`, `b = 10`.

```cpp
// This 'const' ensures the value is calculated ONCE
const uint32_t BAUDRATE_REG_VALUE = []() {
    uint32_t pclk = HAL_RCC_GetPCLK1Freq();
    uint32_t baud = 115200;
    // Complex formula for the register value
    return (pclk + (baud / 2)) / baud;
}(); 

// Now use that clean, constant value
USART1->BRR = BAUDRATE_REG_VALUE;
```

The last example shows how to set a single baud rate or a timer frequency with a lambda expression in STM32. Such programming skill to define a `const` especially shines in the embedded world because:

1. Optimization: It reduces the assembly code to load trash variables from RAM, calculate with them, and get the final `const` value.
2. Flash memory: On microcontrollers, `const` data can often be stored in Flash (ROM) instead of SRAM. That is, it saves your precious RAM.

## ⏩ Resetting an C-Style Array or a Vector
### 1. Resetting an C-Style Array
#### A. `std::fill`
`std::fill` is highly optimized and great for modern compilers. It works for any data type and properly handles object constructors and destructors. While on modern compilers `std::fill` performs identically as a for-loop iteration, it increases the readability for programmers, reduces human errors, and automatically hooks into highly optimized architectural assembly.

```cpp
int arr[1000];

// Resets all elements to 0
std::fill(std::begin(arr), std::end(arr), 0);
```

#### B. `memset`
If you are dealing strictly with trivial types (integers, chars, bools) and resetting them to `0` or `-1`, this works occasionally faster on older compilers. However on modern compilers it would show almost the same performance as using `std::fill`.

```cpp
int arr[1000];

// Resets all elements to 0
std::memset(arr, 0, sizeof(arr));
```

### 2. Resetting a Vector
#### A. `std::fill`
`std::fill` is also good for vectors to overwrite all elements back to 0 while keeping the vector size.

```cpp
std::vector<int> vec(1000, 5); // Size 1000, filled with 5s

// Efficiently overwrites everything to 0
std::fill(vec.begin(), vec.end(), 0);
```

#### B. `clear` & `reserve`
`clear` is good when you want to completely empty the vector to start adding fresh elements using `push_back`. Calling `clear` sets the vector's size to 0, but it keeps the underlying allocated memory capacity intact. So it makes next `push_back` operations very fast because no new memory allocations are needed.

```cpp
std::vector<int> vec = {1, 2, 3, 4, 5};

vec.clear(); // Size is now 0, but capacity remains what it was.
```

#### C. `assign`
`assign` is perfect for wiping the old data and simultaneously change its size to a new specific count.

```cpp
std::vector<int> vec = {1, 2, 3};

// Wipes the old data, changes size to 1000, fills all with 0
vec.assign(1000, 0);
```

## ⏩ Pointer Aliasing in Comparison
Look at these two versions of code to assign the smaller number to `a`, and the bigger one to `b`:

A.

```cpp
for(int i=0; i<hn; ++i){
    int a = (nums[i] < nums[n-1-i] ? nums[i] : nums[n-1-i]);
    int b = (nums[i] < nums[n-1-i] ? nums[n-1-i] : nums[i]);
}
```

B.

```cpp
for(int i=0; i<hn; ++i){
    int v1 = nums[i];
    int v2 = nums[n-1-i];

    int a = v1 < v2 ? v1 : v2;
    int b = v1 < v2 ? v2 : v1;
}
```

A and B perform the same when a compiler optimize A to B well. However, sometimes the compiler can be afraid of optimizing A, when it does not sure the possibility to accidently change the value of `nums[i]` or `nums[n-1-i]` by changing `a` or `b` is absolutely 0%. This is called **pointer aliasing**.

To avoid pointer aliasing and guarantee the code optimization here, assign the array elements' value to other variables like B, or simply use `std::minmax`.

```cpp
for(int i = 0; i < hn; ++i){
    // Automatically figures out the smaller (a) and larger (b) value
    auto [a, b] = std::minmax(nums[i], nums[n-1-i]);
}
```

## ✅ Indirect Sorting
**Indirect sorting** is an algorithm to sort entities' indices instead of creating actual `struct` or `class` for the entities and then sort them.

![Indirect Sorting](indirect_sorting.png)


## ✅ Counting Sort
**Counting sort** is an algorithm to sort entities by increasing some element values as if we are counting them.

![Counting Sort](counting_sort.png)

> This is the part of [the LeetCode Problem 2751 solution](/posts/leetcode-2751/).

Suppose that we need to return the health of $K$ survivors sorting by index, which survived from $N$ robots. Let `idx_vst` is a vector that has survivors' indices. Instead of sorting `idx_vst` and replace the indices to the health values, creating a new vector `hp_vec` having a trash value (here -1) with $N$ size, and put the survivors' health values into `hp_vec`'s corresponding indices. Checking any positive elements in `hp_vec` from $0$-th to $(n-1)$-th will find all survivors' health.

While the former `sort()` takes $O(K log K)$ where $K$ is the number of survivors, the latter takes $O(N)$ where $N$ is the number of robots. Therefore counting sort will save much time when $K$ is big.