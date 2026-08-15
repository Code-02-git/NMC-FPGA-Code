`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   06:25:32 15/08/2026
// Design Name:   NMC
// Module Name:   
// Project Name:  AES_encryption
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: NMC
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module test_mnc;

	// Inputs
	reg [0:127] IV;
	reg [0:127] M1;
	reg [0:127] M2;
	reg [0:127] M3;
	reg [0:127] M4;
	reg [0:127] M5;
	reg [0:127] M6;
	reg [0:127] key;
	reg [0:127] MAC_KEY;
	reg clk;
	reg start;
	reg reset;

	// Outputs
	wire [0:127] C1;
	wire [0:127] C2;
	wire [0:127] C3;
	wire [0:127] C4;
	wire [0:127] C5;
	wire [0:127] C6;
	wire [0:127] MAC;
	wire [0:127] t_After_subbyte;
	wire [3:0] get_current_state;
   wire [3:0] nmc_counter;
	wire load1;
	wire load2;
	wire load3;
	wire load4;
	wire load5;
	wire load6;
	//wire load7;
	wire [0:127] pt;
	wire [0:127] ct;
	wire [0:127] temp_key;

	// Instantiate the Unit Under Test (UUT)
	NMC uut (
		.IV(IV), 
		.M1(M1), 
		.M2(M2), 
		.M3(M3), 
		.M4(M4), 
		.M5(M5),
		.M6(M6),
		.key(key),
		.MAC_KEY(MAC_KEY),		
		.clk(clk), 
		.start(start), 
		.reset(reset), 
		.C1(C1), 
		.C2(C2), 
		.C3(C3), 
		.C4(C4), 
		.C5(C5),
		.C6(C6),
		.MAC(MAC),
		.t_After_subbyte(t_After_subbyte),
		.get_current_state(get_current_state),
		.nmc_counter(nmc_counter),
		.load1(load1),
		.load2(load2),
		.load3(load3),
		.load4(load4),
		.load5(load5),
		.load6(load6),
		//.load7(load7),
		.pt(pt),
		.ct(ct),
		.temp_key(temp_key)
	);

	initial begin
		// Initialize Inputs
		//IV = 128'h3243f6a8885a308d313198a2e0370734;
		IV = 128'h3b68b209a0abf1434a01899630d7a8f5;
		M1 = 128'h0123456789abcdeffedcba9876543210;
		M2 = 128'h1123456789abcdeffedcba9876543201;
		M3 = 128'h1143456788abcdefaedcba9876543201;
		M4 = 128'h1143556799abcdefaedcba9876543201;
		M5 = 128'h1143556799abedeffedcfa9876543201;
		M6 = 128'h012345678923cd1ffe5cba9876543278;
		
		
		


		

	   //key     = 128'h2b7e151628aed2a6abf7158809cf4f3c;
		key=      128'h0f1571c947d9e8590cb7add6af7f6798;
	   MAC_KEY = 128'hec54e34036d33ea56f49604a525c7a43;

		#100
		start = 0;
		reset = 1;
      clk=0;
		#7
		reset = 0;

		#2
		start = 1;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here

	end
 always 
    #1 clk = ~clk;       
endmodule

