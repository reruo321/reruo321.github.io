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

On [System Core] → [SYS] → [Mode] → [Timebase Source], change `SysTick` to `TIM1` (or `TIM2`). This prevents the collision between the default SysTick timer and FreeRTOS.

![mx_conf_1](mx_conf_1.png)

Click [Connectivity] → [USART1] on the left sidebar. On [Mode] → [Mode], select `Asynchronous`.

Look at the configurations below. On [DMA Settings], add `USART1_RX` and `USART1_TX`.

A **USART(Universal Synchronous/Asynchronous Receiver/Transmitter)** is a piece of hardware that lets devices send and receive serial data. It operates full-duplex operation, which means it can send and receive data at the same time using separate internal registers.

It can work in both asynchronous mode and synchronous mode.

* **Asynchronous Mode**: The device uses a single data line to send data. Both devices must agree beforehand on the speed (baud rate) to interpret the bits correctly.
* **Synchronous Mode**: 

![mx_conf_2](mx_conf_2.png)

Additionally, set the mode of `USART1_RX`'s DMA Request Settings to `Circular`. It helps USART1_RX to continuously receive the message.

* **Normal**: After transferring a fixed number of bytes/items once, halts.
* **Circular**: Reaches the end of the destination/source buffer, automatically resets the address/counter pointers, and wraps back to index 0 without stopping.

![mx_conf_3](mx_conf_3.png)

On [NVIC Settings], enable `USART1 global interrupt`. It enables to capture the IDLE line event (`UART_IT_IDLE`) so that the CPU can know when a full message finished arriving from the Pi.

![mx_conf_4](mx_conf_4.png)

On [Parameter Settings], ensure `Baud Rate` is 115200 Bits/s, and `Word Length` is 8 Bits (including Parity).

![mx_conf_5](mx_conf_5.png)

On [Middleware and Software Packs] → 

![mx_conf_6](mx_conf_6.png)

![mx_conf_7](mx_conf_7.png)

![build_console](build_console.png)

![memory_detail](memory_detail.png)


## Study
An embedded 
### Flash vs SRAM
Flash (ROM) and SRAM in STM32F103RB are separate, physical silicon memory blocks inside the board. Flash is 128 KB, Meanwhile, SRAM is 20 KB.

SRAM looks like this, which seems similar to the RAM in a normal computer.

```
[ SRAM 끝: 0x2000 5000 (20KB) ]
┌──────────────────────────┐
│ Stack                    │ <- 지역 변수, 함수 호출 정보 (하향 성장)
│      ↓                   │
│      ↑                   │
│ Heap                     │ -> malloc() 등 동적 할당 (상향 성장)
├──────────────────────────┤
│ .bss                     │ Scan 용량이 클수록 0 초기화 루프가 길어짐
├──────────────────────────┤
│ .data                    │ <- 초기화 값이 있는 전역 변수
└──────────────────────────┘
[ SRAM 시작: 0x2000 0000 ]
```