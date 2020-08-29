`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:09:05 07/08/2020 
// Design Name: 
// Module Name:    single_alu_ctrl 
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

module single_alu_ctrl(aluop, func, alu_ctrl);//single ALU ctrl
 input [1:0] aluop;
 input [5:0] func;
 output reg [2:0] alu_ctrl;
 always @(aluop or func) begin
  case(aluop)
   2'b00: begin
    alu_ctrl = 3'b010;//ADD
   end
   2'b01: begin
    alu_ctrl = 3'b110;//SUB
   end
   2'b10: begin
    case(func)
     6'b100000: alu_ctrl = 3'b010;//ADD
     6'b100010: alu_ctrl = 3'b110;//SUB
     6'b101010: alu_ctrl = 3'b111;//SLT
     6'b100100: alu_ctrl = 3'b000;//AND
     6'b100101: alu_ctrl = 3'b001;//OR
     default: alu_ctrl = 3'b000;//ADD
    endcase
   end
   default: begin
    alu_ctrl = 3'b000;//ADD
   end
  endcase
 end
endmodule
