---
title: Useful C++ Tricks
layout: post
date: 2026-04-28
media_subpath: /pics/2026-04-28-useful-cpp-tricks/
categories: programming
tags: [programming, C++]
---

## Lambda Expression
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