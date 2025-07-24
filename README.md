# MIPS32 Single-Cycle Processor

## Description

This project implements a **MIPS32 single-cycle processor** in Verilog HDL, supporting a rich subset of **50+ MIPS Instructions**. It is designed for simulation and includes all necessary testbenches, waveform setups, and automation scripts.

## Architecture
![MIPS_Single_Cycle drawio](https://github.com/user-attachments/assets/348bea3a-c9a1-41dc-8622-eca2f728d199)

> For a clearer and scalable view of the architecture, open the `.drawio` block diagram file found in the main directory using [draw.io](https://www.drawio.com/). This allows full zoom and editing capabilities.

## Features

* **Single-Cycle Implementation**: All instructions are executed in a single clock cycle.
* **32-Bit MIPS Architecture**: Based on the MIPS32 instruction set architecture.
* **Simulation Ready**: Includes assembly tests converted to hex files for the testbench to verify the processor's functionality.
* **50+ instructions supported**, including:
  - R-type: `ADD`, `ADDU`, `MULT`, `MULTU`, `AND`, `OR`, `XOR`, `SLT`, `SLL`, `SRAV`, `JR`, `MFHI`, `MTLO`, ...
  - I-type: `LW`, `SW`, `LB`, `LH`, `ADDI`, `ADDIU`, `ANDI`, `ORI`, `BEQ`, `BNE`, `LUI`, `BLTZ/BGEZ`, ...
  - J-type: `J`, `JAL`
 
>  See `MIPS I ISA.xlsx` for a full list of supported instructions.

## Getting Started

To get a local copy up and running, follow these simple steps.

### Prerequisites

You will need a Verilog/VHDL simulator to run and test the processor. Some popular options are:
* **ModelSim**
* **Xilinx Vivado**
* **Icarus Verilog (Open Source)**

### Simulation

1. **Clone the repository:**
    ```sh
    git clone https://github.com/mo2menwael/MIPS32_SingleCycle_Processor.git
    ```
2. **Navigate to the project directory:**
    ```sh
    cd MIPS32_SingleCycle_Processor
    ```
3. **Open your simulator, create a new project, add all the RTL files, and run the provided script.** The `run.do` file contains the necessary commands to compile the source code and run the simulation. You can execute it by typing the following command in your simulator console:
    ```tcl
    do run.do
    ```

## Reference

This project was built with guidance and architecture principles from:

> **David Harris & Sarah Harris** —  
> _Digital Design and Computer Architecture, 2nd Edition_  
> Morgan Kaufmann, ISBN: 978-0123944245
