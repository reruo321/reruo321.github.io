---
title: Big-endian MIPS Compiler on Ubuntu
description: Easy big-endian experiment setup without installing full system
layout: post
date: 2026-02-24
media_subpath: /pics/2026-02-24-big-endian-mips-compiler-on-ubuntu/
image:
    path: mips.png
categories: computer-system
tags: [big-endian, MIPS, Ubuntu]
---

## Introduction
It's very useful when you want to make use of your Ubuntu virtual machine, but you don't want to install additional emulator or virtual machine for MIPS compiler or any big-endian tests.

## Steps
My environment: Ubuntu 22.04 virtual machine on Windows 11 Hyper-V

1. Install QEMU inside an Ubuntu virtual machine. It helps the little endian machine x86-64 Ubuntu to automatically emulate the MIPS CPU instructions and handle endianness differences between the host and the guest.
```bash
sudo apt update
sudo apt install qemu-user-static binfmt-support
```

2. Install big-endian MIPS compiler.
```bash
sudo apt install gcc-mips-linux-gnu
```

3. Use either of these commands to cross-compile for big-endian MIPS.
```bash
mips-linux-gnu-gcc hello.c -o hello-mips-be -static
```
or
```bash
mips-linux-gnu-gcc -EB -mips32 hello.c -o hello-mips-be -static
```

## Test
If you want to check if a file is compiled with the MIPS compiler, enter `file my-file-name`.

![mips_file](mips_file.png)

DONE!