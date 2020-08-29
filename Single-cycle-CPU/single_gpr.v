`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:38:00 07/08/2020 
// Design Name: 
// Module Name:    single_gpr 
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
module single_gpr(//general purpose registers
 clk, rst,//clock and reset
 i_adr1, i_adr2,//read register 1 2
 i_adr3,//read register 3, for test
 i_wreg, i_wdata,//register to be written and the data
 i_wen,//RegWrite Enable
 o_op1,o_op2,//read data output 1 2
 o_op3//read data output 3, for test
 );
 input wire clk, rst, i_wen;
 input wire [4:0] i_adr1, i_adr2, i_adr3, i_wreg;
 input wire [31:0] i_wdata;
 output wire [31:0] o_op1, o_op2, o_op3;
 reg [31:0] mem[31:0];//32 local registers
 assign o_op1 = mem[i_adr1];
 assign o_op2 = mem[i_adr2];
 assign o_op3 = mem[i_adr3];
 always @(posedge clk or posedge rst) begin//both on positive pulse written
  if (rst == 1) begin
   mem[0] <= 32'h0000_0000;
  end
  else if (i_wen) begin
   mem[i_wreg] <= (i_wreg == 5'b00000) ? 32'h0000_0000 :
   i_wdata;//zero can't be written
  end
 end
endmodule
