---
title: My STM32F103RBT6 Practice
description: My STM32F103RBT6 Practice.
layout: post
date: 2026-08-04
media_subpath: /pics/firmware/2026-08-04-my-stm32f103rbt6-practice/
categories: firmware
tags: [firmware, STM32, Nucleo, STM32F103RBT6]
math: true
---

## Introduction
I am trying many experiments on STM32F103RBT6 here, which is on a NUCLEO-F103RB board.

## Prerequisite
* STM32F103RBT6, or a board with STM32F103RBT6 (I'll use NUCLEO-F103RB board.)

### Documents
#### NUCLEO-F103RB
* [STM32F103RB](https://www.st.com/en/microcontrollers-microprocessors/stm32f103rb.html)
    * Datasheet for STM32F103RB (**DS5319**) (Documentation)
    * Reference Manual for STM32F103xx (**RM0008**) (Documentation)
* [NUCLEO-F103RB](https://www.st.com/en/evaluation-tools/nucleo-f103rb.html)
    * User Manual for NUCLEO-F103RB (**UM1724**) (Documentation)
    * Board Schematic for **MB1136** (CAD Resources)

## Data Brief
STM32F103RBT6 is a medium-density devices with 128 Kbytes of Flash memory and 20 Kbytes of SRAM. It also has the Arm Cortex-M3 32-bit RISC core and a LQFP64 package.

![stm32f103rbt6](stm32f103rbt6.png)

## Project Configuration
I use MCU/MPU Selector for studying peripherals manually.

### MCU/MPU Selector
![mcu_selector](mcu_selector.png)


## Study
### Grounding
#### Star Grounding
**Star Grounding (Single-Point Grounding)** is a technique used in recording studios is to interconnect all the metal chassis with heavy conductors like copper strips, then connect to the building ground wire system at one point.

![star_ground](star_ground.png)

### Return Path
* $Z$: **Impedance**, the opposition to alternating current presented by the combined effect of resistance ($R$) and reactance ($X$) in a circuit.
* $R$: **Resistance**, a measure of an object's opposition to the flow of electric current.
* $X_L$: **Inductive Reactance**, the opposition of an inductor to an alternating current (AC).
    * How much the actual opposition would be created by a coil against the current change in an AC circuit?
* $f$: **Signal Frequency**
* $L$: **Inductance**, the tendency of an electrical conductor to oppose a change in the electric current flowing through it.
    * How much a coil would resist any change in current?
    * It's a permanent, physical property which is decided by the coil itself.
* $Y$: **Admittance**, a measure of how easily a circuit or device will allow a current to flow.

![](https://www.youtube.com/watch?v=7OoODwOy4Mg)

Note: Originally total impedance is $Z = R + jX$ where $R = R_{forward} + R_{return}$, $X = X_L - X_C = ωL - \frac{1}{ωC}$, and $j = \sqrt{-1}$. However we do not need to think about capacitive reactance ($X_C$) or $j$ here! Capacitance does not block or oppose the current as it travels through the ground plane back to the source. Moreover, since we want to know the real-world physical opposition, we need only the magnitude formula without $j$.
