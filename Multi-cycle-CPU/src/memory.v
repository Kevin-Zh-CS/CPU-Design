`timescale 1ns / 1ps

module memory(//input
				clk,MemRead,MemWrite,IorD,IRWrite,
				PC,ALUOut,wdata,
				//output
				dataout,IR
    );
	input clk,MemRead,MemWrite,IorD,IRWrite;
	input[31:0] PC,ALUOut,wdata; //wdata为可能写入内存的数据
	output[31:0] dataout;
	output reg[31:0] IR;
	
	wire[31:0] addr;

	assign addr=(IorD==0)?PC:ALUOut; //选择内存访问地址
	initial begin
		IR=0;
	end
	ram ram(
			.clka(clk),
			.addra(addr[8:0]),
			.dina(wdata),
			.douta(dataout),
			.wea(MemWrite)
			);

	always@*
	begin
		if(IRWrite==1)
			IR<=dataout; //写IR寄存器
	end
endmodule
