---
title: Edge RTOS Control
description: My first edge RTOS control project.
layout: post
date: 2026-08-05
media_subpath: /pics/firmware/2026-08-05-edge-rtos-control/
categories: firmware
tags: [firmware, STM32, Nucleo, NUCLEO-F103RB]
---

## Introduction
In August 2026, I started my first edge RTOS control project with NUCLEO-F103RB and Raspberry Pi 5. Not only I could be more familiar with firmware and embedded programming, I also got significant insights on computer science.

## Project Configuration
Here are configurations for setting the FreeRTOS project for NUCLEO-F103RB with STM32CubeMX.

### Pinout & Configuration
![mx_conf_0](mx_conf_0.png)

Click [System Core] → [SYS] on the left sidebar. On `Mode` → `Timebase Source`, change `SysTick` to `TIM1` (or `TIM2`). This prevents the collision between the default SysTick timer and FreeRTOS.

![mx_conf_1](mx_conf_1.png)

Click [Connectivity] → [USART1] on the left sidebar. On `Mode` → `Mode`, select `Asynchronous`.

Look at the configurations below. On [DMA Settings], add `USART1_RX` and `USART1_TX`.

A **USART(Universal Synchronous/Asynchronous Receiver/Transmitter)** is a piece of hardware that lets devices send and receive serial data. It operates full-duplex operation, which means it can send and receive data at the same time using separate internal registers.

It is an upgraded version of a standard **UART** which works asynchronously. It can work in both asynchronous mode and synchronous mode.

* **Asynchronous Mode**: The device uses a single data line to send data. Both devices must agree beforehand on the speed (baud rate) to interpret the bits correctly.
* **Synchronous Mode**:  The device uses a data line plus an extra clock line (`CLK`). The clock signal keeps both devices perfectly matched in time. This allows for faster and more efficient data transfers, but it requires an extra wire pin.

![mx_conf_2](mx_conf_2.png)

Additionally, set the mode of `USART1_RX`'s DMA Request Settings to `Circular`. It helps USART1_RX to continuously receive the message.

* **Normal**: After transferring a fixed number of bytes/items once, halts.
* **Circular**: Reaches the end of the destination/source buffer, automatically resets the address/counter pointers, and wraps back to index 0 without stopping.

![mx_conf_3](mx_conf_3.png)

On [NVIC Settings], enable `USART1 global interrupt`. It enables to capture the IDLE line event (`UART_IT_IDLE`) so that the CPU can know when a full message finished arriving from the Pi.

![mx_conf_4](mx_conf_4.png)

On [Parameter Settings], ensure `Baud Rate` is 115200 Bits/s, and `Word Length` is 8 Bits (including Parity).

![mx_conf_5](mx_conf_5.png)

Click [Middleware and Software Packs] → [FREERTOS] on the left sidebar. On `Mode` → `Interface`, select `CMSIS_V2`. On [Tasks and Queues] below, set two new tasks, `Task_Control` and `Task_UART`. (I changed the default task name to `Task_Status`.) Set `Task_Control` priority to `osPriorityHigh`, and `Task_UART` to `osPriorityNormal`.

* `Task_Status`: Task on background maintenance
    * Example: Toggling the onboard LD2 status LED
    * Priority: Low, toggling an indicator LED is low urgency, so the task has low priority.
* `Task_Control`: Task on the primary decision-making task
    * Example: motor safety commands, parsing critical Pi commands
    * Priority: High, in real-time edge controls, parsing commands or reacting to control signals must interrupt background routines immediately to guarantee low latency.
* `Task_UART`: Task on processing non-critical serial telemetry or prepares diagnostic strings to send back to the Pi
    * Priority: Normal, standard telemetry can yield to high-priority control tasks without affecting hardware safety.

![mx_conf_6](mx_conf_6.png)

Select [Project Manager] tab. On [Project], change `Toolchain / IDE` to `STM32CubeIDE`.

![mx_conf_7](mx_conf_7.png)

