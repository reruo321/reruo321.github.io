---
title: Installing Windows 95 with Hyper-V
layout: post
date: 2025-12-24
media_subpath: /pics/2025-12-24-install-windows-95-hyper-v/    
image:
    path: win95-fdisk-00.png
description: Learn how to virtualize Windows 95 with Microsoft Hyper-V.
categories: etc
tags: [Windows 95, Hyper-V, virtual machine]
---

# Introduction
Today I want to share how I could manage to virtualize Windows 95 with Microsoft Hyper-V.

I wanted to try an old-school Japanese CD-ROM game, but the game installation failed in my Korean Windows 11, even with the Windows 95 Compatibility Mode. While the installation, I could not totally understand what the Japanese error said, and what the garbled text (mojibake) was. So I thought installing proper environment would be better than struggling with the alien letters and my modern OS.

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

Because I preferred the good performance to the real vintage Windows 95 experience, I chose **1. Virtual Machine** that can directly make use of my good PC resources!

Also, I decided to use **Hyper-V** for most virtualization including Windows 95. I had used Virtualbox for 5 years, but recently Grok suggested Hyper-V so I tried it for my Ubuntu 22.04 migration. And WOW! It is x2 ~ x3 faster than Virtualbox! Now I am a big fan of type 1 hypervisors. That's why I am installing Windows 95 with Hyper-V.

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


## Prerequisites
1. Microsoft Hyper-V - Basically provided in Windows Server and Windows 10/11 Pro/Enterprise Edition.
2. Windows 95 floppy disk file - Download it for free online, and change its extension name to `.vfd` if it is `.img`.
3. Windows 95 image file - Download it for free online. Its extension should be `.iso`.

## Installation
### Hyper-V Virtual Machine Wizard
1. On the 'Actions' pane select 'Create Virtual Machine'.
![Create Virtual Machine](hyper-v-virtual-machine-wizard-00.png)
2. Click 'Next'.
![Virtual Machine Wizard 1](hyper-v-virtual-machine-wizard-01.png)
3. Specify the name and location of the virtual machine and click 'Next'.
![Virtual Machine Wizard 2](hyper-v-virtual-machine-wizard-02.png)
4. **IMPORTANT: Set Generation 1** and click 'Next'.
![Virtual Machine Wizard 3](hyper-v-virtual-machine-wizard-03.png)
5. Set the startup memory and click 'Next'.
![Virtual Machine Wizard 4](hyper-v-virtual-machine-wizard-04.png)
6. Set the network connection and click 'Next'.
![Virtual Machine Wizard 5](hyper-v-virtual-machine-wizard-05.png)
7. Check 'Create a virtual hard disk', configure, and click 'Next'.
![Virtual Machine Wizard 6](hyper-v-virtual-machine-wizard-06.png)
8. Check 'Install an operating system from a bootable floppy disk', select `.vfd` file, and click 'Next'.
![Virtual Machine Wizard 7](hyper-v-virtual-machine-wizard-07.png)
9. Click 'Finish'.
![Virtual Machine Wizard 8](hyper-v-virtual-machine-wizard-08.png)
10. Select 'Connect' to open a connection to the VM.
![Virtual Machine Wizard 9](hyper-v-virtual-machine-wizard-09.png)
11. You will see this window.
![Virtual Machine OFF](win95-virtual-machine-off-00.png)
12. On the VM's menu click 'Media' → 'DVD Drive' → 'Insert Disk', and select `.iso` file. Then select 'Start' to run the VM.
![Attaching the ISO image](win95-virtual-machine-off-01.png)

### Disk Partitioning with `FDISK`


## Notes

[^1]: [What is virtualization?](https://www.ibm.com/think/topics/virtualization)
[^2]: [Difference Between Virtualization and Emulation - GeeksforGeeks](https://www.geeksforgeeks.org/software-engineering/difference-between-virtualization-and-emulation/)
[^3]: [What’s the Difference Between Type 1 and Type 2 Hypervisors? - AWS](https://www.geeksforgeeks.org/software-engineering/difference-between-virtualization-and-emulation/)
