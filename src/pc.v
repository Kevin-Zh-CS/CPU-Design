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
	input[26:0] IR_low26;
	output[31:0] PCvalue;
	
	wire[31:0] nextPC;
	
	initial begin
		PCvalue=0;
	end
	
	always@(posedge clk or posedge rst)
	begin
		if(rst==1)
			PCvalue<=0;
		else
			PCvalue<=nextPC;
	end
	
	always@*
	begin
		if(PCWriteCond==1&&zero==1)
			nextPC=ALUOut;
		else if(PCWrite==1)
			begin
				case(PCSource)
				2'b00:nextPC=result;
				2'b10:nextPC={PCvalue[31:28],IR_low26,2'b00};
				endcase
			end
		else
			nextPC=PCvalue;
	end
	
endmodule
