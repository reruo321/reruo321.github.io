---
title: Virtual Machine Migration from VirtualBox to Hyper-V
layout: post
date: 2025-12-24
media_subpath: /pics/2025-12-24-migration-from-virtualbox-to-hyper-v/    
image:
    path: ubuntu-01.png
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
3. **A VirtualBox Virtual Machine** - Your virtual machine to migrate.

# Guide
We are going to convert VDI file to VHD and then VHDX.

## 1. VDI to VHD on VirtualBox
Since Hyper-V does not support VDI, at least we need to convert it to VHD.

1) Launch VirtualBox, and click 'File' → 'Tools' → 'Virtual Media Manager'.

![VirtualBox](virtualbox-00.png)

2) Select the VM to convert, and click 'Copy'.

![VirtualBox](virtualbox-01.png)

3) Configure these and click Finish.

(1) Location and disk size

(2) Hard disk file type and format - **IMPORTANT: Select VHD.**

(3) Full size pre-allocation - It depends on your case.

![VirtualBox](virtualbox-02.png)

## 2. (Optional) VHD to VHDX on Hyper-V
Hyper-V says while VHD supports virtual hard disks up to 2,040 GB, VHDX supports up to 64TB and is resilient to consistency issues. Therefore I also converted VHD to VHDX. Note that VHDX is not supported in OS earlier than Windows 8.

1) Launch Hyper-V Manager, and select 'Edit Disk' from the right side 'Actions' pane.

![Hyper-V](hyper-v-00.png)

2) Click Next.

![Hyper-V](hyper-v-01.png)

3) Find the VHD you will convert and click Next.

![Hyper-V](hyper-v-02.png)

4) Select 'Convert' and click Next.

![Hyper-V](hyper-v-03.png)

5) Select 'VHDX' and click Next.

![Hyper-V](hyper-v-04.png)

6) Decide full size pre-allocation by yourself and click Next. I chose to do it as before.

![Hyper-V](hyper-v-05.png)

7) Decide the VHDX destination and click Next.

![Hyper-V](hyper-v-06.png)

8) Click Finish.

![Hyper-V](hyper-v-07.png)

## 3. Creating a New Virtual Machine with Hyper-V
Almost done! Now let's move on to create a new virtual machine.

1) On the 'Actions' pane, click 'New' → 'Virtual Machine'. It will pop up 'New Virtual Machine Wizard'.

![Hyper-V](hyper-v-08.png)

2) Click Next.

![Hyper-V](hyper-v-09.png)

3) Name your new virtual machine.

![Hyper-V](hyper-v-10.png)

4) Decide the VM generation. I chose 'Generation 2' for my Ubuntu 22.04. Click Next.

![Hyper-V](hyper-v-11.png)

5) Decide the startup memory and dynamic memory. Click Next.

![Hyper-V](hyper-v-12.png)

6) Choose a network adapter. I chose Default Switch. Click Next.

![Hyper-V](hyper-v-13.png)

7) Select 'Use an existing virtual hard disk' and find the VHDX. Click Next.

![Hyper-V](hyper-v-14.png)

8) Click Finish.

![Hyper-V](hyper-v-15.png)

## 4. Secure Boot Setting
There is one more setting to check before running the Ubuntu VM!

1) Select your VM and click 'Settings' on the right bottom of the Hyper-V Manager.

![Hyper-V](hyper-v-16.png)

2) First select 'Security' tab. Under 'Secure Boot', choose 'Microsoft UEFI Certificate Authority'.

![Hyper-V](hyper-v-17.png)

## 5. Running
All settings are finished! Click 'Start' to run your VM.

![Ubuntu 22.04](ubuntu-00.png)

![Ubuntu 22.04](ubuntu-01.png)

![Ubuntu 22.04](ubuntu-02.png)

DONE!

# Performance Comparison
By comparing with the same Ubuntu 22.04 VM, Hyper-V 10.0 was ×3 faster than VirtualBox 7.2.4.

{% include embed/youtube.html id='17keF-YGaCQ' %}

# Trivia
I also tried to virtualize Japanese Windows 95 with Hyper-V, but failed since Hyper-V is too modern to work with that old-school OS. Not only the OS rejected any mouse/keyboard inputs once I click inside the Windows 95 VM, it was also too weak to accept Hyper-V's generalized Generation 1 VM settings. Waste of time! Take 86Box or PCem, or any other emulator or virtual machine instead. Many old hardware configurations are available for such emulators.

