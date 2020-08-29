`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:59:28 07/08/2020 
// Design Name: 
// Module Name:    single_pc 
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
module single_pc(clk, rst, i_pc, o_pc);
parameter N=9;
input wire clk, rst;
input  wire[N-1:0] i_pc;
output wire[N-1:0] o_pc;
        reg[N-1:0] t_pc;
assign o_pc = rst ? {N{1'b1}}:t_pc;
always @(posedge clk)
	t_pc <= i_pc; 
endmodule
