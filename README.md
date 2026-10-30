# Non-malleable Codes (NMC) Implementation in Different FPGAs

This repository presents an FPGA implementation of a **Non-Malleable Code (NMC)** that employs the **Cipher Feedback (CFB) mode** of encryption, along with a **leakage-resilient CBC-MAC** instantiated using the **AES-128** block cipher. The project showcases a hardware architecture for secure encoding and decoding, providing robustness against tampering and enhancing resilience to information leakage. 

## Repository Structure. 

**In the NMC-FPGA-Code/Encode/ and NMC-FPGA-Code/Decode/ Folder, we have the following files:**

- **`NMC_Encode.v`/ `NMC_Decode.v`** – Top-level Verilog module implementing the complete Non-Malleable Code (NMC) architecture for encoding and decoding.
- **`AES_Enc.v` / `AES_Dec.v`** – Verilog implementation of the AES-128 encryption and decryption module.
- **`Test_NMC_Input.v`** – It is a crucial component in the FPGA implementation of the NMC design. It contains the input vectors required to simulate and verify the NMC design. This file is essential for testing the design's functionality and ensuring that it meets the required specifications and standards. By using the Test_NMC_Input.v file, developers can effectively benchmark and verify the NMC design for encoding / decoding, which is vital for the security and integrity of the system. Both the encode/decode folder contains the test vector.
- **`NMC_Output_FPGA_encryption` / `NMC_Output_FPGA_decryption`** - Xilinx  ISE waveform output.
## Requirements

- **Hardware requirements:** All experiments are conducted on a computer equipped with an Intel Core i5-8265U processor (x86_64   architecture) operating at 1.60 @GHz, 8 GB of RAM, and the Xilinx ISE Design Suite FPGA development environment.
- **Software requirements:** Xilinx ISE Design Suite 14.7, Windows 11, C++17, Ubuntu 22.04 LTS.
- **Data:** Synthetically generated cryptographic test vectors.
- 
##  NMC Encoder Profile File (NMC_Encode_Project_File) / NMC Decoder Profile File (NMC_Decode_Project_File) Run Steps

 **1. Open the Project**
     - Launch Xilinx ISE 14.7.
     - Go to File > Open Project (or browse to your project directory).
     - Select the .xise project file and click Open.
**2. Run Post-Translate Simulation**
     - Navigate to the Simulation view.
     - Select Post-Translate Simulation mode.
     - Run the simulation process.
  **3. Evaluate Across Multiple Devices**
     - Open the Design Properties dialog.
     - Select your target devices one by one.
     - Apply each device change and re-run the process/simulation for each configuration.
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
