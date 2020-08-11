`timescale 1ns / 1ps

module top(
	input wire clk,				 	//时钟
	input wire RSTN,					//复位
	
	input [3:0] BTN_Y,				//按键输入
	input [7:0] SW,
	
	output readn,             		//三色led灯
	output CR,							//三色信号灯
	output RDY,							//三色信号灯
	
	output [4:0] BTN_X,  	      //输出按键
	
	output wire led_clk,          //串行移位时钟
	output wire led_sout,         //串行输出
	output wire led_clrn,         //LED显示清零
	output wire LED_PEN,          //LED显示刷新使能

	output seg_clk,	//串行移位时钟
	output seg_sout,	//七段显示数据(串行输出)
	output SEG_PEN,	//七段码显示刷新使能
	output seg_clrn,	//七段码显示汪零);//显示7段码	
	
	output Buzzer
);
	reg[15:0] disp_num;
	wire[3:0] blink,dots;
	wire [3:0] BTN_OK;
	//wire [15:0]SW_OK,
	wire [31:0] P_Data;          //并行输入，用于串行输出数据
	wire [31:0] Div;
	
	wire dbgclk,rst_cpu,dbg,DisChoose,DisReg,clk_cpu;
	SAnti_jitter U1(clk,RSTN,readn,BTN_Y,BTN_X,Key_out,RDY,pulse_out,BTN_OK,SW_OK,CR,rst);
	assign dbgclk=BTN_OK[0];
	assign rst_cpu=BTN_OK[1];
	assign dbg=SW[7];
	assign DisChoose=SW[6:5];
	assign DisReg=SW[4:0];
	assign clk_cpu=(dbg==0)?dbgclk:clk; //自动时钟或手动时钟
	
	wire [4:0]beat;
	SPIO U2(clk,rst,Div[20],1,P_Data,counter_set,LED_out,led_clk,led_sout,led_clrn,LED_PEN,GPIOf0);//显示led
	assign P_Data={dbgclk,clk,rst_CPU,beat,{2'b0}};
	
	reg[31:0] dbgContent;
	SSeg7_Dev U3(clk,rst,Div[20],1,Div[25],{16'h0000,disp_num},{4'b0000,dots},{4'b0000,blink},seg_clk,seg_sout,SEG_PEN,seg_clrn);//显示7段码
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
	
	clk_div U4(clk,rst,SW2,Div,Clk_CPU);//分频
	reg [3:0] BTN_cnt;//用来记录cpu时钟周期
	
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
