`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:58:36 07/08/2020 
// Design Name: 
// Module Name:    single_pc_plus_4 
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
module single_pc_plus_4(i_pc, o_pc);
parameter N=9;
input  wire[N-1:0] i_pc;
output wire[N-1:0] o_pc;
assign o_pc = i_pc + 1; //lkj:+1有时候是+4，根据所用				   //内存而定
endmodule

