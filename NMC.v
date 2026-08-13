`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    05:38:44 09/22/2023 
// Design Name: 
// Module Name:    NMC 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module NMC(
    input [0:127] IV,
    input [0:127] M1,
    input [0:127] M2,
    input [0:127] M3,
    input [0:127] M4,
	 input [0:127] M5,
	 input [0:127] M6,
	 input [0:127] key,
	 input [0:127] MAC_KEY,
	 
    input clk,
    input start,
    input reset,
    output [0:127] C1,
    output [0:127] C2,
    output [0:127] C3,
    output [0:127] C4,
	 output [0:127] C5,
	 output [0:127] C6,
	 output [0:127] MAC,
	 output [0:127] t_After_subbyte,
	 output [3:0] get_current_state,
	 output [3:0] nmc_counter,
	 
	 output load1,
	 output load2,
	 output load3,
	 output load4,
	 output load5,
	 output load6,
	 
	 //output load7,
	 output [0:127] pt,
	 output [0:127] ct,
	 output [0:127] temp_key
    );
wire [0:127] w_c1,w_c2,w_c3,w_c4,w_c5,w_c6;
//wire [2:0] nmc_state;
//wire [0:127] temp_key;
//wire load1,load2,load3,load4,load5,load6;
assign pt= ((~nmc_counter[3]) &(~nmc_counter[2]) & (~nmc_counter[1]) & (~nmc_counter[0]))? IV:
           ((~nmc_counter[3]) &(~nmc_counter[2]) & (~nmc_counter[1]) & (nmc_counter[0]))? C1:
			  ((~nmc_counter[3]) &(~nmc_counter[2]) & (nmc_counter[1]) & (~nmc_counter[0]))? C2:
			  ((~nmc_counter[3]) &(~nmc_counter[2]) & (nmc_counter[1]) & (nmc_counter[0]))? C3:
			  ((~nmc_counter[3]) &(nmc_counter[2]) & (~nmc_counter[1]) & (~nmc_counter[0]))? C4:
			  ((~nmc_counter[3]) &(nmc_counter[2]) & (~nmc_counter[1]) & (nmc_counter[0]))? C5:
			  ((~nmc_counter[3]) &(nmc_counter[2]) & (nmc_counter[1]) & (~nmc_counter[0]))? C6:
			  
			  ((~nmc_counter[3]) &(nmc_counter[2]) & (nmc_counter[1]) & (nmc_counter[0]))? C1:
			  ((nmc_counter[3]) &(~nmc_counter[2]) & (~nmc_counter[1]) & (~nmc_counter[0]))? C2:
			  ((nmc_counter[3]) &(~nmc_counter[2]) & (~nmc_counter[1]) & (nmc_counter[0]))? C3:
			  ((nmc_counter[3]) &(~nmc_counter[2]) & (nmc_counter[1]) & (~nmc_counter[0]))? C4:
			  ((nmc_counter[3]) &(~nmc_counter[2]) & (nmc_counter[1]) & (nmc_counter[0]))? C5:
			  ((nmc_counter[3]) &(nmc_counter[2]) & (~nmc_counter[1]) & (~nmc_counter[0]))? C6:pt;
			  
			  
assign temp_key = ((~nmc_counter[3]) &(~nmc_counter[2]) & (~nmc_counter[1]) & (~nmc_counter[0]))?key:
						((~nmc_counter[3]) &(~nmc_counter[2]) & (~nmc_counter[1]) & (nmc_counter[0]))?key:
						((~nmc_counter[3]) &(~nmc_counter[2]) & (nmc_counter[1]) & (~nmc_counter[0]))?key:
						((~nmc_counter[3]) &(~nmc_counter[2]) & (nmc_counter[1]) & (nmc_counter[0]))?key:
						((~nmc_counter[3]) &(nmc_counter[2]) & (~nmc_counter[1]) & (~nmc_counter[0]))?key:
						((~nmc_counter[3]) &(nmc_counter[2]) & (~nmc_counter[1]) & (nmc_counter[0]))?key:
                  ((~nmc_counter[3]) &(nmc_counter[2]) & (nmc_counter[1]) & (nmc_counter[0]))?MAC_KEY:
						((nmc_counter[3]) &(~nmc_counter[2]) & (~nmc_counter[1]) & (~nmc_counter[0])& (get_current_state[3])&(~get_current_state[2])&(get_current_state[1])&(get_current_state[0])&(~clk))? ct:
						((nmc_counter[3]) &(~nmc_counter[2]) & (~nmc_counter[1]) & (nmc_counter[0])& (get_current_state[3])&(~get_current_state[2])&(get_current_state[1])&(get_current_state[0])&(~clk))?ct:
						((nmc_counter[3]) &(~nmc_counter[2]) & (nmc_counter[1]) & (~nmc_counter[0])& (get_current_state[3])&(~get_current_state[2])&(get_current_state[1])&(get_current_state[0])&(~clk))? ct:
						((nmc_counter[3]) &(~nmc_counter[2]) & (nmc_counter[1]) & (nmc_counter[0])& (get_current_state[3])&(~get_current_state[2])&(get_current_state[1])&(get_current_state[0])&(~clk))? ct:
						((nmc_counter[3]) &(nmc_counter[2]) & (~nmc_counter[1]) & (~nmc_counter[0])& (get_current_state[3])&(~get_current_state[2])&(get_current_state[1])&(get_current_state[0])&(~clk))? ct:
						((nmc_counter[3]) &(nmc_counter[2]) & (~nmc_counter[1]) & (nmc_counter[0])& (get_current_state[3])&(~get_current_state[2])&(get_current_state[1])&(get_current_state[0])&(~clk))? ct:

						temp_key;
AES_Enc F_k (
		.pt(pt), 
		.key(temp_key), 
		.clk(clk),  
		.start(start), 
		.reset(reset), 
		.ct(ct),
		.get_current_state(get_current_state),
		.t_After_subbyte(t_After_subbyte)
		);
	
assign w_c1=((~nmc_counter[3]) &(~nmc_counter[2]) & (~nmc_counter[1]) & (nmc_counter[0])& (get_current_state[3])&(~get_current_state[2])&(get_current_state[1])&(get_current_state[0]))?ct^M1:w_c1;
assign w_c2=((~nmc_counter[3]) &(~nmc_counter[2]) & (nmc_counter[1]) & (~nmc_counter[0])& (get_current_state[3])&(~get_current_state[2])&(get_current_state[1])&(get_current_state[0]))?ct^M2:w_c2;
assign w_c3=((~nmc_counter[3]) &(~nmc_counter[2]) & (nmc_counter[1]) & (nmc_counter[0])& (get_current_state[3])&(~get_current_state[2])&(get_current_state[1])&(get_current_state[0]))?ct^M3:w_c3;
assign w_c4=((~nmc_counter[3]) &(nmc_counter[2]) & (~nmc_counter[1]) & (~nmc_counter[0])& (get_current_state[3])&(~get_current_state[2])&(get_current_state[1])&(get_current_state[0]))?ct^M4:w_c4;
assign w_c5=((~nmc_counter[3]) &(nmc_counter[2]) & (~nmc_counter[1]) & (nmc_counter[0])& (get_current_state[3])&(~get_current_state[2])&(get_current_state[1])&(get_current_state[0]))?ct^M5:w_c5;
assign w_c6=((~nmc_counter[3]) &(nmc_counter[2]) & (nmc_counter[1]) & (~nmc_counter[0])& (get_current_state[3])&(~get_current_state[2])&(get_current_state[1])&(get_current_state[0]))?ct^M6:w_c6;



assign load1 = ((~nmc_counter[3]) &(~nmc_counter[2]) & (~nmc_counter[1]) & (nmc_counter[0])& (get_current_state[3])&(~get_current_state[2])&(get_current_state[1])&(get_current_state[0]))?1'b1:1'b0;
assign load2 = ((~nmc_counter[3]) &(~nmc_counter[2]) & (nmc_counter[1]) & (~nmc_counter[0])& (get_current_state[3])&(~get_current_state[2])&(get_current_state[1])&(get_current_state[0]))?1'b1:1'b0;
assign load3 = ((~nmc_counter[3]) &(~nmc_counter[2]) & (nmc_counter[1]) & (nmc_counter[0])& (get_current_state[3])&(~get_current_state[2])&(get_current_state[1])&(get_current_state[0]))?1'b1:1'b0;
assign load4 = ((~nmc_counter[3]) &(nmc_counter[2]) & (~nmc_counter[1]) & (~nmc_counter[0])& (get_current_state[3])&(~get_current_state[2])&(get_current_state[1])&(get_current_state[0]))?1'b1:1'b0;
assign load5 = ((~nmc_counter[3]) &(nmc_counter[2]) & (~nmc_counter[1]) & (nmc_counter[0])& (get_current_state[3])&(~get_current_state[2])&(get_current_state[1])&(get_current_state[0]))?1'b1:1'b0;
assign load6 = ((~nmc_counter[3]) &(nmc_counter[2]) & (nmc_counter[1]) & (~nmc_counter[0])& (get_current_state[3])&(~get_current_state[2])&(get_current_state[1])&(get_current_state[0]))?1'b1:1'b0;

//assign load7 = ((nmc_counter[3]) &(nmc_counter[2]) & (~nmc_counter[1]) & (~nmc_counter[0])& (~get_current_state[3])&(~get_current_state[2])&(~get_current_state[1])&(get_current_state[0]))?1'b1:1'b0;


//assign C1= ((load1)& clk)? ct ^ M1 :C1;
//assign C2= ((load2)& clk)? ct ^ M2 :C2;
//pipo_128_bit
pipo_128_bit  Reg_C1(.clk(load1&(~clk)),.clear(clear),.pi(w_c1),.po(C1));
pipo_128_bit  Reg_C2(.clk(load2&(~clk)),.clear(clear),.pi(w_c2),.po(C2));
pipo_128_bit  Reg_C3(.clk(load3&(~clk)),.clear(clear),.pi(w_c3),.po(C3));
pipo_128_bit  Reg_C4(.clk(load4&(~clk)),.clear(clear),.pi(w_c4),.po(C4));
pipo_128_bit  Reg_C5(.clk(load5&(~clk)),.clear(clear),.pi(w_c5),.po(C5));
pipo_128_bit  Reg_C6(.clk(load6&(~clk)),.clear(clear),.pi(w_c6),.po(C6));
pipo_128_bit  Reg_MAC(.clk((nmc_counter[3]) &(nmc_counter[2]) & (~nmc_counter[1]) & (nmc_counter[0])),.pi(temp_key),.po(MAC));

//NMC_counter count_nmc (.start(start),.clk(clk),.reset(reset),.counter(nmc_counter));

NMC_counter count_nmc (
		.start(start), 
		.clk(clk), 
		.reset(reset), 
		.get_current_state(get_current_state),
		.counter(nmc_counter)
	);


//pipo_3bit nmc_counter_reg (.clk(clk),.clear(reset),.pi(nmc_state),.po(nmc_counter));
//assign nmc_signal = (get_current_state==4'b1011)?1'b1:1'b0;
//assign nmc_state = (nmc_signal)?nmc_counter +1:nmc_counter;
endmodule
//////////////////////////////////////////////////////////////////////
module pipo_128_bit(input clk,input clear,input [0:127]  pi,output reg [0:127] po);
always @(negedge clk)
begin
if (clear)
po<= 128'h00000000000000000000000000000000;
else
po <= pi;
end
endmodule
/////////////////////////////////////////////////////////////////////////////////////////////////




/////////////////////////////////////////////////////////////////////////////////////////////////
module NMC_counter(input start,input clk,input reset,input[3:0] get_current_state, output [3:0] counter);
wire [3:0] f_counter;
pipo_4_bit counter_reg (.clk(clk),.clear(reset),.pi(f_counter),.po(counter));
assign f_counter =  start?(get_current_state[3]&(~get_current_state[2])&get_current_state[1]&(~get_current_state[0]))?counter+1:counter
                         :4'b0000;
 
 //assign f_counter =  start?3'b111:3'b000;
endmodule
/////////////////////////////////////////////////////////////////////////////////////////////////
module pipo_4_bit(input clk,input clear,input [3:0]  pi,output reg [3:0] po);
always @(posedge clk)
begin
if (clear)
po<= 4'b0000;
else
po <= pi;
end
endmodule
/////////////////////////////////////////////////////////////////////////////////////////////////
/*module pipo_3bit(input clk,input clear,input [3:0]  pi,output reg [3:0] po);
always @(posedge clk)
begin
if (clear)
po<= 3'b0000;
else
po <= pi;
end
endmodule
*/



