`timescale 1ns / 1ps

module memory(//input
				clk,osclk,MemRead,MemWrite,IorD,IRWrite,
				PC,ALUOut,wdata,
				//output
				dataout,IR
    );
	input osclk,clk,MemRead,MemWrite,IorD,IRWrite;
	input[31:0] PC,ALUOut,wdata;
	output[31:0] dataout;
	output reg[31:0] IR;
	
	wire[31:0] addr,insout;
	assign addr=(IorD==0)?PC:ALUOut;
	initial begin
		IR=0;
	end
	RAMIP ram(
			.clka(osclk),
			.addra(addr[8:0]),
			.dina(wdata),
			.douta(insout),
			.wea(MemWrite)
			);
	RAMIP wram(
			.clka(clk),
			.addra(addr[8:0]),
			.dina(wdata),
			.douta(dataout),
			.wea(1'b0)
			);
	always@(posedge clk)
	begin
		if(IRWrite==1)
			IR<=insout;
	end
endmodule
