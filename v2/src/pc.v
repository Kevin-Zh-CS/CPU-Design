`timescale 1ns / 1ps

module pc(//input
			clk,rst,PCWrite,PCWriteCond,PCSource,
			zero,result,ALUOut,IR_low26,
			//output
			PCvalue
    );
	input clk,rst,PCWrite,PCWriteCond,zero;
	input[1:0] PCSource;
	input[31:0] result,ALUOut;
	input[25:0] IR_low26;
	output reg[31:0] PCvalue;
	
	reg[31:0] nextPC;
	
	initial begin
		PCvalue=2;
	end
	
	always@(posedge clk or negedge rst)
	begin
		if(!rst)
			PCvalue<=nextPC;
		else
			PCvalue<=0;			
	end
	
	always@*
	begin
		if(PCWriteCond==1&&zero==1)
			nextPC=ALUOut;
		else if(PCWrite==1)
			begin
				case(PCSource)
				2'b00:nextPC=result;
				2'b01:nextPC=ALUOut;
				2'b10:nextPC={PCvalue[31:28],IR_low26,2'b00};
				endcase
			end
		else
			nextPC=PCvalue;
	end
	
endmodule
