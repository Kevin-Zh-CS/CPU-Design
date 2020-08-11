`timescale 1ns / 1ps

module regs(//input
				clk,rst,RegDst,RegWrite,MemtoReg,
				rs,rt,rd,ALUOut,MemContent,dbgReg,
				//output
				rsContent,rtContent,dbgContent
    );
	input clk,rst,RegDst,RegWrite,MemtoReg;
	input[4:0] rs,rt,rd,dbgReg;
	input[31:0] ALUOut,MemContent;
	output [31:0] rsContent,rtContent,dbgContent;
	
	reg[31:0] regFile[31:0];
	wire[4:0] RealRd;
	wire[31:0] WriteData;
	integer i;
	
	assign rsContent=regFile[rs];
	assign rtContent=regFile[rt];
	assign dbgContent=regFile[dbgReg];
	assign RealRd=(RegDst==0)?rd:rt;
	assign WriteData=(MemtoReg==0)?ALUOut:MemContent;
	
	initial begin
		for(i=0;i<32;i=i+1) regFile[i]<=0;
	end
	always@(posedge clk or posedge rst)
	begin
		if(rst==1) begin
			for(i=0;i<32;i=i+1) regFile[i]<=0;
		end
		else begin
			if((RealRd!=0)&&(RegWrite==1))
			regFile[RealRd]<=WriteData;
		end
	end

endmodule
