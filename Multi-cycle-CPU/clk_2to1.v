`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:25:20 10/17/2020 
// Design Name: 
// Module Name:    clk_2to1 
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
module clk_2to1(input clk200P,clk200N,rst,output clk);
	IBUFDS sclk(.I(clk200P),
		.IB(clk200N),
		.O(clk));
endmodule

