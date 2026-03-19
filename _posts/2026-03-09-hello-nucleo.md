---
title: Hello, Nucleo!
description: Let's be familiar with STM32 Nucleo-64 board.
layout: post
date: 2026-03-09
media_subpath: /pics/2026-03-09-hello-nucleo/
image:
    path: nucleo.webp
categories: firmware
tags: [firmware, STM32, Nucleo, NUCLEO-F103RB]
---

## Introduction
Today I'll show some easy firmware experiments with the STM32 Nucleo-64 board (NUCLEO-F103RB). STMicroelectronics is one of the biggest semiconductor contract manufacturing and design company, so anyone who wants to be an embedded (firmware) programmer would be good to try their products.

## Documantation
### Data brief
**Data brief** literally briefs the data on the board. You can click "Download databrief" button on the website to get it.

* [STM32 NUCLEO-F103RB Databrief](https://www.st.com/en/evaluation-tools/nucleo-f103rb.html)

From here you can easily find out the manuals for the board. MB1136 for the board, UM1724 for the user manual. You can also see it uses the MCU STM32F103RBT6, featuring Arm® 32-bit Cortex®-M3 CPU core and LQFP-64 (64-pin low-profile quad flat package).

### Schematic
**Schematic** is a circuit diagram to notify how the board works. You can find one of it from the official schematic pack.

* [STM32 NUCLEO-F103RB CAD Resources](https://www.st.com/en/evaluation-tools/nucleo-f103rb.html#cad-resources)

For example, you can see PA5 is connected to LD2 from the schematic. However, above PB13 says "SB20, SB24, SB29 Close only for F302R8". On the back of the board, you'll see SB29 is really disconnected while SB42 is connected well.

![schematic](schematic.png)

### User Manual
You can also see **user manual** from the website.

* [STM32 NUCLEO-F103RB Documantation](https://www.st.com/en/evaluation-tools/nucleo-f103rb.html#documentation)

For example, we saw the term "SB" above. It means **solder bridge**, which is either closed by solder or 0-ohm resistor (ON), or left open (OFF).

## Project Creation
Especially in STM32CubeIDE 2.X the workflow has been changed, so I wrote the previous post on it.

* [Workflow Tutorial](/posts/stm32-cubeide-version2-new-workflow/)

Each peripheral creates its own .c source files and header files. I checked "Generate peripheral initialization as a pair of '.c/.h' files per peripheral" option because it makes easier to distiguish between main.c and peripheral source.

## Pinout View
You can see pinout view in STM32CubeMX. You can check or change the colors by clicking [v Pinout] → [Pinout View Colors].

![pinout](pinout.png)

Default pinout with default view colors would like this:

![pinout_color](pinout_color.png)

* **Pin In Use**: We are using it.
* **Pin Not In Use**: We are not using it.
* **Pin Single Mapped**: The pin is single mapped for a special purpose. STM32CubeMX will prevent you to accidentally assign it to other things. However, it might be enabled to use in any way like other normal pins, when it is safe to do so. For example, when you hover over PB3, it shows it is a "Pin Single Mapped" which reserved to SYS_JTDO-TRACESWO (or simply SWO). It is the abbreviation of Trace Serial Wire Output, which is a one-way output pin from MCU to debugger. In a nutshell, it is a special pin used for debug tracing, so any assignment to other purposes must be strict.
* 

## Hello, Nucleo! - LED Blink
After you created a new project, let's find `main.c` from the Project Explorer: [your-project] → [Core] → [Src] → [main.c]. Type this code on it between `/* USER CODE BEGIN 3 */` and `/* USER CODE END 3 */`. You should write your most code in a user block between a `BEGIN` comment line and a `END` comment line, or any code generation will clear your code outside user blocks!

```c
    HAL_GPIO_WritePin(LD2_GPIO_Port, LD2_Pin, 1);
    HAL_Delay(500);
    HAL_GPIO_WritePin(LD2_GPIO_Port, LD2_Pin, 0);
    HAL_Delay(500);
```
Connect the Nucleo board to your PC if you haven't done yet, and click the Run button.

![first_run](first_run.png)

![hello_nucleo](hello_nucleo.webp)

