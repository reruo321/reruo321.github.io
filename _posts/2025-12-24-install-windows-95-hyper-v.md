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
Hyper-V says while VHD supports virtual hard disks up to 2,040GB, VHDX supports up to 64TB and is resilient to consistency issues. Therefore I also converted VHD to VHDX. Note that VHDX is not supported in OS earlier than Windows 8.

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
All settings are finished! Select 'Start' to run your VM.

![Ubuntu 22.04](ubuntu-00.png)

![Ubuntu 22.04](ubuntu-01.png)

![Ubuntu 22.04](ubuntu-02.png)

DONE!

# Performance Comparison


# Trivia
I also tried to virtualize Japanese Windows 95 with Hyper-V, but failed since Hyper-V is too modern to work with that old-school OS. Not only the OS rejected any mouse/keyboard inputs once I click inside the Windows 95 VM, it was also too weak to accept Hyper-V's generalized Generation 1 VM settings. Waste of time! Take 86Box or PCem, or any other emulator or virtual machine instead. Many old hardware configurations are available for such emulators.

I succeed to run Windows 95 with PCem following this guide: [EmulatorResources/PCem/Windows/Configurations/95 - TASVideos](https://tasvideos.org/EmulatorResources/PCem/Windows/Configurations/95)

There are some modern features that would have blocked the old Windows working on Hyper-V:

1. **Hardware Emulation**: This is the biggest annoying stuff for Hyper-V that blocks Hyper-V users to try Windows 95. While the old Windows expects real legacy hardware like PS/2 mouse, Hyper-V uses virtualized hardware. So the drivers may have been crashed and all OS inputs were paralyzed on the GUI screen.
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
