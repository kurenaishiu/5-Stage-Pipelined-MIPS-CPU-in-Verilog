# 5-Stage Pipelined MIPS CPU in Verilog

This project is a comprehensive implementation of a 5-stage pipelined CPU based on the **MIPS** instruction set architecture (ISA), developed entirely in Verilog HDL. The design focuses on correctly handling data and control hazards to ensure proper program execution while maximizing instruction throughput.

---

## Architectural Highlights

* **Classic 5-Stage Pipeline:** The CPU implements the five classic pipeline stages: Instruction Fetch (IF), Instruction Decode (ID), Execute (EX), Memory Access (MEM), and Write Back (WB).
* **Data Hazard Resolution via Forwarding:** A dedicated **Forwarding Unit** is implemented to resolve most data hazards without stalling the pipeline. It forwards results from the EX/MEM and MEM/WB stages directly back to the inputs of the ALU in the EX stage.
* **Stalling for Load-Use Hazards:** A **Hazard Detection Unit** is implemented to handle the specific case of a load-use data hazard (`lw` followed immediately by an instruction that uses the loaded value). It stalls the pipeline for one clock cycle to ensure data correctness.

---

## Module Descriptions

The project is organized into the following modular Verilog files:

| File | Description |
| :--- | :--- |
| `Pipe_CPU_PRO.v` | The top-level module that connects all components of the pipelined CPU. |
| **Pipeline Core** | |
| `ProgramCounter.v` | The Program Counter (PC) responsible for fetching the next instruction. |
| `Instruction_Memory.v` | The instruction memory module. |
| `Decoder.v` | Decodes instructions in the ID stage to generate control signals. |
| `Reg_File.v` | The 32-entry register file, handling register reads and writes. |
| `ALU.v` / `ALU_Ctrl.v` | The Arithmetic Logic Unit and its associated control unit. |
| `Data_Memory.v` | The data memory module for load and store operations. |
| **Pipelining & Hazard Units** | |
| `Pipe_Reg.v` | The pipeline registers (IF/ID, ID/EX, EX/MEM, MEM/WB) that hold state between stages. |
| `Hazard_Detection.v` | Detects load-use hazards and signals the pipeline to stall. |
| `Forwarding_Unit.v` | Determines when to forward data from later stages to prevent stalls from data hazards. |
| **Utility Modules** | |
| `MUX_2to1.v` / `MUX_3to1.v`| 2-to-1 and 3-to-1 multiplexers used throughout the design. |
| `Adder.v` | A simple adder, primarily for PC incrementing and branch target calculation. |
| `Shift_Left_Two_32.v` | A shifter used for branch address calculation. |
| `Sign_Extend.v` | Extends immediate values to 32 bits for the ALU. |

---

## Tech Stack
* **Language:** Verilog HDL
* **Concepts:** Computer Architecture, RTL Design, Pipelining, Data Hazards, Control Hazards, Forwarding, Stalling, **MIPS ISA**