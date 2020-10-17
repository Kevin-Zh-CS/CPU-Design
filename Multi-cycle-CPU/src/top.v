`timescale 1ns / 1ps

module top(
	input wire CLK_200M_P,
	input wire CLK_200M_N,		//时钟
	input wire RSTN,					//复位
	
	input [3:0] BTN_Y,				//按键输入
	input [15:0] SW,
	
	output readn,             		//三色led�
	output CR,							//三色信号�
	output RDY,							//三色信号�
	
	output [4:0] BTN_X,  	      //输出按键
	
	output wire led_clk,          //串行移位时钟
	output wire led_sout,         //串行输出
	output wire led_clrn,         //LED显示清零
	output wire LED_PEN,          //LED显示刷新使能

	output seg_clk,	//串行移位时钟
	output seg_sout,	//七段显示数据(串行输出)
	output SEG_PEN,	//七段码显示刷新使�
	output seg_clrn,	//七段码显示汪�;//显示7段码	
	
	output Buzzer
);
	reg[15:0] disp_num;
	wire[3:0] blink,dots;
	wire [3:0] BTN_OK;
	//wire [15:0]SW_OK,
	wire [31:0] P_Data;          //并行输入，用于串行输出数�
	wire [31:0] Div;
	wire clk;
	wire RegWrite,PCWrite,IRWrite,PCWriteCond,IorD;
	wire MemRead,MemWrite,MemtoReg,RegDst,ALUSrcA,ALUZero;
   wire[1:0] ALUSrcB,ALUOp,PCSource;
   wire[4:0] beat;
	wire[31:0] PC,IR,ALUOut,ALUResult,MemContent;
	wire[31:0] regAContent,regBContent,dbgContent;
	wire dbgclk,rst_cpu,clk_cpu;
	reg [3:0] BTN_cnt;
	
	clk_2to1 c0(CLK_200M_P,CLK_200M_N,RSTN,clk);
	
	clk_div U4(clk,rst,SW2,Div,Clk_CPU);//分频
	always @ (posedge clk_cpu or posedge rst_cpu) begin
		if (rst_cpu == 1) //BTN_cnt为时钟计�
			BTN_cnt = 4'b0;
		else begin
			BTN_cnt = BTN_cnt + 1;
		end
	end
	
	SAnti_jitter U1(clk,RSTN,readn,BTN_Y,BTN_X,Key_out,RDY,pulse_out,BTN_OK,SW_OK,CR,rst);
	assign dbgclk=BTN_OK[0];
	assign rst_cpu=BTN_OK[1];
	assign clk_cpu=(SW[7]==0)?dbgclk:clk; //选择自动时钟或手动时�
	
	SPIO U2(clk,rst,Div[20],1,P_Data,counter_set,LED_out,led_clk,led_sout,led_clrn,LED_PEN,GPIOf0);//显示led
	assign P_Data[17:2]={{8{0}},dbgclk,clk,rst_cpu,beat};//LED
	
	SSeg7_Dev U3(clk,rst,Div[20],1,Div[25],{16'h0000,disp_num},{4'b0000,dots},{4'b0000,blink},seg_clk,seg_sout,SEG_PEN,seg_clrn);//显示7段码
	always@* //根据拨动开关选择七段码的输出
	begin
		if(SW[6:5]==2'b00)begin
			disp_num[15:0]=dbgContent[15:0];
		end
		if(SW[6:5]==2'b01)begin
			disp_num[15:0]=dbgContent[31:16];
		end
		if(SW[6:5]==2'b10)begin
			disp_num[15:12]=BTN_cnt;
			case(IR[31:26])
			6'b000000:disp_num[11:8]=10;
			6'b101011:disp_num[11:8]=11;
			6'b100011:disp_num[11:8]=11;
			6'b000100:disp_num[11:8]=11;//BEQ指令应为I�
			6'b000010:disp_num[11:8]=12;
			endcase
			case(beat)
			5'b00001:disp_num[7:4]=0;
			5'b00010:disp_num[7:4]=1;
			5'b00100:disp_num[7:4]=2;
			5'b01000:disp_num[7:4]=3;
			5'b10000:disp_num[7:4]=4;
			endcase
			disp_num[3:0]=PC[3:0];
		end
	end
	
	assign Buzzer = 1;
	
	control x_control( //控制�
				.clk(clk_cpu),
				.rst(rst_cpu),
				.opcode(IR[31:26]),
				.RegWrite(RegWrite),
				.PCWrite(PCWrite),
				.IRWrite(IRWrite),
				.PCWriteCond(PCWriteCond),
				.IorD(IorD),
				.MemRead(MemRead),
				.MemWrite(MemWrite),
				.MemtoReg(MemtoReg),
				.RegDst(RegDst),
				.ALUSrcA(ALUSrcA),
				.ALUSrcB(ALUSrcB),
				.ALUOp(ALUOp),
				.PCSource(PCSource),
				.beat(beat)
				);
	
	memory x_memory( //内存读写
				.clk(clk_cpu),
				.MemRead(MemRead),
				.MemWrite(MemWrite),
				.IorD(IorD),
				.IRWrite(IRWrite),
				.PC(PC),
				.ALUOut(ALUOut),
				.wdata(regBContent),
				.dataout(MemContent),
				.IR(IR)
				);
	
	pc x_pc( //PC寄存器读�
			.clk(clk_cpu),
			.rst(rst_cpu),
			.PCWrite(PCWrite),
			.PCWriteCond(PCWriteCond),
			.PCSource(PCSource),
			.zero(ALUZero),
			.result(ALUResult),
			.ALUOut(ALUOut),
			.IR_low26(IR[25:0]),
			.PCvalue(PC)
			);
			
		
	alu x_alu( //ALU
				.clk(clk_cpu),
				.ALUOp(ALUOp),
				.ALUSrcA(ALUSrcA),
				.ALUSrcB(ALUSrcB),
				.funct(IR[5:0]),
				.PC(PC),
				.regA(regAContent),
				.regB(regBContent),
				.IR_low16(IR[15:0]),
				.result(ALUResult),
				.ALUOut(ALUOut),
				.zero(ALUZero)
				);
							
	regs x_regs( //寄存器组
				.clk(clk_cpu),
				.rst(rst_cpu),
				.RegDst(RegDst),
				.RegWrite(RegWrite),
				.MemtoReg(MemtoReg),
				.rs(IR[25:21]),
				.rt(IR[20:16]),
				.rd(IR[15:11]),
				.dbgReg(SW[4:0]),
				.ALUOut(ALUOut),
				.MemContent(MemContent),
				.rsContent(regAContent),
				.rtContent(regBContent),
				.dbgContent(dbgContent)
				);

endmodule
