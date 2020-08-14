`timescale 1ns / 1ps

module top(
	input wire clk,				 	//ʱ��
	input wire RSTN,					//��λ
	
	input [3:0] BTN_Y,				//��������
	input [7:0] SW,
	
	output readn,             		//��ɫled��
	output CR,							//��ɫ�źŵ�
	output RDY,							//��ɫ�źŵ�
	
	output [4:0] BTN_X,  	      //�������
	
	output wire led_clk,          //������λʱ��
	output wire led_sout,         //�������
	output wire led_clrn,         //LED��ʾ����
	output wire LED_PEN,          //LED��ʾˢ��ʹ��

	output seg_clk,	//������λʱ��
	output seg_sout,	//�߶���ʾ����(�������)
	output SEG_PEN,	//�߶�����ʾˢ��ʹ��
	output seg_clrn,	//�߶�����ʾ����);//��ʾ7����	
	
	output Buzzer
);
	reg[31:0] disp_num;
	wire[7:0] blink,dots;
	wire [3:0] BTN_OK;
	//wire [15:0]SW_OK,
	wire [31:0] P_Data;          //�������룬���ڴ����������
	wire [31:0] Div;
	
	wire RegWrite,PCWrite,IRWrite,PCWriteCond,IorD;
	wire MemRead,MemWrite,MemtoReg,RegDst,ALUSrcA,ALUZero;
   wire[1:0] ALUSrcB,ALUOp,PCSource;
   wire[4:0] beat;
	wire[31:0] PC,IR,ALUOut,ALUResult,MemContent;
	wire[31:0] regAContent,regBContent,dbgContent;
	wire dbgclk,rst_cpu,clk_cpu;
	reg [3:0] BTN_cnt;//������¼cpuʱ������
	
	clk_div U4(clk,rst,SW2,Div,Clk_CPU);//��Ƶ
	always @ (posedge clk_cpu or posedge rst_cpu) begin
		if (rst_cpu == 1)
			BTN_cnt = 4'b0;
		else begin
			BTN_cnt = BTN_cnt + 1;
		end
	end
	
	SAnti_jitter U1(clk,RSTN,readn,BTN_Y,BTN_X,Key_out,RDY,pulse_out,BTN_OK,SW_OK,CR,rst);
	assign dbgclk=BTN_OK[0];
	assign rst_cpu=BTN_OK[1];
	assign clk_cpu=(SW[7]==0)?dbgclk:clk; //�Զ�ʱ�ӻ��ֶ�ʱ��
	
	SPIO U2(clk,rst,Div[20],1,P_Data,counter_set,LED_out,led_clk,led_sout,led_clrn,LED_PEN,GPIOf0);//��ʾled
	assign P_Data[17:2]={{8{0}},dbgclk,clk,rst_cpu,beat};
	
	SSeg7_Dev U3(clk,rst,Div[20],1,Div[25],disp_num,dots,blink,seg_clk,seg_sout,SEG_PEN,seg_clrn);//��ʾ7����
	always@*
	begin
		if(SW[6:5]==2'b00)begin
			disp_num[31:0]=dbgContent[31:0];
		end
		if(SW[6:5]==2'b01)begin
			case(SW[4])
			1'b0:disp_num[31:0]=IR;
			1'b1:disp_num[31:0]=PC;
			endcase
		end
		if(SW[6:5]==2'b10)begin
			disp_num[15:12]=BTN_cnt;
			case(IR[31:26])
			6'b000000:disp_num[11:8]=10;
			6'b101011:disp_num[11:8]=11;
			6'b100011:disp_num[11:8]=11;
			6'b000100:disp_num[11:8]=12;
			6'b000010:disp_num[11:8]=12;
			default:disp_num[11:8]=4;
			endcase
			case(beat)
			5'b00001:disp_num[7:4]=0;
			5'b00010:disp_num[7:4]=1;
			5'b00100:disp_num[7:4]=2;
			5'b01000:disp_num[7:4]=3;
			5'b10000:disp_num[7:4]=4;
			default:disp_num[7:4]=5;
			endcase
			disp_num[3:0]=PC[3:0];
		end
		if(SW[6:5]==2'b11) begin
			case(SW[4])
			1'b0:disp_num[31:0]=ALUResult;
			1'b1:disp_num[31:0]=ALUOut;
			endcase
		end
	end
	
	assign Buzzer = 1;
	
	control x_control(
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
	
	memory x_memory(
				.clk(clk_cpu),
				.osclk(clk),
				.MemRead(MemRead),
				.MemWrite(MemWrite),
				.IorD(IorD),
				.IRWrite(IRWrite),
				.PC(PC),
				.ALUOut(ALUOut),
				.wdata(rtContent),
				.dataout(MemContent),
				.IR(IR)
				);
	
	pc x_pc(
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
			
		
	alu x_alu(
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
							
	regs x_regs(
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
