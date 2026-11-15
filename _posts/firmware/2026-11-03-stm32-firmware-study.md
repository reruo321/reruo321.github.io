---
title: STM32 Firmware Study
description: My study on STM32 Firmware.
layout: post
date: 2026-11-03
media_subpath: /pics/firmware/2026-11-03-stm32-firmware-study/
categories: firmware
tags: [firmware, STM32, Nucleo, NUCLEO-F103RB, STM32F103RBT6]
math: true
---

## ✅ STM32CubeIDE Tips
* To see the full function documentation pop-up, hover your cursor over the function name and press `F2`.
* To find the definition of a function, hover your cursor over the function name and press `F3`.
* To see the parameter hint pop-up while typing inside the parentheses `(...)`, place your cursor inside the function's parentheses and press `Ctrl + Shift + Space`. (Windows/Linux)
* Auto-complete feature gives some default proposals to easily find a function or an argument which are defined somewhere. For example, to auto-complete `HAL_UART_Transmit(...)`, type `HAL_UART_` and press `Ctrl + Space`. And to find any candidates for the first argument, `Ctrl + Space` on the `huart`. It'll show something like `huart1` and `huart2`. Don't forget to add `&` if you are going to refer some address!

## ✅ HAL
**HAL (Hardware Abstraction Layer)** is an abstraction layer, implemented in software, between the physical hardware of a computer and the software that runs on that computer. In ST's HAL library, almost every function provided by ST starts with `HAL_`. The naming convention look like this:

> HAL_ + [PERIPHERAL] + _ + [ACTION]

## ✅ JTAG vs SWD
![JTAG-vs-SWD](JTAG-vs-SWD.webp)
_JTAG vs SWD: Choosing a Debug Interface for Embedded Systems - PCBCOOL_

Both are industry standard for verifying designs of and testing printed circuit boards after manufacture. That is, both are interface for debugging and programming MCUs or embedded systems.

For example, interfaces such as ST-LINK or Raspberry Pi Debug Probe have either JTAG or SWD (or both) for debugger or programmer. Some devices such as ARTIK 053 can even provide such interfaces by default.

Article: [What Is SWD and How Does It Compare to JTAG?](https://www.digikey.kr/en/maker/blogs/2026/what-is-swd-and-how-does-it-compare-to-jtag)

### 1️⃣ JTAG
**Joint Test Action Group (JTAG)** is a serial protocol using at least 4~5 pins, `TCK`, `TMS`, `TDI`, `TDO`, and optionally `TRST`. It shifts data through a scan chain and can address multiple devices.

#### Pros
* **Universal Compatibility**: Can be supported by almost all major microprocessors, microcontrollers, FPGAs, and DSPs.
* **Boundary Scan Testing Support**: Can test the physical connections on a PCB without using physical probes.
* **Daisy-Chaining**: Can connect multiple ICs in a single serial chain, (scan chain) which allows a single JTAG debugger header to program and debug multiple chips on the same board.

#### Cons
* **Complex Hardware Interface**: It requires at least 4 to 5 pins, and often up to 20 pins for standard debugging headers.

### 2️⃣ SWD
**Serial Wire Debug (SWD)** is a two-wire hardware interface and protocol developed by ARM. It has a bidirectional serial data line (`SWDIO`) and a synchronization clock (`SWCLK`). It uses an ARM CPU standard bi-directional wire protocol. It exchanges structed packets between a debugger and a single target in alternating turns.

#### Pros
* **Simpler Hardware Interface**: It uses only 2 pins and 2 lines, which frees up MCU pins and reduces routing complexity. More freed up MCU pins means more extra microcontroller pins for actual application use (like SPI, I2C, or GPIOs), and simpler routing complexity allows the use of microscopic (very small) headers. Therefore it's PCB-friendly and can become the absolute standard for compact devices like wearables and IoT gadgets.
* **Optimized for ARM Cortex**: It offers special features for ARM-based MCUs.
* **Better Debugging Performance**: Because it is intended for debugging, its debugging performance is better than JTAG which was originally developed for boundary-scan testing.

#### Cons
* **Not Available in Non-ARM devices**
* **No Boundary-Scan Testing**: It is designed just for debugging and firmware flashing, so it cannot be used for board-level testing.
* **No Daisy-Chaining**: Since it uses a point-to-point link, it cannot access multiple ICs at the same time via scan chain.
* **Communicate In Turns**[^1]: Since it has a single bidirectional data line, the devices cannot transmit and receive data at the same time.
* **Low Reliability on Asynchronous Mode**: In the asynchronous mode, it drops the clock signal, making it a one-wire interface. However the mode is rarely used due to the increased reliability the clock provides.

### Table
| | **JTAG** | **SWD** |
| - | - | - |
| **Target Architecture** | Universal | ARM Cortex series only |
| **Minimum Pin Count** | 4~5 | 2 |
| **Hardware Interface** | Complex | Simple |
| **Hardware Testing** | O, Boundary Scan Testing | X |
| **Multi-Device Support** | O, Daisy-chaining | X, Point-to-point (1:1 only) |

---

## ✅ Button Interrupts
Hardware EXTI line interrupts fire on edge transitions. Assume that a button use a pull-up resistor. (Active-LOW circuit) Its default state is HIGH, and when it is pressed, it is connected directly to GND so it drops to LOW.

* **Rising Edge**: Fires the interrupt when you release the button.
* **Falling Edge**: Fires the interrupt the exact instant you press the button down.
* **Both Edges**: Fires twice—once when pressed and once when released. Useful if you want to measure how long a button was held down.

The interrupts do not fire on static signal levels. Therefore, if you need continuous detection while a button is held down, polling a standard GPIO pin or using a timer-based debouncing task in FreeRTOS is the proper approach.

## ✅ FLASH vs SRAM
From Build Analyzer on the IDE, you can see various sections are available in **FLASH (ROM)** and **RAM**.

![memory_detail](memory_detail.png)

FLASH and SRAM in STM32F103RB are separate, physical silicon memory blocks inside the board. FLASH is 128 KB, Meanwhile, SRAM is 20 KB. We cannot see them without decapsulate the MCU, however we can check their digital status with some tools.

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

## ✅ Finding Start and End Addresses of Sections
1. Memory Detail
2. Map File
3. Linker Script
### 1. Memory Detail
### 2. Map File
![map_file](map_file.png)

### 3. Linker Script
The linker script (`.ld`) file in the project root shows how the sections are structured dynamically.

![linker_script](linker_script.png)

The startup code utilizes these exact symbols (`_sbss` and `_ebss`) to know exactly where to start and stop clearing the RAM to zero.

## Notes
[^1]: "In turns" means "one after the other", "번갈아 가며" in Korean.