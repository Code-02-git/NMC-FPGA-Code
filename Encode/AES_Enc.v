`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    09:10:58 09/19/2023 
// Design Name: 
// Module Name:    AES_Enc 
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
module AES_Enc(
    input [0:127] pt,
    input [0:127] key,
    input clk,
	 input start,
	 input reset,
    output [0:127] ct,
	 output [3:0] get_current_state

    );
wire [0:127] out_key;
wire [0:127] intermidiate_round_result_reg;
wire [0:127] t_After_subbyte;
wire [0:127] after_shift_second;
wire [0:127] t_After_mixcol;
wire mux_select;
wire [0:127] mux_third_op;
wire stop_mix_col;
	 
wire first_or_next;
wire [0:127] after_first_xor,intermidiate_value;
wire [3:0] state;
assign get_current_state = state;
assign first_or_next= ((get_current_state==4'b0000)|(get_current_state==4'b1011))?1'b0:1'b1;
assign mux_select =(~get_current_state[3]&~get_current_state[2]&~get_current_state[1]&get_current_state[0])?1'b1:1'b0;
assign stop_mix_col = (get_current_state[3]&~get_current_state[2]&get_current_state[1]&get_current_state[0])?1'b1:1'b0;

Combined_control_path   CCP (.clk(clk),
									  .start(start),
									  .reset(reset),
									  .get_current_state(get_current_state),
									  .state(state)
                             );


key_generator         keygen (
										.ip_key1(key), 
										.clk(clk), 
										.reset(reset), 
										.state(get_current_state), 
										.first_or_next(first_or_next),
										.out_key(out_key)
									);
									
									
xor_operation_128bit  first_xor(.ip1(pt),.ip2(out_key),.op(after_first_xor));

mux2x1 mux_first(.inp1(intermidiate_value),.inp2(after_first_xor),.ctrl_signal(mux_select),.out(ct));

pipo_128_bit_reg intermidiate_round_result (.clk(clk),.clear(reset),.pi(ct),.po(intermidiate_round_result_reg));
 
After_subbyte      sub(.Din(intermidiate_round_result_reg),.Dout(t_After_subbyte));

shift_row SR2(.Din(t_After_subbyte),.Dout(after_shift_second));	

After_mix_col      before_op_mix (.Din(after_shift_second),.Dout(t_After_mixcol));

mux2x1 mux_third(.inp1(t_After_mixcol),.inp2(after_shift_second),.ctrl_signal(stop_mix_col),.out(mux_third_op));

xor_operation_128bit  second_xor(.ip1(mux_third_op),.ip2(out_key),.op(intermidiate_value));
								

endmodule
///////////////////////////////////////////////////////////////////////////
module Combined_control_path(input  clk,input start,input reset,
									  input  [3:0]  get_current_state,
									  output stop_mix_col,
									  output [3:0] state
                             
);

reg r_start,r_stop_mix_col;
wire [3:0] r_state;

assign stop_mix_col=r_stop_mix_col;

pipo_4bit state_reg (.clk(clk),.clear(reset),.pi(r_state),.po(state));

assign r_state =  start?
((~get_current_state[3])& (~get_current_state[2])& (~get_current_state[1])& (~get_current_state[0]))?4'b0001:
((~get_current_state[3])& (~get_current_state[2])& (~get_current_state[1])& (get_current_state[0])) ?4'b0010:
((~get_current_state[3])& (~get_current_state[2])& (get_current_state[1])&  (~get_current_state[0]))?4'b0011:
((~get_current_state[3])& (~get_current_state[2])& (get_current_state[1])&  (get_current_state[0])) ?4'b0100:
((~get_current_state[3])& (get_current_state[2])&  (~get_current_state[1])& (~get_current_state[0]))?4'b0101:
((~get_current_state[3])& (get_current_state[2])&  (~get_current_state[1])& (get_current_state[0])) ?4'b0110:
((~get_current_state[3])& (get_current_state[2])&  (get_current_state[1])&  (~get_current_state[0]))?4'b0111:
((~get_current_state[3])& (get_current_state[2])&  (get_current_state[1])&  (get_current_state[0])) ?4'b1000:
((get_current_state[3])&  (~get_current_state[2])& (~get_current_state[1])& (~get_current_state[0]))?4'b1001:
((get_current_state[3])&  (~get_current_state[2])& (~get_current_state[1])& (get_current_state[0])) ?4'b1010:
((get_current_state[3])&  (~get_current_state[2])& (get_current_state[1])&  (~get_current_state[0]))?4'b1011:
((get_current_state[3])&  (~get_current_state[2])& (get_current_state[1])&  (get_current_state[0]))?4'b0001:

 get_current_state:4'b0000;
 

endmodule
/////////////////////////////////////////////////////////////////////////////////////////////////
module pipo_4bit(input clk,input clear,input [3:0]  pi,output reg [3:0] po);
always @(posedge clk)
begin
if (clear)
po<= 4'b0000;
else
po <= pi;
end
endmodule
  



////////////////////////////////////////////////////////////////////////////////

module key_generator(input [0:127] ip_key1,
							input clk,
							input reset,
							input [3:0] state,
							input first_or_next,
							output [0:127] out_key
    );
      wire [0:127] po,mux2x1_out,ip_key2;
		wire [0:31] o_word0,o_word1,o_word2,o_word3,word3_xor_word2;
		wire [0:31] interim_key_word0,interim_key_word1,interim_key_word2,interim_key_word3;
		wire [0:31] round_const_vslue;
		wire [0:7] temp_f_rcon_val;
		
		wire [0:31] after_round_const;
		wire [0:31] redy_for_shift;
		wire [0:31] op_rot;
		wire [0:31] op_subbyte;

		
		mux2x1 mux_1(.inp1(ip_key1),.inp2(ip_key2),.ctrl_signal(first_or_next),.out(mux2x1_out));

		
		pipo_128_bit_reg aes_key (.clk(clk),.clear(reset),.pi(mux2x1_out),.po(po));
		
		assign o_word0 = po[0:31];
	   assign o_word1 = po[32:63];
	   assign o_word2 = po[64:95];
	   assign o_word3 = po[96:127];

      Rot_word_aes R01(o_word3,op_rot);
		
		sub_byte_aes S01(op_rot,op_subbyte);
   	round_const rcon_updated_value(.state(state),.clk(clk),.reset(reset),.rcon_val(temp_f_rcon_val));
		assign round_const_vslue = {temp_f_rcon_val,24'h000000};
		xor_operation xor_for_rcon (.ip1(round_const_vslue),.ip2(op_subbyte),.op(after_round_const));
		xor_operation xor_for_1 (.ip1(after_round_const),.ip2(o_word0),.op(interim_key_word0));
		xor_operation xor_for_2 (.ip1(interim_key_word0),.ip2(o_word1),.op(interim_key_word1));
		xor_operation xor_for_3(.ip1(interim_key_word1),.ip2(o_word2),.op(interim_key_word2));
		xor_operation xor_for_4 (.ip1(interim_key_word2),.ip2(o_word3),.op(interim_key_word3));
		
		

	assign ip_key2	 		  				  = {interim_key_word0,interim_key_word1,interim_key_word2,interim_key_word3};
	assign out_key  		              = po;

		
endmodule

////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////
module mux2x1(inp1,inp2,ctrl_signal,out);
input [0:127]  inp1;
input [0:127]  inp2;
input  ctrl_signal;
output[0:127]  out;
assign out = ctrl_signal ? inp2 : inp1;//
endmodule
//////////////////////////////////////////////////////////////////////////////////////////
module pipo_128_bit_reg(clk,clear, pi, po);
input clk,clear;
input  [0:127] pi;
output [0:127] po;
wire   [0:127] pi;
reg    [0:127] po;
always @(posedge clk)
begin
if (clear)
po<= 128'h00000000000000000000000000000000;
else
po <= pi;
end
endmodule
//////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////
module xor_operation(input [0:31] ip1,input [0:31] ip2,output [0:31] op);
assign op = ip1 ^ ip2;
endmodule
//////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////
module Rot_word_aes(
    input [31:0] Rin,
    output [31:0] Rout
    );
assign Rout[31:8]=Rin[23:0];
assign Rout[7:0]=Rin[31:24];
endmodule
//////////////////////////////////////////////////////////////////////////////////
module sub_byte_aes(
    input [31:0] Rin,
    output [31:0] Rout
    );
wire [7:0] a,b,c,d,a_out,b_out,c_out,d_out;
assign a=Rin[31:24];
assign b=Rin[23:16];
assign c=Rin[15:8];
assign d=Rin[7:0];

aes_sbox    S01(a,a_out);
aes_sbox    S02(b,b_out);
aes_sbox    S03(c,c_out);
aes_sbox    S04(d,d_out);


assign Rout[31:24]=a_out;
assign Rout[23:16]=b_out;
assign Rout[15:8] =c_out;
assign Rout[7:0]  =d_out;

endmodule


////////////////////////////
module aes_sbox(input [7:0] inp,output [7:0] op_sbox);
wire [7:0] after_affine_inverse,
           after_first_mux,
			  after_inv_mul,
			  after_affine;

multiplicative_inverse uut (.a(inp),.b(after_inv_mul));
Affine_transfrom AT(.inp(after_inv_mul),.op(op_sbox));

endmodule
///////////////////////////////////////////////////////////
module Affine_transfrom(input [7:0] inp,output [7:0] op);
wire b7,b6,b5,b4,b3,b2,b1,b0;

assign b7 =inp[7]^inp[6]^inp[5]^inp[4]^inp[3]^1'b0;
assign b6 =inp[6]^inp[5]^inp[4]^inp[3]^inp[2]^1'b1;
assign b5 =inp[5]^inp[4]^inp[3]^inp[2]^inp[1]^1'b1;
assign b4 =inp[4]^inp[3]^inp[2]^inp[1]^inp[0]^1'b0;
assign b3 =inp[7]^inp[3]^inp[2]^inp[1]^inp[0]^1'b0;
assign b2 =inp[7]^inp[6]^inp[2]^inp[1]^inp[0]^1'b0;
assign b1 =inp[7]^inp[6]^inp[5]^inp[1]^inp[0]^1'b1;
assign b0 =inp[7]^inp[6]^inp[5]^inp[4]^inp[0]^1'b1;

assign op = {b7,b6,b5,b4,b3,b2,b1,b0};
endmodule
//////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////


module multiplicative_inverse(input [7:0] a,output [7:0] b);
wire [7:0] after_mul_del,before_inv_mul,after_inv_mul;
wire [3:0] after_mul_del_hl,after_mul_del_lw,after_square_hl,after_mul_lamda,after_xor_upper_lower,after_mul_pow4_lw,after_xor_lamda_pow4,after_inv_lamda_xor,after_final_mul_hl,after_final_mul_lw;
//wire b7,b6,b5,b4,b3,b2,b1,b0;
assign after_mul_del_hl = after_mul_del[7:4];
assign after_mul_del_lw = after_mul_del[3:0];
assign after_xor_upper_lower = after_mul_del_hl^after_mul_del_lw;
assign after_xor_lamda_pow4  = after_mul_lamda^after_mul_pow4_lw;
assign before_inv_mul={after_final_mul_hl,after_final_mul_lw};


matrix_mul_delta          delta_mul(.a(a),.b(after_mul_del));
square_power4             sq_power_4 (.a(after_mul_del_hl),.b(after_square_hl));
multiplication_with_lamda mul_with_lmda(.a(after_square_hl),.b(after_mul_lamda));

power_4_mul               mul1_pow4 (.a(after_xor_upper_lower),.b(after_mul_del_lw),.c(after_mul_pow4_lw));
multiplicative_inv_power_four inv_pow4 (.a(after_xor_lamda_pow4),.b(after_inv_lamda_xor));
power_4_mul               mul2_pow4 (.a(after_mul_del_hl),.b(after_inv_lamda_xor),.c(after_final_mul_hl));
power_4_mul               mul3_pow4 (.a(after_xor_upper_lower),.b(after_inv_lamda_xor),.c(after_final_mul_lw));
inv_matrix_mul_delta      inv_delta_mul (.a(before_inv_mul),.b(after_inv_mul));


assign b=after_inv_mul;
endmodule
///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////

////////////////////////////////////////////////////////
module matrix_mul_delta(input [7:0] a,output [7:0] b);
wire b7,b6,b5,b4,b3,b2,b1,b0;
assign b7 = a[7]^a[5];
assign b6 = a[7]^a[6]^a[4]^a[3]^a[2]^a[1];
assign b5 = a[7]^a[5]^a[3]^a[2];
assign b4 = a[7]^a[5]^a[3]^a[2]^a[1];
assign b3 = a[7]^a[6]^a[2]^a[1];
assign b2 = a[7]^a[4]^a[3]^a[2]^a[1];
assign b1 = a[6]^a[4]^a[1];
assign b0 = a[6]^a[1]^a[0];
assign b={b7,b6,b5,b4,b3,b2,b1,b0};

endmodule
//////////////////////////////////////////////////////////////////////////////////
//////																							///////
//////																							///////
//////																							///////
//////////////////////////////////////////////////////////////////////////////////


module square_power4(input [3:0] a,output [3:0] b);
assign b[3] = a[3];
assign b[2] = a[3]^a[2];
assign b[1] = a[2]^a[1];
assign b[0] = a[3]^a[1]^a[0];
endmodule
//////////////////////////////////////////////////////////////////////////////////
//////																							///////
//////																							///////
//////																							///////
//////////////////////////////////////////////////////////////////////////////////


module multiplication_with_lamda(input [3:0] a,output [3:0] b);
assign b[3] = a[2]^a[0];
assign b[2] = a[3]^a[2]^a[1]^a[0];
assign b[1] = a[3];
assign b[0] = a[2];
assign b[0] = a[2];
endmodule

//////////////////////////////////////////////////////////////////////////////////
//////																							///////
//////																							///////
//////																							///////
//////////////////////////////////////////////////////////////////////////////////

module power_4_mul(input [3:0] a,input [3:0] b,output [3:0] c);
wire [1:0] a3a2,a1a0,b3b2,b1b0,mul_a3a2_b3b2,after_x_phi,xor_a3a2_a1a0,xor_b3b2_b1b0,mul_a3a2a1a0_b3b2b1b0,mul_a1a0_b1b0,xor_gen_first2,xor_gen_second2;
assign a3a2 = a[3:2];
assign a1a0 = a[1:0];
assign b3b2 = b[3:2];
assign b1b0 = b[1:0];
assign xor_a3a2_a1a0   = a3a2 ^ a1a0;
assign xor_b3b2_b1b0   = b3b2 ^ b1b0;
assign xor_gen_first2  = mul_a3a2a1a0_b3b2b1b0^mul_a1a0_b1b0;
assign xor_gen_second2 = after_x_phi^mul_a1a0_b1b0;

power_2_mul    mul1(.b(a3a2),.a(b3b2),.c(mul_a3a2_b3b2));
mul_x_with_phi x_phi(.a(mul_a3a2_b3b2),.b(after_x_phi));
power_2_mul    mul2(.b(xor_a3a2_a1a0),.a(xor_b3b2_b1b0),.c(mul_a3a2a1a0_b3b2b1b0));
power_2_mul    mul3(.b(a1a0),.a(b1b0),.c(mul_a1a0_b1b0));
assign c={xor_gen_first2,xor_gen_second2};



endmodule
//////////////////////////////////////////////////////////////////////////////////
//////																							///////
//////																							///////
//////																							///////
//////////////////////////////////////////////////////////////////////////////////

module power_2_mul(input [1:0] b,input [1:0] a,output [1:0] c );
wire q1w1,q0w0,q0,q1,w0,w1,q1q0,w1w0,q1q0w1w0,r1,r2;
assign q1=a[1];
assign q0=a[0];
assign w1=b[1];
assign w0=b[0];
assign q1w1 = q1&w1;
assign q0w0 = q0&w0;
assign q1q0 = q1^q0;
assign w1w0 = w1^w0;
assign q1q0w1w0 = q1q0 & w1w0;
assign r1  = q1q0w1w0^q0w0 ;
assign r2  =  q1w1^q0w0;
assign c ={r1,r2};


endmodule
//////////////////////////////////////////////////////////////////////////////////
//////																							///////
//////																							///////
//////																							///////
//////////////////////////////////////////////////////////////////////////////////

module mul_x_with_phi(input [1:0] a,output [1:0] b);
assign b[1]=a[1]^a[0];
assign b[0]=a[1];
endmodule

//////////////////////////////////////////////////////////////////////////////////
//////																							///////
//////																							///////
//////																							///////
//////////////////////////////////////////////////////////////////////////////////


module multiplicative_inv_power_four(input [3:0] a,output [3:0] b);

assign b[3] = a[3]^(a[3]&a[2]&a[1])^(a[3]&a[0])^a[2];
assign b[2] = (a[3]&a[2]&a[1])^(a[3]&a[2]&a[0])^(a[3]&a[0])^a[2]^(a[2]&a[1]);
assign b[1] = a[3]^(a[3]&a[2]&a[1])^(a[3]&a[1]&a[0])^a[2]^(a[2]&a[0])^a[1];
assign b[0] = (a[3]&a[2]&a[1])^(a[3]&a[2]&a[0])^(a[3]&a[1])^(a[3]&a[1]&a[0])^(a[3]&a[0])^a[2]^(a[2]&a[1])^(a[2]&a[1]&a[0])^a[1]^a[0];
endmodule

//////////////////////////////////////////////////////////////////////////////////
//////																							///////
//////																							///////
//////																							///////
//////////////////////////////////////////////////////////////////////////////////



module inv_matrix_mul_delta(input [7:0] a,output [7:0] b);
wire b7,b6,b5,b4,b3,b2,b1,b0;
assign b7=a[7]^a[6]^a[5]^a[1];
assign b6=a[6]^a[2];
assign b5=a[6]^a[5]^a[1];
assign b4=a[6]^a[5]^a[4]^a[2]^a[1];
assign b3=a[5]^a[4]^a[3]^a[2]^a[1];
assign b2=a[7]^a[4]^a[3]^a[2]^a[1];
assign b1=a[5]^a[4];
assign b0=a[6]^a[5]^a[4]^a[2]^a[0];
assign b={b7,b6,b5,b4,b3,b2,b1,b0};
endmodule
/////////////////////////////////////////////////////

/////////////////////////////////////////////////////////////////////////////////////////////

module round_const (input [3:0] state,input clk, input reset,output  [0:7] rcon_val);
wire [0:7]  f_rcon_val;
wire [0:7]  op_rcon; 
//pipo_8bit rcon_reg (.clk(clk),.clear(reset),.pi(f_rcon_val),.po(op_rcon));
assign rcon_val = f_rcon_val;
	assign f_rcon_val =      ((state) == 4'b0001)?8'h01:
									 ((state) == 4'b0010)?8'h02:
									 ((state) == 4'b0011)?8'h04:
									 ((state) == 4'b0100)?8'h08: 
									 ((state) == 4'b0101)?8'h10:
									 ((state) == 4'b0110)?8'h20:
									 ((state) == 4'b0111)?8'h40:
									 ((state) == 4'b1000)?8'h80:
									 ((state) == 4'b1001)?8'h1b:
									 ((state) == 4'b1010)?8'h36:
								    8'h00;
									 


endmodule
///////////////////////////////////////////////////////////////////////////////////////////
module xor_operation_128bit(input [0:127] ip1,input [0:127] ip2,output [0:127] op
    );

assign op = ip1 ^ ip2;
endmodule
///////////////////////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////////////////////////
////
////
////
//////////////////////////////////////////////////////////////////////////////////
module After_subbyte    (input [127:0] Din,output [127:0] Dout);
wire [7:0]    T_Din0,
              T_Din1,
              T_Din2,
              T_Din3,
              T_Din4,
              T_Din5,
              T_Din6,
              T_Din7,
              T_Din8,
              T_Din9,
              T_Din10,
              T_Din11,
              T_Din12,
              T_Din13,
              T_Din14,
              T_Din15,
              T_Dout0,
              T_Dout1,
              T_Dout2,
              T_Dout3,
              T_Dout4,
              T_Dout5,
              T_Dout6,
              T_Dout7,
              T_Dout8,
              T_Dout9,
              T_Dout10,
              T_Dout11,
              T_Dout12,
              T_Dout13,
              T_Dout14,
              T_Dout15;


               assign T_Din0   = Din[127:120];
               assign T_Din1   = Din[119:112];
               assign T_Din2   = Din[111:104];
               assign T_Din3   = Din[103:96];
               assign T_Din4   = Din[95:88];
               assign T_Din5   = Din[87:80];
               assign T_Din6   = Din[79:72];
               assign T_Din7   = Din[71:64];
               assign T_Din8   = Din[63:56];
               assign T_Din9   = Din[55:48];
               assign T_Din10  = Din[47:40];
               assign T_Din11  = Din[39:32];
               assign T_Din12  = Din[31:24];

               assign T_Din13  = Din[23:16];
               assign T_Din14  = Din[15:8];
               assign T_Din15  = Din[7:0];

	
              aes_sbox    AS0_0      (.inp(T_Din0),.op_sbox(T_Dout0));
              aes_sbox    AS1_0      (.inp(T_Din1),.op_sbox(T_Dout1));
              aes_sbox    AS2_0      (.inp(T_Din2),.op_sbox(T_Dout2));
              aes_sbox    AS3_0      (.inp(T_Din3),.op_sbox(T_Dout3));
              aes_sbox    AS4_0      (.inp(T_Din4),.op_sbox(T_Dout4));
              aes_sbox    AS5_0      (.inp(T_Din5),.op_sbox(T_Dout5));
              aes_sbox    AS6_0      (.inp(T_Din6),.op_sbox(T_Dout6));
              aes_sbox    AS7_0      (.inp(T_Din7),.op_sbox(T_Dout7));
              aes_sbox    AS8_0      (.inp(T_Din8),.op_sbox(T_Dout8));
              aes_sbox    AS9_0      (.inp(T_Din9),.op_sbox(T_Dout9));
              aes_sbox   AS10_0      (.inp(T_Din10),.op_sbox(T_Dout10));
              aes_sbox   AS11_0      (.inp(T_Din11),.op_sbox(T_Dout11));
              aes_sbox   AS12_0      (.inp(T_Din12),.op_sbox(T_Dout12));
              aes_sbox   AS13_0      (.inp(T_Din13),.op_sbox(T_Dout13));
              aes_sbox   AS14_0      (.inp(T_Din14),.op_sbox(T_Dout14));
              aes_sbox   AS15_0      (.inp(T_Din15),.op_sbox(T_Dout15));

       assign     Dout  = {T_Dout0,T_Dout1,T_Dout2,T_Dout3,T_Dout4,T_Dout5,T_Dout6,T_Dout7,T_Dout8,T_Dout9,T_Dout10,T_Dout11,T_Dout12,T_Dout13,T_Dout14,T_Dout15};

  // assign Dout=Din;
endmodule
///////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////
/////
//////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////////////////////////
module shift_row(input [127:0] Din,output [127:0] Dout);

wire [31:0] T_Ip_Ar2,T_Ip_Ar3,T_Ip_Ar4,T_Op_Ar2,T_Op_Ar3,T_Op_I_Ar3,T_Op_Ar4,T_Op_I1_Ar4,T_Op_I2_Ar4;
            //T_Op_Ar2_dec,T_Op_I_Ar3_dec,T_Op_Ar3_dec,T_Op_I1_Ar4_dec,T_Op_I2_Ar4_dec,T_Op_Ar4_dec;
//wire [127:0] shift_enc;
assign  T_Ip_Ar2 = {Din[119:112],Din[87:80],Din[55:48],Din[23:16]};
assign  T_Ip_Ar3 = {Din[111:104],Din[79:72],Din[47:40],Din[15:8]};
assign  T_Ip_Ar4 = {Din[103:96],Din[71:64],Din[39:32],Din[7:0]};

Rot_word_enc R0(T_Ip_Ar2,T_Op_Ar2);

Rot_word_enc R11(T_Ip_Ar3,T_Op_I_Ar3);
Rot_word_enc R12(T_Op_I_Ar3,T_Op_Ar3);

Rot_word_enc R21(T_Ip_Ar4,T_Op_I1_Ar4);
Rot_word_enc R22(T_Op_I1_Ar4,T_Op_I2_Ar4);
Rot_word_enc R23(T_Op_I2_Ar4,T_Op_Ar4);
assign Dout = {Din[127:120],T_Op_Ar2[31:24],T_Op_Ar3[31:24],T_Op_Ar4[31:24],Din[95:88],T_Op_Ar2[23:16],T_Op_Ar3[23:16],T_Op_Ar4[23:16],Din[63:56],T_Op_Ar2[15:8],T_Op_Ar3[15:8],T_Op_Ar4[15:8],Din[31:24],T_Op_Ar2[7:0],T_Op_Ar3[7:0],T_Op_Ar4[7:0]};

endmodule
//////////////////////////////////////////////////////////////////////////////////
//////																							///////
//////																							///////
//////																							///////
//////////////////////////////////////////////////////////////////////////////////
module Rot_word_enc(
    input [31:0] Rin,
    output [31:0] Rout
    );
assign Rout[31:8]=Rin[23:0];
assign Rout[7:0]=Rin[31:24];
endmodule
///////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////
/////
//////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////
module After_mix_col    (input [127:0] Din,output [127:0] Dout);

wire [31:0]   din1,din2,din3,din4,dout1,dout2,dout3,dout4;
wire [7:0]    T_Ip1,
              T_Ip2,
              T_Ip3,
              T_Ip4,
              T_Ip5,
              T_Ip6,
              T_Ip7,
              T_Ip8,
              T_Ip9,
              T_Ip10,
              T_Ip11,
              T_Ip12,
              T_Ip13,
              T_Ip14,
              T_Ip15,
              T_Ip16,
              T_Op1,
              T_Op2,
              T_Op3,
              T_Op4,
              T_Op5,
              T_Op6,
              T_Op7,
              T_Op8,
              T_Op9,
              T_Op10,
              T_Op11,
              T_Op12,
              T_Op13,
              T_Op14,
              T_Op15,
              T_Op16;

        //assign T_c = counter;
       
       assign   T_Ip1 =Din[127:120];
       assign   T_Ip2 =Din[119:112];
       assign   T_Ip3 =Din[111:104];
       assign   T_Ip4 =Din[103:96];

        assign  T_Ip5 =Din[95:88];
        assign  T_Ip6 =Din[87:80];
        assign  T_Ip7 =Din[79:72];
        assign  T_Ip8 =Din[71:64];

        assign  T_Ip9 =Din[63:56];
        assign  T_Ip10=Din[55:48];
        assign  T_Ip11=Din[47:40];
        assign  T_Ip12=Din[39:32];

        assign  T_Ip13=Din[31:24];
        assign  T_Ip14=Din[23:16];
        assign  T_Ip15=Din[15:8];
        assign  T_Ip16=Din[7:0];


       //Mix_coloum  C0_1  (T_Ip1,T_Ip2,T_Ip3,T_Ip4,S_T_M,T_Op1,T_Op2,T_Op3,T_Op4);
       //Mix_coloum  C1_1  (T_Ip5,T_Ip6,T_Ip7,T_Ip8,S_T_M,T_Op5,T_Op6,T_Op7,T_Op8);
       //Mix_coloum  C2_1  (T_Ip9,T_Ip10,T_Ip11,T_Ip12,S_T_M,T_Op9,T_Op10,T_Op11,T_Op12);
       //Mix_coloum  C3_1  (T_Ip13,T_Ip14,T_Ip15,T_Ip16,S_T_M,T_Op13,T_Op14,T_Op15,T_Op16);
       assign din1 = {T_Ip1,T_Ip2,T_Ip3,T_Ip4};
		 assign din2 = {T_Ip5,T_Ip6,T_Ip7,T_Ip8};
		 assign din3 = {T_Ip9,T_Ip10,T_Ip11,T_Ip12};
		 assign din4 = {T_Ip13,T_Ip14,T_Ip15,T_Ip16};
		 

       mix_col_operation C0_1 (.din(din1),.dout(dout1));
		 mix_col_operation C1_1 (.din(din2),.dout(dout2));
		 mix_col_operation C2_1 (.din(din3),.dout(dout3));
		 mix_col_operation C3_1 (.din(din4),.dout(dout4));

    // assign Dout ={T_Op1,T_Op2,T_Op3,T_Op4,T_Op5,T_Op6,T_Op7,T_Op8,T_Op9,T_Op10,T_Op11,T_Op12,T_Op13,T_Op14,T_Op15,T_Op16};
     assign Dout ={dout1,dout2,dout3,dout4};

endmodule

module mix_col_operation(input [31:0] din,output [31:0] dout);


wire [7:0] pg1_a,pg1_b,pg1_c,pg1_d,pg2_a,pg2_b,pg2_c,pg2_d,pg3_a,pg3_b,pg3_c,pg3_d,pg4_a,pg4_b,pg4_c,pg4_d,
           interim_1a,interim_1b,interim_2a,interim_2b,interim_3a,interim_3b,interim_4a,interim_4b,
			  din1,din2,din3,din4;
assign din1 = din[31:24];
assign din2 = din[23:16];
assign din3 = din[15:8];
assign din4 = din[7:0];

product_generator PG1 (.din(din1),.dout1(pg1_a),.dout2(pg1_b),.dout3(pg1_c),.dout4(pg1_d));
product_generator PG2 (.din(din2),.dout1(pg2_a),.dout2(pg2_b),.dout3(pg2_c),.dout4(pg2_d));
product_generator PG3 (.din(din3),.dout1(pg3_a),.dout2(pg3_b),.dout3(pg3_c),.dout4(pg3_d));
product_generator PG4 (.din(din4),.dout1(pg4_a),.dout2(pg4_b),.dout3(pg4_c),.dout4(pg4_d));

assign interim_1a = pg4_a ^ pg2_b;
assign interim_1b = pg3_c ^ pg1_d;
assign interim_2a = pg1_a ^ pg3_b;
assign interim_2b = pg4_c ^ pg2_d;
assign interim_3a = pg4_b ^ pg2_a;
assign interim_3b = pg1_c ^ pg3_d;
assign interim_4a = pg3_a ^ pg1_b;
assign interim_4b = pg2_c ^ pg4_d;

assign dout[31:24] = interim_1a ^ interim_1b;
assign dout[23:16] = interim_2a ^ interim_2b; 
assign dout[15:8]  = interim_3a ^ interim_3b;
assign dout[7:0]   = interim_4a ^ interim_4b;



/*
wire [7:0] pg1_a,pg1_b,pg1_c,pg1_d,pg2_a,pg2_b,pg2_c,pg2_d,pg3_a,pg3_b,pg3_c,pg3_d,pg4_a,pg4_b,pg4_c,pg4_d,
           interim_1a,interim_1b,interim_2a,interim_2b,interim_3a,interim_3b,interim_4a,interim_4b,
			  din1,din2,din3,din4,t_d1,t_d2,t_d3,t_d4;
			  
wire [7:0] pg1_a_t,pg1_b_t,pg1_c_t,pg1_d_t,pg2_a_t,pg2_b_t,pg2_c_t,pg2_d_t,pg3_a_t,pg3_b_t,pg3_c_t,pg3_d_t,pg4_a_t,pg4_b_t,pg4_c_t,pg4_d_t,
           interim_1a_t,interim_1b_t,interim_2a_t,interim_2b_t,interim_3a_t,interim_3b_t,interim_4a_t,interim_4b_t;
wire [31:0] t_dout;
assign din1 = din[31:24];
assign din2 = din[23:16];
assign din3 = din[15:8];
assign din4 = din[7:0];

product_generator PG1 (.din(din1),.dec(dec),.dout1(pg1_a),.dout2(pg1_b),.dout3(pg1_c),.dout4(pg1_d));
product_generator PG2 (.din(din2),.dec(dec),.dout1(pg2_a),.dout2(pg2_b),.dout3(pg2_c),.dout4(pg2_d));
product_generator PG3 (.din(din3),.dec(dec),.dout1(pg3_a),.dout2(pg3_b),.dout3(pg3_c),.dout4(pg3_d));
product_generator PG4 (.din(din4),.dec(dec),.dout1(pg4_a),.dout2(pg4_b),.dout3(pg4_c),.dout4(pg4_d));

assign interim_1a = pg4_a ^ pg2_b;
assign interim_1b = pg3_c ^ pg1_d;
assign interim_2a = pg1_a ^ pg3_b;
assign interim_2b = pg4_c ^ pg2_d;
assign interim_3a = pg4_b ^ pg2_a;
assign interim_3b = pg1_c ^ pg3_d;
assign interim_4a = pg3_a ^ pg1_b;
assign interim_4b = pg2_c ^ pg4_d;

assign t_d1   = interim_1a ^ interim_1b;
assign t_d2   = interim_2a ^ interim_2b; 
assign t_d3   = interim_3a ^ interim_3b;
assign t_d4   = interim_4a ^ interim_4b;




product_generator PG1_2 (.din(t_d1),.dec(~dec),.dout1(pg1_a_t),.dout2(pg1_b_t),.dout3(pg1_c_t),.dout4(pg1_d_t));
product_generator PG2_2 (.din(t_d2),.dec(~dec),.dout1(pg2_a_t),.dout2(pg2_b_t),.dout3(pg2_c_t),.dout4(pg2_d_t));
product_generator PG3_2 (.din(t_d3),.dec(~dec),.dout1(pg3_a_t),.dout2(pg3_b_t),.dout3(pg3_c_t),.dout4(pg3_d_t));
product_generator PG4_2 (.din(t_d4),.dec(~dec),.dout1(pg4_a_t),.dout2(pg4_b_t),.dout3(pg4_c_t),.dout4(pg4_d_t));

assign interim_1a_t = pg4_a_t ^ pg2_b_t;
assign interim_1b_t = pg3_c_t ^ pg1_d_t;
assign interim_2a_t = pg1_a_t ^ pg3_b_t;
assign interim_2b_t = pg4_c_t ^ pg2_d_t;
assign interim_3a_t = pg4_b_t ^ pg2_a_t;
assign interim_3b_t = pg1_c_t ^ pg3_d_t;
assign interim_4a_t = pg3_a_t ^ pg1_b_t;
assign interim_4b_t = pg2_c_t ^ pg4_d_t;


assign t_dout[31:24] = interim_1a_t ^ interim_1b_t;
assign t_dout[23:16] = interim_2a_t ^ interim_2b_t; 
assign t_dout[15:8]  = interim_3a_t ^ interim_3b_t;
assign t_dout[7:0]   = interim_4a_t ^ interim_4b_t;


assign dout[31:24] = t_dout[31:24] ^ t_dout[23:16] ^ t_dout[7:0];
assign dout[23:16] = t_dout[31:24] ^ t_dout[23:16] ^ t_dout[15:8]; 
assign dout[15:8]  = t_dout[23:16] ^ t_dout[15:8]  ^ t_dout[7:0];
assign dout[7:0]   = t_dout[31:24] ^ t_dout[15:8]  ^ t_dout[7:0];
*/
endmodule
module product_generator (input [7:0] din,output [7:0] dout1,output [7:0] dout2,output [7:0] dout3,output [7:0] dout4);
wire [7:0] interim_a,interim_b,interim_c,interim_d,interim_2;

multiplication multi_gen(.din(din),.dout1(interim_a),.dout2(interim_b),.dout3(interim_c),.dout4(interim_d));

assign dout1     = interim_a ^ interim_d;
//assign dout2     = interim_a ^ interim_b;
assign dout2     = dout1 ^ interim_b;
//assign dout3     = interim_a ^ interim_c;
assign dout3     = dout1 ^ interim_c;
assign interim_2 = interim_c ^ interim_d;
assign dout4     = interim_2 ^ interim_b;
endmodule

module multiplication (input [7:0] din,output [7:0] dout1,output [7:0] dout2,output [7:0] dout3,output [7:0] dout4);
wire [7:0] after_mul_din1,amd2,amd3,logic_zero,asg;
assign after_mul_din1      = {din[6],din[5],din[4],din[7]^din[3],din[7]^din[2],din[1],din[7]^din[0],din[7]};
assign amd2                = {asg[6],asg[5],asg[4],asg[7]^asg[3],asg[7]^asg[2],asg[1],asg[7]^asg[0],asg[7]};
assign amd3						= {amd2[6],amd2[5],amd2[4],amd2[7]^amd2[3],amd2[7]^amd2[2],amd2[1],amd2[7]^amd2[0],amd2[7]};

//assign amd4                = {amd3[6],amd3[5],amd3[4],amd3[7]^amd3[3],amd3[7]^amd3[2],amd3[1],amd3[7]^amd3[0],amd3[7]};
//assign amd5                = {amd4[6],amd4[5],amd4[4],amd4[7]^amd4[3],amd4[7]^amd4[2],amd4[1],amd4[7]^amd4[0],amd4[7]};
//assign amd6                = {amd5[6],amd5[5],amd5[4],amd5[7]^amd5[3],amd5[7]^amd5[2],amd5[1],amd5[7]^amd5[0],amd5[7]};
assign logic_zero          = 8'b0;
assign dout1               = din;
assign dout2               = after_mul_din1;
assign dout3               = amd2;
assign dout4               = amd3;

switch_gate swg(.din(after_mul_din1),.din2(logic_zero),.dout(asg));

endmodule
module switch_gate (input [7:0] din,input [7:0] din2,output [7:0] dout);
assign dout =  din2;
endmodule


