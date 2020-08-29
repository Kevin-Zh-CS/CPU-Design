`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:57:55 07/08/2020 
// Design Name: 
// Module Name:    single_mux5 
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

module single_mux5(A, B, Ctrl, S);//2to1MUX
 parameter N = 5;//N=5
 input wire [N-1:0] A, B;
 input Ctrl;
 output wire [N-1:0] S;
 assign S = (Ctrl == 1'b0) ? (A) : (B);
endmodule