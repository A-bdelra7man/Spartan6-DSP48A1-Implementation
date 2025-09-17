📌 Project Overview

The DSP48A1 slice is a high-performance arithmetic unit found in Spartan-6 FPGAs, supporting pre-addition/subtraction, multiplication, and post-addition/subtraction operations.

This project implements the DSP48A1 architecture in Verilog, verifies it using a self-checking testbench, and completes the Vivado FPGA flow including elaboration, synthesis, implementation, and linting.

🛠 Features

Configurable Pipeline Registers: Implemented A0/A1, B0/B1, CREG, DREG, MREG, PREG, CARRYINREG, CARRYOUTREG, and OPMODEREG.

Arithmetic Operations: Supports pre-add/subtract, multiplication, and post-add/subtract as per OPMODE.

Cascade Connections: Full support for BCIN/BCOUT and PCIN/PCOUT for chaining multiple DSP blocks.

Comprehensive Testbench: Covers reset operation and DSP Paths 1–4 with expected outputs.

🔍 Verification Process

Simulation: Verified functionality in QuestaSim using .do files for automated waveform analysis.

Linting: Performed code linting to ensure zero coding errors.

Synthesis & Implementation: Used Vivado for elaboration, synthesis, and implementation at 100 MHz, achieving zero timing violations and optimal FPGA resource usage.

📊 Results

All test cases produced correct outputs.

Clean reports for synthesis, implementation, and linting.

Efficient FPGA resource utilization on Xilinx xc7a200tffg1156-3 device.

🗂 Repository Structure
├── RTL/                   # Verilog RTL source files
├── Testbench/             # Self-checking testbench files
├── DoFiles/               # .do files for QuestaSim automation
├── Constraints/           # Constraint file (timing @100MHz)
├── Reports/               # Synthesis, Implementation, Timing, Linting reports
└── README.md              # Project description

🛠 Tools & Technologies

->HDL: Verilog

->Simulation: QuestaSim

->FPGA Design Flow: Vivado

->Device: Xilinx Spartan-6 (xc7a200tffg1156-3)
