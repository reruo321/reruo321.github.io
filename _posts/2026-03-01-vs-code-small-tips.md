---
title: Visual Studio Code Small Tips
description: Let's customize some simple things in Visual Studio Code
layout: post
date: 2026-03-01
media_subpath: /pics/2026-03-01-vs-code-small-tips/
image:
    path: vs-code.png
categories: programming
tags: [Visual Studio Code, programming]
---

## Disable Auto-closing Brackets in Markdown
Since VS Code treats `<` as an HTML-like tag opener in Markdown, it automatically inserts `>`. I felt it's very annoying to explain some C syntax using just `<`, such as `<<` (left shift). So I have disabled it.

1. Open settings.json. You can access it by typing **Preferences: Open User Settings (JSON)** in the Command Palette (`Ctrl+Shift+P`).

2. Copy-and-paste the code. Don't forget to add `,` to the code for its following settings!
```json
    "[markdown]": {
        "editor.autoClosingBrackets": "never",
        "editor.autoClosingQuotes": "never",
        "editor.autoClosingOvertype": "never"
    }
```

3. Check if your VS Code is not inserting `>` after your `<` in a Markdown document. Done!