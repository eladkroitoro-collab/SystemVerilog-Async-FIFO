<img width="2822" height="2286" alt="block_diagram" src="https://github.com/user-attachments/assets/1a280868-31b7-44f4-90cc-069389ffdaad" /># SystemVerilog Asynchronous FIFO

A Asynchronous FIFO implementation designed for safe Clock Domain Crossing (CDC) using Gray Code pointers. 
This project demonstrates multi-bit signal synchronization, dual-port RAM usage, and a SystemVerilog verification environment.
The module bridges two asynchronous clock domains: Write Domain (`w_clk`) and Read Domain (`r_clk`).

![Diagram](docs/block_diagram.png)

## 2. Micro-Architecture
The design of CDC challenges using:
* **Gray Code Counters:** To prevent multi-bit glitches during pointer sampling.
* **2-Stage Synchronizers:** To mitigate metastability.
* **Dual Port RAM:** For simultaneous read/write operations.

![Architecture Diagram](docs/Architecture.png)

## 3. Verification Environment
The design was verified using a layered Testbench approach, including:
* **Stimulus Generator:** Randomizes write transactions.
* **Monitor/Checker:** Validates data integrity and Empty/Full flags.
* **Assertions:** Ensures protocol compliance.

![Testbench Diagram](docs/testbench.sv)

**Author:** Elad Kroitoro  
**University:** The Hebrew University Of Jerusalem - Electrical Engineering and Applied Physics Student (3rd Year)
