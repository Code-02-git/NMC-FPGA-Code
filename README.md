# Non-malleable Codes (NMC) Implementation in Different FPGAs

This repository presents an FPGA implementation of a **Non-Malleable Code (NMC)** that employs the **Cipher Feedback (CFB) mode** of encryption, along with a **leakage-resilient CBC-MAC** instantiated using the **AES-128** block cipher. The project showcases a hardware architecture for secure encoding and decoding, providing robustness against tampering and enhancing resilience to information leakage. 

## Repository Structure

- **`NMC.v`** – Top-level Verilog module implementing the complete Non-Malleable Code (NMC) architecture.
- **`AES_Enc.v`** – Verilog implementation of the AES-128 encryption and decryption module.
- **`Test_NMC_Input.v`** – It contains the input vectors required to simulate and verify the NMC design.

## Requirements

- FPGA development environment (e.g., Xilinx )

## Usage

1. Clone this repository.
2. Open the project in your preferred FPGA development tool.
3. Compile the Verilog source files.
4. Run the simulation using `Test_NMC_Input.v` to verify the implementation.
5. Synthesize and program the design onto a supported FPGA device.

## Applications

- Hardware security modules
- Tamper-proof tokens
- Hardware wallets
- Tamper-resistant systems
  

## License

Specify the appropriate license for this repository (e.g., MIT, BSD, GPL, or Apache 2.0).
