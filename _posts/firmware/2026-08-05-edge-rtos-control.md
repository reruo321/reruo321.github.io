---
title: Edge RTOS Control
description: My first edge RTOS control project.
layout: post
date: 2026-08-05
media_subpath: /pics/firmware/2026-08-05-edge-rtos-control/
categories: firmware
tags: [firmware, STM32, Nucleo, NUCLEO-F103RB, STM32F103RBT6]
math: true
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
* [STM32F103RB](https://www.st.com/en/microcontrollers-microprocessors/stm32f103rb.html)
    * Datasheet for STM32F103RB (**DS5319**) (Documentation)
    * Reference Manual for STM32F103xx (**RM0008**) (Documentation)
* [NUCLEO-F103RB](https://www.st.com/en/evaluation-tools/nucleo-f103rb.html)
    * User Manual for NUCLEO-F103RB (**UM1724**) (Documentation)
    * Board Schematic for **MB1136** (CAD Resources)

#### Raspberry Pi 5
* [RP1 Peripherals](https://pip-assets.raspberrypi.com/categories/892-raspberry-pi-5/documents/RP-008370-DS-1-rp1-peripherals.pdf)

#### Other Useful Guides
* [Getting started with UART - Wiki by ST](https://wiki.st.com/stm32mcu/wiki/Getting_started_with_UART)
* [FreeRTOS on STM32 v2 - Youtube Playlist](https://www.youtube.com/watch?v=5rWyAlrkQec&list=PLnMKNibPkDnExrAsDpjjF1PsvtoAIBquX)
* [Raspberry Pi Documentation](https://www.raspberrypi.com/documentation/)
* [pySerial's documentation](https://pyserial.readthedocs.io/en/latest/)

## Project Configuration
Here are configurations for setting the FreeRTOS project for NUCLEO-F103RB with STM32CubeMX. Instead of using the easy-going Board Selector, I tried to use MCU/MPU Selector for studying peripherals manually.

We are going to configure these:

* System Core
    * **DMA**:
    * **GPIO**:
    * **IWDG**: Independant WatchDoG 
    * **NVIC**:
    * **SYS**: ST-LINK flashing and debugging
        * Timebase Source: TIM1, because FreeRTOS uses SysTick as core resource to generate system time.

* Timers
    * **TIM1**: HAL Timebase Source
    * **TIM2**: Front servo PWM

* Connectivity
    * **I2C1**:
    * **USART1**:
    * **USART2**:

* Middleware and Software Packs
    * **FreeRTOS**: CMSIS_V2

<!--
## Configuration Method A. Board Selector
This is easier way to configure the project than Method B. Open STM32CubeMX, and select [File] → [New Project].

![board_selector](board_selector.png)

Click [Board Selector] and write `NUCLEO-F103RB` on `Commercial Part Number`.
-->
### MCU/MPU Selector
![mcu_selector](mcu_selector.png)

### Pinout & Configuration
Note that we'll add FreeRTOS later.

#### IWDG
Click [System Core] → [IWDG] on the left sidebar.

![iwdg_enable](iwdg_enable.png)

On `Mode`, check "Activated".

On `Configuration` → `Parameter Settings`, choose "32" on `IWDG counter clock prescaler`, and type "624" on `IWDG down-counter reload value`. This sets total timeout of the watchdog to 500 ms.

![iwdg_calculate](iwdg_calculate.png)

If the $Prescaler$ is $32$ and the $RL$ is $624$, the worst case of the IWDG timeout period is derived when $f_{LSI}$ is $60 kHz$, which has the maximum speed. In this case, the watchdog can underflow after $333 ms$ has passed, and reset the MCU prematurely. Therefore, feeding the IWDG at $167 ms$ is safe.

#### RCC
Click [System Core] → [RCC] on the left sidebar.

![rcc_hse](rcc_hse.png)

On `Mode` → `High Speed Clock (HSE)`, choose "Crystal/Ceramic Resonator".

#### SYS
Click [System Core] → [SYS] on the left sidebar.

![sys_debug](sys_debug.png)

On `Mode` → `Debug`, select "Trace Asynchronous Sw" (or "Serial Wire" if you do not need SWO). First it opens PA13 and PA14 to enable SWD (Serial Wire Debug) protocol by the ST-LINK, so that we can plug in a serial wire to flash and debug. Moreover, it also opens PB3 for SWO (Serial Wire Output), which is very useful to check `printf` debug logs via SWV (Serial Wire Viewer).

![tim1](tim1.png)

On `Mode` → `Timebase Source`, change `SysTick` to `TIM1`.

The change is recommended when we use HAL library, because allowing both FreeRTOS and HAL library to use SysTick can lead to improper timing management within the system. FreeRTOS assigns SysTick and PendSV the lowest hardware interrupt priority, so that application hardware interrupts (such as UART DMA or EXTI) are never blocked by kernel task scheduling. If HAL library share SysTick at priority 15, calling `HAL_Delay()` inside an interrupt handler or critical section disables or delays SysTick updates. This halts `uwTick`, leading to infinite `while` loops and deadlock.

#### TIM2
Click [Timers] → [TIM2] on the left sidebar.

![tim2_config](tim2_config.png)

On `Mode` → `Channel1`, choose `PWM Generation CH1`.

On `Configuration` → `Parameter Settings`, type a number $A$ on `Prescaler (PSC - 16 bits value)` and another number $B$ on `Counter Period (AutoReload Register - 16 bits value)`, where $(A + 1) × (B + 1)$ becomes $1,440,000$. I set $A = 39$, $B = 35999$ for the best resolution. For easier pulse calculation, $A = 71$, $B = 19999$ is good enough.

![tim2_tick](tim2_tick.png)

#### I2C1
Click [Connectivity] → [I2C1] on the left sidebar.

![i2c_config](i2c_config.png)

On `Mode` → `I2C`, choose `I2C`.

On `Configuration` → `Parameter Settings`, choose "Fast Mode" or leave "Standard Mode" on `I2C Speed Mode`.

#### USART1
Click [Connectivity] → [USART1] on the left sidebar.

![usart1_config](usart1_config.png)

On `Mode`, choose "Asynchronous".

![usart1_dma](usart1_dma.png)

On `Configuration` → `DMA Settings`. Add `USART1_RX`, and from `DMA Request Settings` → `Mode`, choose "Circular". And add `USART1_TX`, and from `DMA Request Settings` → `Mode`, choose "Normal".

#### USART2
Click [Connectivity] → [USART2] on the left sidebar.

![usart2_config](usart2_config.png)

On `Mode`, choose "Asynchronous".

#### PA5
Let's enable the green on-board LED, PA5. On Pinout view, click [PA5], and select `GPIO_Output`.

![pa5_config](pa5_config.png)

#### PC13
Let's configure the blue button interrupt, PC13. On Pinout view, click [PC13], and select `GPIO_EXTI13`. Since the circuit holds it at HIGH via a pull-up register, pressing the button bridges directly to GND, which drops the voltage from HIGH to LOW.

![pc13](pc13.png)

Click [System Core] → [GPIO] on the left sidebar.

![pc13_gpio](pc13_gpio.png)

On `Configuration` → `GPIO`, choose "External Interrupt Mode with Falling edge trigger detection" on `GPIO mode`.

![pc13_nvic](pc13_nvic.png)

On `Configuration` → `NVIC`, check "Add" on `EXTI line[15:10] interrupts`.

#### NVIC
Click [System Core] → [NVIC] on the left sidebar.

![nvic_config](nvic_config.png)

On `Configuration` → `NVIC`, increase the `Preemption Priority` of `Time base: Tim1 update interrupt`. Smaller number, higher priority. I changed the value "15" to "5".

Also ensure `USART1 global interrupt` and `EXTI line[15:10] interrupts` are added.

#### (Optional) User Labels
You can freely add user labels to pins by right-clicking them in Pinout view.

![pinout_view](pinout_view.png)

#### Clock Configuration

![clock_config](clock_config.png)

##### Configuration
Red marks in the figure are what we should configure.

* `Input frequency`: 8
* `PLL Source Mux`: HSE
* `PLLMUL`: X 9
* `System CLock Mux`: PLLCLK
    * (Optional) Enable CSS
* `AHB Prescaler`: /1
* `APB1 Prescaler`: /2
* `APB2 Prescaler`: /1

##### Verification
Green marks in the figure are what we should verify, whose value would be automatically adjusted by the configuration.

* `HCLK (MHz)` should be 72 MHz.
* `APB1 Timer clocks (MHz)` should be 72 MHz.

<!--
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
-->

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

##### Debug Configuration
In main.c, override `_write` function inside the USER CODE 4 tag like this:

```c
/* USER CODE BEGIN 4 */
int _write(int file, char *ptr, int len){
	int data_idx;

	for(data_idx = 0; data_idx < len; ++data_idx){
		ITM_SendChar(*ptr++);
	}
	return len;
}
/* USER CODE END 4 */
```

Build your project by clicking the hammer icon, connect the Nucleo board to your PC, and debug your program by clicking the green bug icon.

![debug_uart_tx](debug_uart_tx.png)

In the debug configurations window, rename your configuration as what you want.

![debug_uart_tx_debugger](debug_uart_tx_debugger.png)

(Optional) In the Debugger tab, check "ST-LINK S/N" and click "Scan" button to detect your board. It indicates that this debug configuration is related to this specific board, which would be useful for developers with the same multiple boards.

![swv_enable](swv_enable.png)

Scroll down, and enable SWV. Make sure Core Clock is 72.0.

![itm_open](itm_open.png)

While debugging, click [Window] → [Show View] → [SWV] → [SWV ITM Data Console]. Now you can see SWV ITM (Instrumentation Trace Macrocell) Data Console on your screen. (Normally at the bottom of the window.)

![itm_icon](itm_icon.png)

Click the SWV ITM Data Console tab, and click the "Configure trace" button.

![itm_port](itm_port.png)

On "ITM Stimulus Ports", enable port 0 and click OK.

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

### Button Interrupts
Hardware EXTI line interrupts fire on edge transitions. Assume that a button use a pull-up resistor. (Active-LOW circuit) Its default state is HIGH, and when it is pressed, it is connected directly to GND so it drops to LOW.

* **Rising Edge**: Fires the interrupt when you release the button.
* **Falling Edge**: Fires the interrupt the exact instant you press the button down.
* **Both Edges**: Fires twice—once when pressed and once when released. Useful if you want to measure how long a button was held down.

The interrupts do not fire on static signal levels. Therefore, if you need continuous detection while a button is held down, polling a standard GPIO pin or using a timer-based debouncing task in FreeRTOS is the proper approach.

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

Let's try some simple code for self-testing. First here's my test script for Pi 5, `self_uart_test.py`.

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

I found the problem from the STM32 code. I fixed the code, set breakpoints on every `__NOP();` line, and debugged the program. It worked too!

```c
/* USER CODE BEGIN Header */
/**
  ******************************************************************************
  * @file           : main.c
  * @brief          : Main program body
  ******************************************************************************
  * @attention
  *
  * Copyright (c) 2026 STMicroelectronics.
  * All rights reserved.
  *
  * This software is licensed under terms that can be found in the LICENSE file
  * in the root directory of this software component.
  * If no LICENSE file comes with this software, it is provided AS-IS.
  *
  ******************************************************************************
  */
/* USER CODE END Header */
/* Includes ------------------------------------------------------------------*/
#include "main.h"
#include "dma.h"
#include "i2c.h"
#include "iwdg.h"
#include "tim.h"
#include "usart.h"
#include "gpio.h"

/* Private includes ----------------------------------------------------------*/
/* USER CODE BEGIN Includes */

/* USER CODE END Includes */

/* Private typedef -----------------------------------------------------------*/
/* USER CODE BEGIN PTD */

/* USER CODE END PTD */

/* Private define ------------------------------------------------------------*/
/* USER CODE BEGIN PD */

/* USER CODE END PD */

/* Private macro -------------------------------------------------------------*/
/* USER CODE BEGIN PM */

/* USER CODE END PM */

/* Private variables ---------------------------------------------------------*/

/* USER CODE BEGIN PV */

/* USER CODE END PV */

/* Private function prototypes -----------------------------------------------*/
void SystemClock_Config(void);
/* USER CODE BEGIN PFP */

/* USER CODE END PFP */

/* Private user code ---------------------------------------------------------*/
/* USER CODE BEGIN 0 */
uint8_t tx_buff[]={0,1,2,3,4,5,6,7,8,9};
uint8_t rx_buff[10];
/* USER CODE END 0 */

/**
  * @brief  The application entry point.
  * @retval int
  */
int main(void)
{

  /* USER CODE BEGIN 1 */

  /* USER CODE END 1 */

  /* MCU Configuration--------------------------------------------------------*/

  /* Reset of all peripherals, Initializes the Flash interface and the Systick. */
  HAL_Init();

  /* USER CODE BEGIN Init */

  /* USER CODE END Init */

  /* Configure the system clock */
  SystemClock_Config();

  /* USER CODE BEGIN SysInit */

  /* USER CODE END SysInit */

  /* Initialize all configured peripherals */
  MX_GPIO_Init();
  MX_DMA_Init();
  MX_I2C1_Init();
  MX_IWDG_Init();
  MX_TIM2_Init();
  MX_USART1_UART_Init();
  MX_USART2_UART_Init();
  /* USER CODE BEGIN 2 */

  /* USER CODE END 2 */

  /* Infinite loop */
  /* USER CODE BEGIN WHILE */
  while (1)
  {
    /* USER CODE END WHILE */

    /* USER CODE BEGIN 3 */

	  HAL_UART_Transmit_DMA(&huart1, tx_buff, 10);
	  if(HAL_UART_Receive_DMA(&huart1, rx_buff, 10) == HAL_OK){
		  __NOP();
	  }
	  else{
		  __NOP();
	  }
	  HAL_Delay(10000);
  }
  /* USER CODE END 3 */
}

/**
  * @brief System Clock Configuration
  * @retval None
  */
void SystemClock_Config(void)
{
  RCC_OscInitTypeDef RCC_OscInitStruct = {0};
  RCC_ClkInitTypeDef RCC_ClkInitStruct = {0};

  /** Initializes the RCC Oscillators according to the specified parameters
  * in the RCC_OscInitTypeDef structure.
  */
  RCC_OscInitStruct.OscillatorType = RCC_OSCILLATORTYPE_LSI|RCC_OSCILLATORTYPE_HSE;
  RCC_OscInitStruct.HSEState = RCC_HSE_ON;
  RCC_OscInitStruct.HSEPredivValue = RCC_HSE_PREDIV_DIV1;
  RCC_OscInitStruct.HSIState = RCC_HSI_ON;
  RCC_OscInitStruct.LSIState = RCC_LSI_ON;
  RCC_OscInitStruct.PLL.PLLState = RCC_PLL_ON;
  RCC_OscInitStruct.PLL.PLLSource = RCC_PLLSOURCE_HSE;
  RCC_OscInitStruct.PLL.PLLMUL = RCC_PLL_MUL9;
  if (HAL_RCC_OscConfig(&RCC_OscInitStruct) != HAL_OK)
  {
    Error_Handler();
  }

  /** Initializes the CPU, AHB and APB buses clocks
  */
  RCC_ClkInitStruct.ClockType = RCC_CLOCKTYPE_HCLK|RCC_CLOCKTYPE_SYSCLK
                              |RCC_CLOCKTYPE_PCLK1|RCC_CLOCKTYPE_PCLK2;
  RCC_ClkInitStruct.SYSCLKSource = RCC_SYSCLKSOURCE_PLLCLK;
  RCC_ClkInitStruct.AHBCLKDivider = RCC_SYSCLK_DIV1;
  RCC_ClkInitStruct.APB1CLKDivider = RCC_HCLK_DIV2;
  RCC_ClkInitStruct.APB2CLKDivider = RCC_HCLK_DIV1;

  if (HAL_RCC_ClockConfig(&RCC_ClkInitStruct, FLASH_LATENCY_2) != HAL_OK)
  {
    Error_Handler();
  }
}

/* USER CODE BEGIN 4 */

/* USER CODE END 4 */

/**
  * @brief  Period elapsed callback in non blocking mode
  * @note   This function is called  when TIM1 interrupt took place, inside
  * HAL_TIM_IRQHandler(). It makes a direct call to HAL_IncTick() to increment
  * a global variable "uwTick" used as application time base.
  * @param  htim : TIM handle
  * @retval None
  */
void HAL_TIM_PeriodElapsedCallback(TIM_HandleTypeDef *htim)
{
  /* USER CODE BEGIN Callback 0 */

  /* USER CODE END Callback 0 */
  if (htim->Instance == TIM1)
  {
    HAL_IncTick();
  }
  /* USER CODE BEGIN Callback 1 */

  /* USER CODE END Callback 1 */
}

/**
  * @brief  This function is executed in case of error occurrence.
  * @retval None
  */
void Error_Handler(void)
{
  /* USER CODE BEGIN Error_Handler_Debug */
  /* User can add his own implementation to report the HAL error return state */
  __disable_irq();
  while (1)
  {
  }
  /* USER CODE END Error_Handler_Debug */
}
#ifdef USE_FULL_ASSERT
/**
  * @brief  Reports the name of the source file and the source line number
  *         where the assert_param error has occurred.
  * @param  file: pointer to the source file name
  * @param  line: assert_param error line source number
  * @retval None
  */
void assert_failed(uint8_t *file, uint32_t line)
{
  /* USER CODE BEGIN 6 */
  /* User can add his own implementation to report the file name and line number,
     ex: printf("Wrong parameters value: file %s on line %d\r\n", file, line) */
  /* USER CODE END 6 */
}
#endif /* USE_FULL_ASSERT */
```

#### System Reset by IWDG
When I tried the USART connection with Pi 5, I saw wrong `rx_count` values on Pi's terminal. However, I found the SWV ITM Data Console shows like this:

```
...
Hi 0!
Hi 5!
Hi 0!
Hi 5!
Hi 0!
Hi 5!
Hi 0!
Hi 2!
Hi 0!
Hi 0!
Hi 0!
...
```

Therefore, I tried to find the cause from the STM32 code.

```c
/* USER CODE BEGIN Header */
/**
  ******************************************************************************
  * @file           : main.c
  * @brief          : Main program body
  ******************************************************************************
  * @attention
  *
  * Copyright (c) 2026 STMicroelectronics.
  * All rights reserved.
  *
  * This software is licensed under terms that can be found in the LICENSE file
  * in the root directory of this software component.
  * If no LICENSE file comes with this software, it is provided AS-IS.
  *
  ******************************************************************************
  */
/* USER CODE END Header */
/* Includes ------------------------------------------------------------------*/
#include "main.h"
#include "dma.h"
#include "i2c.h"
#include "iwdg.h"
#include "tim.h"
#include "usart.h"
#include "gpio.h"

/* Private includes ----------------------------------------------------------*/
/* USER CODE BEGIN Includes */
#include <stdio.h>
#include <string.h>
/* USER CODE END Includes */

/* Private typedef -----------------------------------------------------------*/
/* USER CODE BEGIN PTD */

/* USER CODE END PTD */

/* Private define ------------------------------------------------------------*/
/* USER CODE BEGIN PD */
#define RX_BUF_SIZE 256
/* USER CODE END PD */

/* Private macro -------------------------------------------------------------*/
/* USER CODE BEGIN PM */

/* USER CODE END PM */

/* Private variables ---------------------------------------------------------*/

/* USER CODE BEGIN PV */

/* USER CODE END PV */

/* Private function prototypes -----------------------------------------------*/
void SystemClock_Config(void);
/* USER CODE BEGIN PFP */

/* USER CODE END PFP */

/* Private user code ---------------------------------------------------------*/
/* USER CODE BEGIN 0 */
uint8_t rx_buff[RX_BUF_SIZE] = {0};
static char ack_msg[50];

uint16_t rx_data_len = 0;
uint16_t rx_count = 0;
/* USER CODE END 0 */

/**
  * @brief  The application entry point.
  * @retval int
  */
int main(void)
{

  /* USER CODE BEGIN 1 */

  /* USER CODE END 1 */

  /* MCU Configuration--------------------------------------------------------*/

  /* Reset of all peripherals, Initializes the Flash interface and the Systick. */
  HAL_Init();

  /* USER CODE BEGIN Init */

  /* USER CODE END Init */

  /* Configure the system clock */
  SystemClock_Config();

  /* USER CODE BEGIN SysInit */

  /* USER CODE END SysInit */

  /* Initialize all configured peripherals */
  MX_GPIO_Init();
  MX_DMA_Init();
  MX_I2C1_Init();
  MX_IWDG_Init();
  MX_TIM2_Init();
  MX_USART1_UART_Init();
  MX_USART2_UART_Init();
  /* USER CODE BEGIN 2 */
  HAL_UARTEx_ReceiveToIdle_DMA(&huart1, rx_buff, RX_BUF_SIZE);
  /* USER CODE END 2 */

  /* Infinite loop */
  /* USER CODE BEGIN WHILE */
  fflush(stdout);
  while (1)
  {
    /* USER CODE END WHILE */

    /* USER CODE BEGIN 3 */
	  printf("Hi %d!\n", rx_count);
	  HAL_Delay(500);
  }
  /* USER CODE END 3 */
}

/**
  * @brief System Clock Configuration
  * @retval None
  */
void SystemClock_Config(void)
{
  RCC_OscInitTypeDef RCC_OscInitStruct = {0};
  RCC_ClkInitTypeDef RCC_ClkInitStruct = {0};

  /** Initializes the RCC Oscillators according to the specified parameters
  * in the RCC_OscInitTypeDef structure.
  */
  RCC_OscInitStruct.OscillatorType = RCC_OSCILLATORTYPE_LSI|RCC_OSCILLATORTYPE_HSE;
  RCC_OscInitStruct.HSEState = RCC_HSE_ON;
  RCC_OscInitStruct.HSEPredivValue = RCC_HSE_PREDIV_DIV1;
  RCC_OscInitStruct.HSIState = RCC_HSI_ON;
  RCC_OscInitStruct.LSIState = RCC_LSI_ON;
  RCC_OscInitStruct.PLL.PLLState = RCC_PLL_ON;
  RCC_OscInitStruct.PLL.PLLSource = RCC_PLLSOURCE_HSE;
  RCC_OscInitStruct.PLL.PLLMUL = RCC_PLL_MUL9;
  if (HAL_RCC_OscConfig(&RCC_OscInitStruct) != HAL_OK)
  {
    Error_Handler();
  }

  /** Initializes the CPU, AHB and APB buses clocks
  */
  RCC_ClkInitStruct.ClockType = RCC_CLOCKTYPE_HCLK|RCC_CLOCKTYPE_SYSCLK
                              |RCC_CLOCKTYPE_PCLK1|RCC_CLOCKTYPE_PCLK2;
  RCC_ClkInitStruct.SYSCLKSource = RCC_SYSCLKSOURCE_PLLCLK;
  RCC_ClkInitStruct.AHBCLKDivider = RCC_SYSCLK_DIV1;
  RCC_ClkInitStruct.APB1CLKDivider = RCC_HCLK_DIV2;
  RCC_ClkInitStruct.APB2CLKDivider = RCC_HCLK_DIV1;

  if (HAL_RCC_ClockConfig(&RCC_ClkInitStruct, FLASH_LATENCY_2) != HAL_OK)
  {
    Error_Handler();
  }
}

/* USER CODE BEGIN 4 */
// Enables to write ITM
int _write(int file, char *ptr, int len){
	int data_idx;
	for(data_idx = 0; data_idx < len; ++data_idx){
		ITM_SendChar(*ptr++);
	}
	return len;
}

void HAL_UARTEx_RxEventCallback(UART_HandleTypeDef *huart, uint16_t Size){
	if(huart->Instance == USART1){
		rx_data_len = Size;
		sprintf(ack_msg, "ACK %d\n", rx_count);
		HAL_UART_Transmit_DMA(&huart1, (uint8_t *)ack_msg, strlen(ack_msg));
		HAL_UARTEx_ReceiveToIdle_DMA(&huart1, rx_buff, RX_BUF_SIZE);
		++rx_count;
	}
}
/* USER CODE END 4 */

/**
  * @brief  Period elapsed callback in non blocking mode
  * @note   This function is called  when TIM1 interrupt took place, inside
  * HAL_TIM_IRQHandler(). It makes a direct call to HAL_IncTick() to increment
  * a global variable "uwTick" used as application time base.
  * @param  htim : TIM handle
  * @retval None
  */
void HAL_TIM_PeriodElapsedCallback(TIM_HandleTypeDef *htim)
{
  /* USER CODE BEGIN Callback 0 */

  /* USER CODE END Callback 0 */
  if (htim->Instance == TIM1)
  {
    HAL_IncTick();
  }
  /* USER CODE BEGIN Callback 1 */

  /* USER CODE END Callback 1 */
}

/**
  * @brief  This function is executed in case of error occurrence.
  * @retval None
  */
void Error_Handler(void)
{
  /* USER CODE BEGIN Error_Handler_Debug */
  /* User can add his own implementation to report the HAL error return state */
  __disable_irq();
  while (1)
  {
  }
  /* USER CODE END Error_Handler_Debug */
}
#ifdef USE_FULL_ASSERT
/**
  * @brief  Reports the name of the source file and the source line number
  *         where the assert_param error has occurred.
  * @param  file: pointer to the source file name
  * @param  line: assert_param error line source number
  * @retval None
  */
void assert_failed(uint8_t *file, uint32_t line)
{
  /* USER CODE BEGIN 6 */
  /* User can add his own implementation to report the file name and line number,
     ex: printf("Wrong parameters value: file %s on line %d\r\n", file, line) */
  /* USER CODE END 6 */
}
#endif /* USE_FULL_ASSERT */
```

Which means STM32