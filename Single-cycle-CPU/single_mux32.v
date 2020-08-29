`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:02:13 07/08/2020 
// Design Name: 
// Module Name:    single_mux32 
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
module single_mux32(A, B, Ctrl, S);//2to1MUX
 parameter N = 32;//N=32
 input wire [N-1:0] A, B;
 input Ctrl;
 output wire [N-1:0] S;
 assign S = (Ctrl == 1'b0) ? (A) : (B);


endmodule
