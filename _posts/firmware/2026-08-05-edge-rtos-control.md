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

The NUCLEO-F103RB board has a MCU called STM32F103RB, which contains an Arm Cortex-M3 32-bit RISC core (CPU). It features FLASH up to 128 Kbytes and SRAM up to 20 Kbytes.

## Prerequisite
* NUCLEO-F103RB board
* Raspberry Pi 5
* Wire × 3

### Documents
#### NUCLEO-F103RB
* Datasheet for STM32F103RB (**DS5319**) - From [here](https://www.st.com/en/microcontrollers-microprocessors/stm32f103rb.html)
* User Manual for NUCLEO-F103RB (**UM1724**) - From [here](https://www.st.com/en/evaluation-tools/nucleo-f103rb.html#documentation)
* Board Schematic for **MB1136** - From [here](https://www.st.com/en/evaluation-tools/nucleo-f103rb.html#cad-resources)

#### Raspberry Pi 5
* [RP1 Peripherals](https://pip-assets.raspberrypi.com/categories/892-raspberry-pi-5/documents/RP-008370-DS-1-rp1-peripherals.pdf)

#### Other Useful Guides
* [Getting started with UART - Wiki by ST](https://wiki.st.com/stm32mcu/wiki/Getting_started_with_UART)
* [Raspberry Pi Documentation](https://www.raspberrypi.com/documentation/)
* [pySerial's documentation](https://pyserial.readthedocs.io/en/latest/)

## Project Configuration
Here are configurations for setting the FreeRTOS project for NUCLEO-F103RB with STM32CubeMX.

## Board Selector
Open STM32CubeMX, and select [File] → [New Project].

![board_selector](board_selector.png)

Click [Board Selector] and write `NUCLEO-F103RB` on `Commercial Part Number`.

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

### Project Manager
Select [Project Manager] tab. On [Project], change `Toolchain / IDE` to `STM32CubeIDE`.

![mx_conf_7](mx_conf_7.png)

On [Code Generator], choose `Copy only the necessary library files`, and check `Generate peripheral initialization as a pair of '.c/.h' files per peripheral`.

After finishing the configurations, generate code and open the project with STM32CubeIDE!

### C++ Project Conversion
Right-click the project and select "Convert to C++".

![cpp_conversion](cpp_conversion.png)

Click the "Continue" button.

## Raspberry Pi Software Configuration Tool
Open the terminal in Pi.

![pi_pin_before](pi_pin_before.png)

The command `pinctrl -p` display the state of the 40-way header pins. (`pinctrl` displays the state of ALL recognized GPIOs. You can find the usage with `pinctrl help`.)

```bash
sudo raspi-config
```

From `raspi-config`, choose [Interface Options] → [Serial Port].

> Would you like a login shell to be accessible over serial?
> `<No>`

> Would you like the serial port hardware to be enabled?
> `<Yes>`

After `<Ok>`, push the right arrow key on your keyboard twice, select `<Finish>`, and reboot.

![pi_pin_after](pi_pin_after.png)

Now you can see with `pinctrl -p`, `Pin 8` is changed to `TXD0` and `Pin 10` is changed to `RXD0`! We will use this information for hardware connection soon.

* `a4` means "alternate function 4". The functions available on each IO are show in Table 4 in 3.1.1. Function select, RP1 Peripherals document.
* `pn` means "pull none", no internal pull-up or pull-down registor is active. `pu` is "pull up", and `pd` is "pull down".

Additionally, install `pyserial` if you don't have. Since Raspberry Pi OS Bookworm, it is recommended to use the official Debian package to install the package system-wide. (We used to do `pip install pyserial` in normal Python package installation.)

```bash
sudo apt update
sudo apt install python3-pyserial
```

## Hardware Connection
### NUCLEO-F103RB
As you can see from STM32CubeMX, the signal `USART1_TX` is on `PA9`, and `USART1_RX` is on `PA10`. You can also check this from the Pinout view, or many documents.

![signal_pin](signal_pin.png)

![pinout_pa910](pinout_pa910.png)

![ds_pa910](ds_pa910.png)

Looking at UM1724, we can check on CN10, `Pin 21` is `PA9`, and `Pin 33` is `PA10`.

![morpho_pa910](morpho_pa910.png)

### Raspberry Pi 5
We already confirmed above that `Pin 8` is `UART0_TX (GPIO14 = TXD0)`, and `Pin 10` is `UART0_RX (GPIO15 = RXD0)`. There are some other ways to check this.

![rp1_pin](rp1_pin.png)

The RP1 Peripherals document shows `GPIO14` is `UART0_TX`, and `GPIO15` is `UART0_RX`, which we are going to use for our USART connection.

![pinout_pi](pinout_pi.png)

The terminal command `pinout` in Pi or the website [pinout.xyz](https://pinout.xyz/) show the pinout of Pi, so we can the position of the pins very easily. `Pin 8` is `GPIO14`, and `Pin 10` is `GPIO15`.

### Final Connection
We must pair TX of a board with RX of another board. Don't forget that we should also connect one of the Nucleo's GND pins (I chose `Pin 20`) and one of the Pi's GND pins (I chose `Pin 6`). Here's my final connection:

| **Nucleo** | **Pin No.** | **Pi 5** | **Pin No.** |
| - | - | - | - |
| USART1_TX | 21 (PA9) | UART0_RX | 10 (GPIO15) |
| USART1_RX | 33 (PA10) | UART0_TX | 8 (GPIO14) |
| GND | 20 | GND | 6 |

![hw_connection](hw_connection.png)

## Polling Mode Test
### 1. Nucleo → Pi
#### A. Nucleo
In STM32CubeIDE, find `Drivers/STM32F1xx_HAL_Driver/stm32f1xx_hal_uart.c` in the project to get some information on UART functions.

```c
/*
     *** Polling mode IO operation ***
     =================================
     [..]
       (+) Send an amount of data in blocking mode using HAL_UART_Transmit()
       (+) Receive an amount of data in blocking mode using HAL_UART_Receive()
*/
```

In main.c, insert some code inside two tags like these:

```c
/* Private user code ---------------------------------------------------------*/
/* USER CODE BEGIN 0 */
uint8_t tx_buff[]={0,1,2,3,4,5,6,7,8,9};
/* USER CODE END 0 */
```

```c
  /* Infinite loop */
  /* USER CODE BEGIN WHILE */
  while (1)
  {
    /* USER CODE END WHILE */

    /* USER CODE BEGIN 3 */
	HAL_UART_Transmit(&huart1, tx_buff, 10, 1000);
	HAL_Delay(10000);
  }
  /* USER CODE END 3 */
```

Build your project by clicking the hammer icon, connect the Nucleo board to your PC, and run your program by clicking the green play icon.

In the debug configurations window, rename your configuration as what you want.

![debug_uart_tx](debug_uart_tx.png)

(Optional) In the Debugger tab, check "ST-LINK S/N" and click "Scan" button to detect your board. It indicates that this debug configuration is related to this specific board, which would be useful for developers with the same multiple boards.

![debug_uart_tx_debugger](debug_uart_tx_debugger.png)

#### B. Pi
From the official Pi documentation [Configuration](https://www.raspberrypi.com/documentation/computers/configuration.html#uarts), it says on Pi 5, `/dev/ttyAMA0` can be used for use on the GPIO by disabling Bluetooth. Be careful older Pi developers! `/dev/serial0` became the symbolic link of `/dev/ttyAMA10` in Pi 5, which is the debug UART for Raspberry Pi Debug Probe. That is, it is the SWD interface for Pi acting the same as ST-LINK for STM32 boards.

![debug_probe](debug_probe.jpg)

_The left one is Raspberry Pi Debug Probe._

In a nutshell, we should transmit or receive data via `/dev/ttyAMA0` in Pi 5, or the board would try to use a wrong port!

Let's write a simple Python script to receive data from the Nucleo board. Checking some documents from [pySerial's documentation](https://pyserial.readthedocs.io/en/latest/) would be very helpful.



## Interrupt & DMA Echo

## FreeRTOS Task Integration

## C++ Command Parser & GET_STATUS


## Build and Debug
![build_console](build_console.png)

You can also see some kinds of information on the CDT Build Console.

## Study
### HAL
**HAL (Hardware Abstraction Layer)** is an abstraction layer, implemented in software, between the physical hardware of a computer and the software that runs on that computer. In ST's HAL library, almost every function provided by ST starts with `HAL_`. The naming convention look like this:

> HAL_ + [PERIPHERAL] + _ + [ACTION]

### STM32CubeIDE Tips
* To see the full function documentation pop-up, hover your cursor over the function name and press `F2`.
* To find the definition of a function, hover your cursor over the function name and press `F3`.
* To see the parameter hint pop-up while typing inside the parentheses `(...)`, place your cursor inside the function's parentheses and press `Ctrl + Shift + Space`. (Windows/Linux)
* Auto-complete feature gives some default proposals to easily find a function or an argument which are defined somewhere. For example, to auto-complete `HAL_UART_Transmit(...)`, type `HAL_UART_` and press `Ctrl + Space`. And to find any candidates for the first argument, `Ctrl + Space` on the `huart`. It'll show something like `huart1` and `huart2`. Don't forget to add `&` if you are going to refer some address!

### JTAG vs SWD
Both are industry standard for verifying designs of and testing printed circuit boards after manufacture. That is, both are interface for debugging and programming MCUs or embedded systems.

For example, interfaces such as ST-LINK or Raspberry Pi Debug Probe have either JTAG or SWD (or both) for debugger or programmer. Some devices such as ARTIK 053 can even provide such interfaces by default.

#### JTAG
**Joint Test Action Group (JTAG)** is a serial protocol using at least 4~5 pins, `TCK`, `TMS`, `TDI`, `TDO`, and optionally `TRST`.

##### Pros
* **Universal Compatibility**: Can be supported by almost all major microprocessors, microcontrollers, FPGAs, and DSPs.
* **Boundary Scan Testing**: Can test the physical connections on a PCB without using physical probes.
* **Daisy-Chaining**: Can connect multiple ICs in a single serial chain, which allows a single JTAG debugger header to program and debug multiple chips on the same board.

##### Cons
* **High Pin Count**: It requires at least 4 pins, and often up to 20 pins for standard debugging headers. On small microcontrollers with limited GPIOs, dedicating 4 or 5 pins just for debugging is a significant drawback.
* **Complex Routing**: Routing 4 to 5 high-speed signals across a crowded PCB increases layout complexity and requires more physical board space for the connector.

#### SWD
**Serial Wire Debug (SWD)** is an alternative 2-pin electrical interface that uses the same protocol. It uses an ARM CPU standard bi-directional wire protocol. It uses just two signal pins, `SWCLK` and `SWDIO`.

##### Pros
* **Ultra-Low Pin Count**: It uses only 2 pins, which frees up extra microcontroller pins for actual application use (like SPI, I2C, or GPIOs).
* **Space Saving**: It only requires 2 lines, drastically simplifies PCB routing and allows the use of microscopic (very small) headers. Therefore it can become the absolute standard for compact devices like wearables and IoT gadgets.
* **Optimized for ARM Cortex**: 

---

| | **JTAG** | **SWD** |
| - | - | - |
| **Minimum Pins Needed** | 4~5 | 2 |
| **Target Architecture** | Universal | ARM Cortex series only |
| **Hardware Testing** | Boundary Scan supported | - |
| **Multi-Device Support** | Daisy-chaining allowed | Point-to-point (1:1 only) |
| **PCB Space Impact** | Requires larger connectors and more routing | Highly efficient for tight spaces |

### FLASH vs SRAM
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

### Troubleshooting
#### Failed to start GDB server
There are several reasons to get this error while debugging/running in STM32CubeIDE. I got "Failed to bind to port 61234".

![stm_port_error](stm_port_error.png)

![stm_port_error2](stm_port_error2.png)

We should check (1) if the port is busy and (2) if it is in one of the reserved port ranges by the system. In Windows 11, open CMD and type these:

```console
netstat -ano
```

If there's your port number exactly, OR

```console
netsh int ipv4 show excludedportrange protocol=tcp
```

If there's a range that contains your port number, changing your port number would be the easiest solution. Follow these steps to change it. I changed it something like "29876" to avoid the reserved port ranges.

![stm_port_error3.png](stm_port_error3.png)

![stm_port_error4.png](stm_port_error4.png)

#### "Whose Fault?" Dilemma
While writing code by myself and testing the serial bridge between two boards, I got a problem that I could not check which one failed to transmit or receive data.

The solution is simple: Make a TX/RX loopback on a board you want to test - Disconnect GND, and connect TX and RX together with a single jumper wire.

First here's my test script for Pi 5, `self_uart_test.py`.

```python
import serial
import time

SERIAL_PORT = '/dev/ttyAMA0'
BAUD_RATE = 115200

try:
    ser = serial.Serial(SERIAL_PORT, BAUD_RATE, timeout=1)
    print(f"Opening port {SERIAL_PORT} at {BAUD_RATE} baud: Successful!")
except Exception as e:
    print(f"Error... Cannot open port: {e}")
    exit(1)

try:
    ser.reset_input_buffer()
    while True:
        ser.write(b"hello")
        time.sleep(0.1)
        if ser.in_waiting > 0:
            s = ser.read(ser.in_waiting)
            print(f"I said: \"{s}\"\n")
        else:
            print("Timeout... No echo from me\n")
except KeyboardInterrupt:
    print("\nStopping UART test. Bye!")
    ser.close()
finally:
    if 'ser' in locals() and ser.is_open:
        ser.close()
        print("\nSerial port is closed well. Bye!")
```

![self_pi](self_pi.png)

It properly works!

