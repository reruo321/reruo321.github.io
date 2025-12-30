---
title: Installing Windows 95 with Hyper-V
layout: post
date: 2025-12-24
categories: etc
tags: [Windows 95, Hyper-V, virtual machine]
---

# Introduction
Today I want to share how I could manage to virtualize Windows 95 with Microsoft Hyper-V.

I wanted to try an old-school Japanese CD-ROM game, but the game installation failed in my Korean Windows 11, even with the Windows 95 Compatibility Mode. While the installation, I could not totally understand what the Japanese error said, and what the garbled text was (in a nutshell, "mojibake"). So I thought installing proper environment would be better than struggling with the alien letters and my modern OS.

There are mainly two options for this situation:
1. **Virtual Machine**: **Virtualization** is a technology that enables the creation of virtual environments from a single physical machine. And a **virtual machine** is a virtual environment that simulates a physical computer in software form.[^1]
    * Ex) Microsoft Hyper-V, Oracle Virtualbox, Broadcom VMware, ...
2. **Emulator**: **Emulator** is a software to simulate another kind of device.
    * Ex) 86Box, PCjs, PCEM, ...

Here is the table to compare virtual machine with emulator.[^2]

| | Virtual Machine | Emulator |
|-| -------------- | --------- |
| Definition | Virtual environment | Device simulator |
| Capacity | Full capacity of physical machines | Runs software |
| Purpose | Centralizes administrative tasks | Unites interface and characteristics of subsystems |
| Environment | Isolated | Shared |
| Hardware Accessibility | Direct access | Requires software bridge |
| Operating Cost | △<br>(Higher than emulator) | ○ |
| Backup | ○ | △ |
| Speed | ○ | △ |

Because I preferred the good performance to the real vintage Windows 95 experience, I chose **1. Virtual Machine** that can directly make use of my good PC resources!

Also, I decided to use **Hyper-V** for most virtualization including Windows 95. I had used Virtualbox for 5 years, but recently Grok suggested Hyper-V so I tried it for my Ubuntu 22.04 migration. And WOW! It is x2 ~ x3 faster than Virtualbox! Now I am a big fan of type 1 hypervisors. That's why I am installing Windows 95 with Hyper-V.

Here is the table to compare type 1 hypervisors with type 2 hypervisors.[^3]

## Prerequisites
1. Windows 95 Floppy disk file - Download it from somewhere for free, and change its extension from .img to .vfd.
2. Windows 95 Disk

## Installation


[^1]: [What is virtualization?](https://www.ibm.com/think/topics/virtualization)
[^2]: [Difference Between Virtualization and Emulation - GeeksforGeeks](https://www.geeksforgeeks.org/software-engineering/difference-between-virtualization-and-emulation/)
[^3]: [What’s the Difference Between Type 1 and Type 2 Hypervisors? - AWS](https://www.geeksforgeeks.org/software-engineering/difference-between-virtualization-and-emulation/)
