`timescale 1ns / 1ps

module alu(//input
				clk,ALUOp,ALUSrcA,ALUSrcB,funct,
				PC,regA,regB,IR_low16,
				//output
				result,ALUOut,zero
    );
	input[1:0] ALUOp;
	input ALUSrcA;
	input[1:0] ALUSrcB;
	input[5:0] funct;
	input[31:0] PC,regA,regB;
	input[15:0] IR_low16;
	
	output reg[31:0] result,ALUOut;
	output reg zero;
	
	reg[31:0] A;
	reg[31:0] B;
	wire[31:0] ext;
	wire[31:0] ext2;
	
	initial begin
		result=0;
	end
	
	assign ext={{16{IR_low16[15]}},IR_low16[15:0]};
	assign ext2={{14{IR_low16[15]}},IR_low16[15:0],2'b00};
	always@*
	begin
		A=(ALUSrcA==0)?PC:regA;
		case(ALUSrcB)
			2'b00:B=regB;
			2'b01:B=4;
			2'b10:B=ext;
			2'b11:B=ext2;
		endcase
		case(ALUOp)
			2'b00:result=A+B;
			2'b01:result=A-B;
			2'b10:
				case(funct)
					6'b100000:result=A+B;
					6'b100010:result=A-B;
					6'b100100:result=A&B;
					6'b100101:result=A|B;
					6'b100111:result=~(A|B);
				endcase
		endcase
		zero=(result==0)?1:0;
	end
	
	always@(posedge clk)
	begin
		ALUOut<=result;
	end
	
endmodule
