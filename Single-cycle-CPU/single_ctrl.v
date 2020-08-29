`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:08:25 07/08/2020 
// Design Name: 
// Module Name:    single_ctrl 
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
module single_ctrl(OP, ALUop, RegDst, RegWrite, Branch, Jump,
		      MemtoReg, MemRead, MemWrite, ALUsrc, rst);
input  wire      rst;
input  wire[5:0] OP;
output wire[1:0] ALUop;
output wire RegDst, RegWrite, ALUsrc, Branch, Jump;
output wire MemtoReg, MemRead, MemWrite;
wire R, LW, SW, BEQ;
assign R  = ~OP[0]&~OP[1]&~OP[2]&~OP[3]&~OP[4]&~OP[5];//000000
assign LW =  OP[0]& OP[1]&~OP[2]&~OP[3]&~OP[4]& OP[5];//100011
assign SW =  OP[0]& OP[1]&~OP[2]& OP[3]&~OP[4]& OP[5];//101011
assign BEQ= ~OP[0]&~OP[1]& OP[2]&~OP[3]&~OP[4]&~OP[5];//000100
assign ALUop    = ~rst & {R, BEQ};
assign RegDst   = ~rst & R;
assign RegWrite = ~rst & (R | LW);
assign Branch   = ~rst & BEQ;
assign Jump = (~OP[5]&~OP[4]&~OP[3]&~OP[2]&OP[1]&~OP[0]);
assign MemtoReg = ~rst & LW;
assign MemRead = ~rst & LW;
assign MemWrite=~rst & SW;
assign ALUsrc = ~rst & (LW | SW);

endmodule

