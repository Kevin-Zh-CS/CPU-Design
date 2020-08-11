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
	reg[15:0] disp_num;
	wire[3:0] blink,dots;
	wire [3:0] BTN_OK;
	//wire [15:0]SW_OK,
	wire [31:0] P_Data;          //�������룬���ڴ����������
	wire [31:0] Div;
	
	wire dbgclk,rst_cpu,dbg,DisChoose,DisReg,clk_cpu;
	SAnti_jitter U1(clk,RSTN,readn,BTN_Y,BTN_X,Key_out,RDY,pulse_out,BTN_OK,SW_OK,CR,rst);
	assign dbgclk=BTN_OK[0];
	assign rst_cpu=BTN_OK[1];
	assign dbg=SW[7];
	assign DisChoose=SW[6:5];
	assign DisReg=SW[4:0];
	assign clk_cpu=(dbg==0)?dbgclk:clk; //�Զ�ʱ�ӻ��ֶ�ʱ��
	
	wire [4:0]beat;
	SPIO U2(clk,rst,Div[20],1,P_Data,counter_set,LED_out,led_clk,led_sout,led_clrn,LED_PEN,GPIOf0);//��ʾled
	assign P_Data={dbgclk,clk,rst_CPU,beat,{2'b0}};
	
	reg[31:0] dbgContent;
	SSeg7_Dev U3(clk,rst,Div[20],1,Div[25],{16'h0000,disp_num},{4'b0000,dots},{4'b0000,blink},seg_clk,seg_sout,SEG_PEN,seg_clrn);//��ʾ7����
	always@(posedge clk)
	begin
		disp_num[31:16]=16'b0;
		if(DisChoose==2'b00)begin
			disp_num[15:0]=dbgContent[15:0];
		end
		if(DisChoose==2'b01)begin
			disp_num[15:0]=dbgContent[31:16];
		end
		if(DisChoose==2'b10)begin
			disp_num[15:12]=BTN_cnt;
			case(IR[31:26])
			6'b000000:disp_num[11:8]=10;
			6'b101011:disp_num[11:8]=11;
			6'b100011:disp_num[11:8]=11;
			6'b000100:disp_num[11:8]=12;
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
	
	clk_div U4(clk,rst,SW2,Div,Clk_CPU);//��Ƶ
	reg [3:0] BTN_cnt;//������¼cpuʱ������
	
	always @ (posedge clk_cpu or posedge rst_cpu) begin
		if (rst_cpu == 1)
			BTN_cnt = 4'b0;
		else begin
			BTN_cnt = BTN_cnt + 1;
		end
	end
	
	assign Buzzer = 1;
	assign P_Data[9:2] = SW;
	assign {dots,blink}={SW[7:4],SW[3:0]};
	always @(posedge BTN_OK[3]) disp_num[3:0]<=disp_num[3:0]+1;
	always @(posedge BTN_OK[2]) disp_num[7:4]<=disp_num[7:4]+1;
	always @(posedge BTN_OK[1]) disp_num[11:8]<=disp_num[11:8]+1;
	always @(posedge BTN_OK[0]) disp_num[15:12]<=disp_num[15:12]+1;
endmodule
