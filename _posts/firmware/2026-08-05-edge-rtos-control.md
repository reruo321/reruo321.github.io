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

On [System Core] → [SYS] → (Mode) Timebase Source, change `SysTick` to `TIM1` (or `TIM2`). This prevents the collision between the default SysTick timer and FreeRTOS.

![mx_conf_1](mx_conf_1.png)

On [Connectivity] → [USART1] → (Mode) Mode, select `Asynchronous`.

Look at the configurations below. On [DMA Settings], add `USART1_RX` and `USART1_TX`.

![mx_conf_2](mx_conf_2.png)

Additionally, set the mode of `USART1_RX`'s DMA Request Settings to `Circular`. It helps USART1_RX to continuously receive the message.

* **Normal**: After transferring a fixed number of bytes/items once, halts.
* **Circular**: Reaches the end of the destination/source buffer, automatically resets the address/counter pointers, and wraps back to index 0 without stopping.

![mx_conf_3](mx_conf_3.png)

On [NVIC Settings], enable `USART1 global interrupt`. It enables to capture the IDLE line event (`UART_IT_IDLE`) so that the CPU can know when a full message finished arriving from the Pi.

![mx_conf_4](mx_conf_4.png)

![mx_conf_5](mx_conf_5.png)

![mx_conf_6](mx_conf_6.png)

![mx_conf_7](mx_conf_7.png)


![build_console](build_console.png)

## Study
An embedded 
### Flash vs SRAM
Flash (ROM) and SRAM in STM32F103RB are separate, physical silicon memory blocks inside the board. Flash is 128 KB, Meanwhile, SRAM is 20 KB.