`timescale 1ns / 1ps

module memory(//input
				clk,MemRead,MemWrite,IorD,IRWrite,
				PC,ALUOut,wdata,
				//output
				dataout,IR
    );
	input clk,MemRead,MemWrite,IorD,IRWrite;
	input[31:0] PC,ALUOut,wdata;
	output[31:0] dataout;
	output reg[31:0] IR;
	
	wire[31:0] addr;
	assign addr=(IorD==0)?PC:ALUOut;
	initial begin
		IR=5;
	end
	RAMIP ram(
			.clka(clk),
			.addra(addr[8:0]),
			.dina(wdata),
			.douta(dataout),
			.wea(MemWrite)
			);
			
	always@(posedge clk)
	begin
		if(IRWrite==1)
			IR<=dataout;
	end
endmodule
