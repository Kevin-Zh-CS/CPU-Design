`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:00:44 07/08/2020 
// Design Name: 
// Module Name:    single_add 
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
module single_add(i_op1, i_op2, o_out);
input  wire[31:0] i_op1, i_op2;
output wire[31:0] o_out;
assign o_out = i_op1 + i_op2;
endmodule

