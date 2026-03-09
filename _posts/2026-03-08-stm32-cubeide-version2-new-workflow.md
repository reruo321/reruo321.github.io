---
title: STM32CubeIDE 2.X New Workflow
description: Let's learn how to create a new project for STM32CubeIDE version 2.X.
layout: post
date: 2026-03-08
media_subpath: /pics/2026-03-08-stm32-cubeide-version2-new-workflow/
image:
    path: stm32cubeide.avif
categories: firmware
tags: [firmware, STM32, CubeIDE, Nucleo 64]
---

Today I'll show you how we can create a fresh new project for STM32CubeIDE version 2.X. I wrote this guide since I have some experience of version 1.X but got annoyed when using the version 2.X for the first time.

![where](where.png)

## Introduction
To sum up first, you need **STM32CubeMX** in addition to STM32CubeIDE to generate a new project. They removed the project configuration tool STM32CubeMX from STM32CubeIDE in version 2.X. If you are a professional developer to use the IDE instead of using the VS Code extension, see this tutorial. I also wrote the post based on it.

* The official workflow tutorial: [https://community.st.com/t5/stm32-mcus/stm32cubeide-2-0-0-workflow-tutorial/ta-p/864831](https://community.st.com/t5/stm32-mcus/stm32cubeide-2-0-0-workflow-tutorial/ta-p/864831)

## Steps
### STM32CubeMX
#### 1) Download and install the latest STM32CubeMX AND STM32CubeIDE.
* STM32CubeMX: [https://www.st.com/en/development-tools/stm32cubemx.html](https://www.st.com/en/development-tools/stm32cubemx.html)
* STM32CubeIDE: [https://www.st.com/en/development-tools/stm32cubemx.html](https://www.st.com/en/development-tools/stm32cubemx.html)

#### 2) Open STM32CubeMX first, and start a new project.
There are three options to start the project:

1. ACCESS TO MCU SELECTOR
1. ACCESS TO BOARD SELECTOR
1. ACCESS TO EXAMPLE SELECTOR

In my case, I picked up "ACCESS TO BOARD SELECTOR" for my Nucleo-F103RB. If a pop-up window says it failed to download something, close the selector and press the button again. I had failed for three times before finally succeeded.

![mx00](mx00.png)

#### 3) Configure your project.
I selected my board, initialized all peripherals with their default Mode, use default configurations. In "Project" in **Project Manager** tab I set my project name and changed "ToolChain / IDE" to "STM32CubeIDE", and in "Code Generator" I checked "Generate peripheral initialization as a pair of '.c/.h' files per peripheral".

![mx01](mx01.png)

![mx02](mx02.png)

![mx03](mx03.png)

![mx04](mx04.png)

![mx05](mx05.png)

#### 4) Click on the right top "GENERATE CODE" button.
You may download something here too.

![mx06](mx06.png)

If you got this pop-up message, congratulations! You successfully created the project.

![mx07](mx07.png)

### STM32CubeIDE
#### 5) Open STM32CubeIDE, and select File → STM32 Project Create/Import.

![ide00](ide00.png)

#### 6) Choose "STM32CubeMX1/STM32CubeIDE Project".

![ide01](ide01.png)

#### 7) Select your project as the import source, and click Finish.

![ide02](ide02.png)

### Result

![ide03](ide03.png)

DONE!

### Project Modification Tips
#### 1) Open the project with STM32CubeMX, and do the modifications you want to do.

![mx03](mx03.png)

#### 2) Click "GENERATE CODE".

![mx06](mx06.png)

#### 3) Go back to STM32CubeIDE and click File → Refresh, or press F5.

![refresh](refresh.png)

Updated!

## Conclusion
The tool split in version 2.X meant to provide more flexibility for developers to update and freeze versions of STM32CubeMX and STM32CubeIDE independently, and avoid conflicts with older STM32CubeIDE versions. However, many users are experiencing the inconvenience by those sudden changes. So relax, you and me are not the only ones that had a hard time with the new workflow!