I succeed to run Windows 95 with PCem following this guide: [EmulatorResources/PCem/Windows/Configurations/95 - TASVideos](https://tasvideos.org/EmulatorResources/PCem/Windows/Configurations/95)

There are some modern features that would have blocked the old Windows working on Hyper-V:

1. **Hardware Emulation**: This is the biggest annoying stuff for Hyper-V that blocks Hyper-V users to try Windows 95. While the old Windows expects real legacy hardware like PS/2 mouse, Hyper-V uses virtualized hardware. So the drivers may have been crashed and all OS inputs were paralyzed on the GUI screen.
2. **Memory Handling**: Windows 95 cannot accept memory more than 512 MB. Dynamic memory or large memory allocation from Hyper-V caused bugs.
3. **CPU**: Modern host CPUs are too fast so multi-core would not appropriate for old Windows. I could not fix the protection error even if I limited the virtual processor number to 1. (There are some patches like `FIX95CPU` to resolve such problem.)

# What We Learn
> Let's learn on virtual machine.
{: .prompt-info }

## Emulator vs Virtual Machine

There are mainly two options for this situation:
1. **Virtual Machine**: **Virtualization** is a technology that enables the creation of virtual environments from a single physical machine. And a **virtual machine** is a virtual environment that simulates a physical computer in software form.
    * Ex) Microsoft Hyper-V, Oracle Virtualbox, Broadcom VMware, ...
2. **Emulator**: **Emulator** is a software to simulate another kind of device.
    * Ex) 86Box, PCjs, PCEM, ...

Here is the table to compare virtual machine with emulator.

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

