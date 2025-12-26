---
title: Installing Windows 95 with Hyper-V
layout: post
date: 2025-12-24
categories: etc
tags: [Windows 95, Hyper-V, virtual machine]
---

# Introduction
I wanted to try an old-school Japanese CD-ROM game, but the game installation failed in my Korean Windows 11. I could not understand what the Japanese error said, but I thought installing proper environment would be better than struggling with the alien letters and my modern OS.

There are mainly two options for this situation:
1. **Virtualization**: Virtualization is a process of creating virtual version of something like OS, server, storage device, etc..
    * Ex) Microsoft Hyper-V, Oracle Virtualbox, Broadcom VMware, ...
2. **Emulation**: Emulation is a process of simulating another kind of device.
    * Ex) 86Box, PCjs, PCEM, ...

Because I preferred the good performance to the real vintage Windows 95 experience, I chose **1. Virtualization** that can directly make use of my good PC resources![^1]

Also, I decided to use **Hyper-V** for most virtualization including Windows 95. I had used Virtualbox for 5 years, but recently Grok suggested Hyper-V so I tried it for my Ubuntu 22.04 migration. And WOW! It is x2 ~ x3 faster than Virtualbox! Now I am a big fan of type 1 hypervisors.[^2] That's why I am installing Windows 95 with Hyper-V.

## Installation

[^1]: [Difference between Virtualization and Emulation - GeeksforGeeks](https://www.geeksforgeeks.org/software-engineering/difference-between-virtualization-and-emulation/)
[^2]: [What’s the Difference Between Type 1 and Type 2 Hypervisors? - AWS](https://www.geeksforgeeks.org/software-engineering/difference-between-virtualization-and-emulation/)