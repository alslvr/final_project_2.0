# x86 Assembly Interactive Typing Tutor

A lightweight, real-time typing evaluation and speed test application written in 32-bit x86 Assembly using the Flat Memory Model.

---

## Overview

This project implements an interactive terminal-based typing tutor directly at the hardware-software interface. It features dynamic procedural text generation, low-level keyboard polling, real-time byte-level character validation, and visual feedback rendered through terminal control routines.

---

## Features

- **Procedural Paragraph Generation:** Generates pseudo-random word strings and dynamically formats text paragraphs while respecting maximum line length constraints and inserting carriage return/line feed pairs (`CR/LF`).
- **Real-Time Input Validation:** Intercepts individual keystrokes via direct console polling and validates characters against source memory buffers.
- **Color-Coded Feedback:** Visually differentiates correct and incorrect inputs by adjusting console text color attributes in real time (e.g., green for matches, red for mismatches).
- **Low-Level Buffer Management:** Organizes static buffers within the `.data` segment to separate and track raw inputs, correct entries, and error states.
- **Interactive Menu Interface:** Modular execution paths for launching the typing test, running games, reviewing metrics, or terminating the program via `ExitProcess`.

---

## Technical Highlights

- **Architecture:** 32-bit x86 Assembly (`.386`, `flat`, `stdcall`).
- **Pointer Arithmetic & Addressing:** Utilizes indexed addressing modes and pointer registers (`ESI`, `EDI`, `ECX`) for manual string traversal, string length calculations, and bounded memory copying.
- **Stack & Register Allocation:** Implements calling conventions using `push`/`pop` sequences to preserve general-purpose registers (`EAX`, `EBX`, `ECX`, `EDX`) across subroutines.
- **Memory Safety:** Direct null-termination handling across 1,024-byte allocated buffers to prevent out-of-bounds reads and runtime overflow vulnerabilities.

---

## File Structure

```text
├── main.asm              # Primary source file containing assembly procedures and data buffers[cite: 5]
└── README.md             # Project documentation