> [What is virtualization?](https://www.ibm.com/think/topics/virtualization)

> [Difference Between Virtualization and Emulation - GeeksforGeeks](https://www.geeksforgeeks.org/software-engineering/difference-between-virtualization-and-emulation/)

## Hypervisor
The hypervisor is the coordination layer in virtualization technology. It supports multiple virtual machines (VMs) running at once.
A type 1 hypervisor, or a bare metal hypervisor, interacts directly with the underlying machine hardware. Meanwhile, A type 2 hypervisor, or hosted hypervisor, interacts with the underlying host machine hardware through the host machine's operating system.

Here is the table to compare type 1 hypervisors with type 2 hypervisors.

| | Type 1 Hypervisor | Type 2 Hypervisor |
|-| ----------------- | ----------------- |
| Synonym | Bare Metal Hypervisor | Hosted Hypervisor |
| Host Machine<br>Hardware Interaction | Directly | Indirectly<br>(Through the host machine's OS) |
| Resource Allocation | Directly access underlying machine resources | Negotitate resource allocation with the OS |
| Ease of Management | △<br>(Requires system administrator-level knowledge) | ○<br>(Like an application of an OS) |
| Performance | ○ | △ |
| Isolation | ○ | △ |

> [What’s the Difference Between Type 1 and Type 2 Hypervisors? - AWS](https://www.geeksforgeeks.org/software-engineering/difference-between-virtualization-and-emulation/)

## Old Windows vs Modern Windows
Some major differences are available between old Windows (95/98/Me) and modern Windows (10/11).

| | Old | Modern |
|-| --- | ------ |
| Boot | Legacy BIOS with MBR<br>2 TB drive limit<br>Requires floppy/CD for installation | UEFI with GPT<br>Secure Boot<br>USB/ISO for installation |
| Kernel | DOS-based 16-bit/32-bit mixed kernel (95/98)<br>Consumer NT kernel (Me) | Fully 64-bit NT kernel |
| ISA | x86 (CISC) | x86-64 (CISC)<br>ARM (RISC) |
| Bit Width | 32-bit | 64-bit |
| Cores | Single-core | Multi-core |
| Parallelism | Sequential | Hyper-threading |
| Permission | Run everything as admin | UAC prompt |
| File System | FAT16/FAT32 | NTFS (+ ReFS for servers) |

![x86](https://www.allaboutcircuits.com/uploads/articles/cpu_block_diagram.png)
_A Rundown of x86 Processor Architecture - Technical Articles_

![Single-core vs Multi-core](https://www.researchgate.net/profile/Abhishek-Sharma-174/publication/274902722/figure/fig1/AS:294779112968199@1447292225763/Block-Diagram-of-Single-core-and-Multi-core-Processor.png)
_Block Diagram of Single-core and Multi-core Processor - Researchgate_

## Terminology

### BIOS
![Boot Process](https://upload.wikimedia.org/wikipedia/commons/thumb/2/20/Legacy_BIOS_boot_process_fixed.png/500px-Legacy_BIOS_boot_process_fixed.png)
_Boot process - Wikipedia_

**Basic Input/Output System** is a type of firmware used to provide runtime services for operating systems and programs and to perform hardware initialization during the booting process (power-on startup).

> [BIOS - Wikipedia](https://en.wikipedia.org/wiki/BIOS)

### MBR
**Master Boot Record** is a type of boot sector in the first block of partitioned computer mass storage devices like fixed disks or removable drives intended for use with IBM PC-compatible systems and beyond.

> [Master Boot Record - Wikipedia](https://en.wikipedia.org/wiki/Master_boot_record)

### GPT
![GPT Scheme](https://upload.wikimedia.org/wikipedia/commons/thumb/0/07/GUID_Partition_Table_Scheme.svg/330px-GUID_Partition_Table_Scheme.svg.png)
_The GUID Partition Table Scheme - Wikipedia_

**GUID Partition Table** is a standard for the layout of partition tables of a physical computer storage device, such as hard disk driveor solid-state drive. It is a part of the UEFI standard.

> [GUID Partition Table - Wikipedia](https://en.wikipedia.org/wiki/GUID_Partition_Table)

### Boot sector
![Boot sector](https://upload.wikimedia.org/wikipedia/commons/thumb/4/45/GNU_GRUB_components.svg/500px-GNU_GRUB_components.svg.png)
_GNU GRUB 2 components distributed over sectors of a hard disk - Wikipedia_

**Boot sector** is sector of a persistent data storage device (e.g., hard disk, floppy disk, optical disc, etc.) which contains machine code to be loaded into random-access memory (RAM) and then executed by a computer system's built-in firmware (e.g., the BIOS).

The figure shows boot.img is written into the boot sector of the hard disk where GRUB is installed.

> [Boot sector - Wikipedia](https://en.wikipedia.org/wiki/Boot_sector)

### UEFI
![UEFI](https://upload.wikimedia.org/wikipedia/commons/thumb/8/89/Logo_of_the_UEFI_Forum.svg/120px-Logo_of_the_UEFI_Forum.svg.png)
_UEFI Logo - Wikipedia_

**Unified Extensible Firmware Interface** is a specification for the firmware architecture of a computing platform. When a computer is powered on, the UEFI implementation is typically the first that runs, before starting the operating system.

> [UEFI - Wikipedia](https://en.wikipedia.org/wiki/UEFI)

### Secure Boot
The UEFI specification defines a protocol known as **Secure Boot**, which can secure the boot process by preventing the loading of UEFI drivers or OS boot loaders that are not signed with an acceptable digital signature.

> [Secure Boot - Wikipedia](https://en.wikipedia.org/wiki/UEFI#Secure_Boot)

### Kernel
![Kernel](https://upload.wikimedia.org/wikipedia/commons/thumb/8/8f/Kernel_Layout.svg/250px-Kernel_Layout.svg.png)
_A kernel connecting applications to the hardware of a computer - Wikipedia_
![Kernel Architecture](https://upload.wikimedia.org/wikipedia/commons/thumb/d/d0/OS-structure2.svg/960px-OS-structure2.svg.png)

A **kernel** is a computer program at the core of a computer's operating system that always has complete control over everything in the system.

Some example of kernel architectures are:
* **Microkernel**: Near-minimum amount of software including low-level address space management, thread management, and inter-process communication (IPC)
* **Monolithic kernel**: An operating system architecture with the entire operating system running in kernel space
* **Hybrid Kernel**: Microkernel + Monolithic Kernel
    * Examples: NT kernel, XNU kernel, ...

> [Kernel - Wikipedia](https://en.wikipedia.org/wiki/Kernel_(operating_system))

> [Microkernel - Wikipedia](https://en.wikipedia.org/wiki/Microkernel)

> [Monolithic kernel - Wikipedia](https://en.wikipedia.org/wiki/Monolithic_kernel)

> [Hybrid kernel - Wikipedia](https://en.wikipedia.org/wiki/Hybrid_kernel)

#### NT Kernel
![NT 3.1](https://upload.wikimedia.org/wikipedia/commons/thumb/4/41/NT_3.1_layers.png/640px-NT_3.1_layers.png)
_The architecture of Windows NT 3.1, the very first version of the Windows NT family - Wikipedia_
![NT Architecture](https://upload.wikimedia.org/wikipedia/commons/thumb/5/5d/Windows_2000_architecture.svg/330px-Windows_2000_architecture.svg.png)
_The Windows NT operating system family's architecture - Wikipedia_

The architecture of Windows NT is a layered design that consists of two main components, user mode and kernel mode. It is a preemptive, reentrant multitasking operating system, which has been designed to work with uniprocessor and symmetrical multiprocessor (SMP)-based computers. To process I/O requests, it uses packet-driven I/O, which utilizes I/O request packets (IRPs) and asynchronous I/O.

The NT kernel has been always hybrid. It is a mixture of monolithic efficiency with some microkernel modularity, including the Executive services, HAL for hardware portability, and drivers running in kernel mode. The hybrid nature started with NT 3.1 in 1993 and remains today in Windows 10/11. While those modern Windows has 64-bit kernel, they can support 32-bit apps via WoW64 (Windows-on-Windows 64-bit emulation layer).

> [Architecture of Windows NT - Wikipedia](https://en.wikipedia.org/wiki/Architecture_of_Windows_NT)

### History of OS
![OS](https://preview.redd.it/azoeztp0a2a81.png?width=1080&crop=smart&auto=webp&s=054696af3c1c3b05bfb6265a4ce7251b2540d662)

### ISA
An **Instruction Set Architecture** is an abstract model that defines the programmable interface of the CPU of a computer, defining how software interacts with hardware.

> [Instruction set architecture - Wikipedia](https://en.wikipedia.org/wiki/Instruction_set_architecture)
