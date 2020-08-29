`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:25:02 07/08/2020 
// Design Name: 
// Module Name:    single_alu 
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
module single_alu(i_r, i_s, i_aluc, o_zf, o_alu);//single ALU
 input [31:0] i_r;
 input [31:0] i_s;
 input [2:0] i_aluc;
 output reg o_zf;
 output reg [31:0] o_alu;
 always @(i_aluc or i_r or i_s) begin
  case (i_aluc)
   3'b000: begin//AND
    o_zf = 0;
    o_alu = i_r & i_s;
   end
   3'b001: begin//OR
    o_zf = 0;
    o_alu = i_r | i_s;
   end
   3'b010: begin//ADD
    o_zf = 0;
    o_alu = i_r + i_s;
   end
   3'b110: begin//SUB
    o_alu = i_r - i_s;
    o_zf = (o_alu == 0);
   end
   3'b111: begin//SLT
    o_zf = 0;
    if (i_r < i_s)
     o_alu = 1;
    else
     o_alu = 0;
   end
   default: begin//reset
    o_alu = 0;
    o_zf = 0;
   end
  endcase
 end
endmodule
