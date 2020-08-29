`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:46:50 07/08/2020 
// Design Name: 
// Module Name:    single_mux 
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

module single_mux(A, B, Ctrl, S);
	input  wire[N-1:0] A, B;
	output wire[N-1:0] S;

	parameter N=5;
	assign S = (Ctrl == 1'b0) ? A : B;
endmodule

