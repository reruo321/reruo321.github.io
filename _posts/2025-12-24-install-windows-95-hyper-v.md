---
title: Virtual Machine Migration from VirtualBox to Hyper-V
layout: post
date: 2025-12-24
media_subpath: /pics/2025-12-24-migration-from-virtualbox-to-hyper-v/    
# image:
#     path: 
description: Learn how to migrate a VirtualBox virtual machine to Hyper-V.
categories: OS
tags: [Ubuntu, VirtualBox, Hyper-V, virtual machine]
---

# Introduction
Today I want to share how I could move Ubuntu 22.04 virtual machine from Oracle VirtualBox to Microsoft Hyper-V.

Recently, I heard from Grok that Microsoft Hyper-V performs way better than VirtualBox to virtualize Ubuntu 22.04 in Windows 11. The biggest difference between them is while Hyper-V is type 1 hypervisor, VirtualBox is type 2 hypervisor. In a nutshell, Hyper-V can make use of PC resources much better as if it is running on the bare-metal hardware.

## Prerequisites
1. **Microsoft Hyper-V** - Basically provided in Windows Server and Windows 10/11 Pro/Enterprise Edition.
2. **Oracle VM VirtualBox** - Download it for free online. You need this for converting `.vdi` to `.vhd`.
3. **A VirtualBox Virtual Machine** - Your virtual machine.

# Trivia
I also tried to virtualize Japanese Windows 95 with Hyper-V, but failed since Hyper-V is too modern to work with that old-school OS. Not only the OS rejected any mouse/keyboard inputs once I click inside the Windows 95 VM, it was also too weak to accept Hyper-V's generalized Generation 1 VM settings. Waste of time! Take 86Box or PCem, or any other emulator or virtual machine instead. Many old hardware configurations are available for such emulators.

I succeed to run Windows 95 with PCem and this guide: [EmulatorResources/PCem/Windows/Configurations/95 - TASVideos](https://tasvideos.org/EmulatorResources/PCem/Windows/Configurations/95)

There are some modern features that would have blocked the old Windows working on Hyper-V:

1. **Hardware Emulation**: This might be the biggest annoying stuff that blocks Hyper-V users to try Windows 95. While the old Windows expects real legacy hardware like PS/2 mouse, Hyper-V uses virtualized hardware. So the drivers might have been crashed and all OS inputs were paralyzed.
2. **Memory Handling**: Windows 95 cannot accept memory more than 512 MB. Dynamic memory or large memory allocation from Hyper-V caused bugs.
3. **CPU**: Modern host CPUs are too fast so multi-core would not appropriate for old Windows. I could not fix the protection error even if I limited the virtual processor number to 1. (There is a patch like `FIX95CPU` to resolve this problem.)

# What We Learned
> Learn about virtual machine below.
{: .prompt-info }

## Emulator vs Virtual Machine

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
| Operating Cost | △<br>(More expensive) | ○ |
| Backup | ○ | △ |
| Speed | ○ | △ |

## Hypervisor
The hypervisor is the coordination layer in virtualization technology. It supports multiple virtual machines (VMs) running at once.
A type 1 hypervisor, or a bare metal hypervisor, interacts directly with the underlying machine hardware. Meanwhile, A type 2 hypervisor, or hosted hypervisor, interacts with the underlying host machine hardware through the host machine's operating system.

Here is the table to compare type 1 hypervisors with type 2 hypervisors.[^3]

| | Type 1 Hypervisor | Type 2 Hypervisor |
|-| ----------------- | ----------------- |
| Synonym | Bare Metal Hypervisor | Hosted Hypervisor |
| Host Machine<br>Hardware Interaction | Directly | Indirectly<br>(Through the host machine's OS) |
| Resource Allocation | Directly access underlying machine resources | Negotitate resource allocation with the OS |
| Ease of Management | △<br>(Requires system administrator-level knowledge) | ○<br>(Like an application of an OS) |
| Performance | ○ | △ |
| Isolation | ○ | △ |

## Notes

[^1]: [What is virtualization?](https://www.ibm.com/think/topics/virtualization)
[^2]: [Difference Between Virtualization and Emulation - GeeksforGeeks](https://www.geeksforgeeks.org/software-engineering/difference-between-virtualization-and-emulation/)
[^3]: [What’s the Difference Between Type 1 and Type 2 Hypervisors? - AWS](https://www.geeksforgeeks.org/software-engineering/difference-between-virtualization-and-emulation/)
