---
title: Useful C++ Tricks
layout: post
date: 2026-04-28
media_subpath: /pics/2026-04-28-useful-cpp-tricks/
categories: programming
tags: [programming, C++]
---

## Lambda Expression
```cpp
static const int fast_io = [](){
    ios::sync_with_stdio(false);
    cin.tie(NULL);
    cout.tie(NULL);
    return 0;
}();
```

Before the main function, the code immediately runs three performance optimizations inside a lambda expression, and then destroys. It is useful for optimizing resources like LeetCode solutions.

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
**IIFE(Immediately Invoked Function Expression)** immediately runs statements inside a lambda expression then destroys it. The destruction prevents the expression to be called again accidently. It can be attached right after to the definition of a lambda expression.