On [Code Generator], choose `Copy only the necessary library files`, and check `Generate peripheral initialization as a pair of '.c/.h' files per peripheral`.

![build_console](build_console.png)

You can also see some kinds of information on the CDT Build Console.

##

## Study
### Flash vs SRAM
From Build Analyzer on the IDE, you can see various sections are available in **FLASH (ROM)** and **RAM**.

![memory_detail](memory_detail.png)

FLASH and SRAM in STM32F103RB are separate, physical silicon memory blocks inside the board. FLASH is 128 KB, Meanwhile, SRAM is 20 KB.

FLASH looks like this, which operates completely different from the flash memory (SSDs) used in a normal PC.

```
[ FLASH End: 0x0801 FFFF (128KB) ]
┌──────────────────────────┐
│ Page 127 (2KB)           │ <- Last page (Often used for user data backup / non-volatile config)
├──────────────────────────┤
│ ...                      │
├──────────────────────────┤
│ Page 1 (2KB)             │ 
├──────────────────────────┤
│ Page 0 (2KB)             │ <- Main Memory Start (0x0800 0000)
│  ┌────────────────────┐  │
│  │ .rodata            │  │ <- Read-Only Data (Constants, string literals)
│  ├────────────────────┤  │
│  │ .text              │  │ <- Executable Code (Compiled machine instructions & functions)
│  ├────────────────────┤  │
│  │ .data (Init Values)│  │ <- Initial values of global/static variables (Copied to SRAM at boot)
│  ├────────────────────┤  │
│  │ Interrupt Vectors  │  │ <- Vector Table (Reset, SysTick, and peripheral ISR addresses)
│  ├────────────────────┤  │
│  │ Initial SP Value   │  │ <- Absolute Start: Initial Main Stack Pointer (MSP) value
│  └────────────────────┘  │
└──────────────────────────┘
[ FLASH Start: 0x0800 0000 ]
```

Here are major differences between two types of FLASH:

| **Feature** | **NOR FLASH**<br>**(e.g. NUCLEO-F103RB)** | **NAND FLASH**<br>**(e.g. PC SSD / USB Drive)** |
| - | - | - |
| **Primary Use** | Code execution<br>Bootloaders<br>Firmware storage | Bulk data storage<br>Files<br>Operating systems |
| **Primary Use** | Byte-addressable<br>(Random access like RAM) | Block/Page-addressable (Serial access) |
| **Execute-in-Place**<br>**(XIP)** | Yes<br>The CPU can run code directly from FLASH. | No.<br>Code |
| **Read Speed** | Very fast | Fast, but high initial latency for random reads |
| **Write/Erase Speed** | Very slow | Fast |
| **Storage Density** | Low (Typically 32KB~a few MB) | Extremely high (GB~TB) |
| **Cost per Bit** | High | Low |

Meanwhile, SRAM looks like this, which seems similar to the RAM in a normal computer.

```
[ SRAM End: 0x2000 5000 (20KB) ]
┌──────────────────────────┐
│ Stack                    │ <- Local variables & function calls (grows downward)
│      ↓                   │
│      ↑                   │
│ Heap                     │ -> Dynamic memory via malloc() (grows upward)
├──────────────────────────┤
│ .bss                     │ <- Uninitialized global/static variables (cleared to 0 at boot)
├──────────────────────────┤
│ .data                    │ <- Initialized global/static variables (copied from Flash)
└──────────────────────────┘
[ SRAM Start: 0x2000 0000 ]
```

### Finding Start and End Addresses of Sections
1. Memory Detail
2. Map File
3. Linker Script
#### 1. Memory Detail
#### 2. Map File
![map_file](map_file.png)

#### 3. Linker Script
The linker script (`.ld`) file in the project root shows how the sections are structured dynamically.

![linker_script](linker_script.png)

The startup code utilizes these exact symbols (`_sbss` and `_ebss`) to know exactly where to start and stop clearing the RAM to zero.
