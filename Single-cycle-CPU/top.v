`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:45:15 07/08/2020 
// Design Name: 
// Module Name:    top 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

`timescale 1 ps / 1 ps
//顶层模块
module top(
	input wire clk,				 	//时钟
	input wire RSTN,					//复位
	input [6:0] SW,
	input [3:0] BTN_Y,				//按键输入
	
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
	
	output wire [4:0]LED
	
);

	reg[31:0] disp_num;
	wire[7:0] blink,dots;
	wire [3:0] BTN_OK;
	//wire [15:0]SW_OK,
	wire [31:0] P_Data;          //并行输入，用于串行输出数据
	wire [31:0] Div;
	wire rst_cpu;
	
	assign rst_cpu=BTN_OK[1];
	
	clk_div x_clk_div(clk,rst,SW2,Div,Clk_CPU);//分频
	
	SAnti_jitter x_SAnti_jitter(clk,RSTN,readn,BTN_Y,BTN_X,Key_out,RDY,pulse_out,BTN_OK,SW_OK,CR,rst);//按键
	
	SPIO x_SPIO(clk,rst,Div[20],1,P_Data,counter_set,LED_out,led_clk,led_sout,led_clrn,LED_PEN,GPIOf0);//显示led
	
	SSeg7_Dev x_SSeg7_Dev(clk,rst,Div[20],1,Div[25],disp_num,dots,blink,seg_clk,seg_sout,SEG_PEN,seg_clrn);//显示7段码
	
	
	
	reg [15:0] BTN_cnt;//用来记录cpu时钟周期
	
	always @ (posedge BTN_OK[0] or posedge rst_cpu) begin
		if (rst_cpu == 1)
			BTN_cnt = 16'h0000;
		else begin
			BTN_cnt = BTN_cnt + 1;
		end
	end
	

wire [8:0] pc_out, pc_in, pc_plus_4;
 wire [4:0] reg3_out,
      tmp_sel;	
	
wire [31:0] wdata_out,
     instr_out,
     reg1_dat, reg2_dat,
     signext_out,
     mux_to_alu,
     alu_out,
     mem_dat_out,
     branch_addr_out,
     branch_mux_out,
     gpr_disp_out;
 wire [1:0] aluop;
 wire [2:0] alu_ctrl;
 wire regwrite, alusrc, memwrite, memtoreg, memread, branch, jump, regdst, alu_zero, and_out;


//assign LED[5:0]=instr_out[31:26];
//assign LED[7:6]=instr_out[1:0];


assign LED[0]=regdst;
assign LED[1]=memread;
assign LED[2]=memwrite;
assign LED[3]=branch;
assign LED[4]=jump;
//assign LED[5]=regwrite;


assign tmp_sel[4:0] = SW[4:0];	


 

always @(posedge clk) begin
	disp_num[31:16]=16'b0;
	if(SW[6:5]==2'b00) begin
		disp_num[15:0]=gpr_disp_out[15:0];
	end
	if(SW[6:5]==2'b01) begin
		disp_num[15:0]=gpr_disp_out[31:16];
	end
	if(SW[6:5]==2'b10) begin
		disp_num[15:0]={{7'b0},pc_out};
	end
	if(SW[6:5]==2'b11) begin
		disp_num[15:0]=BTN_cnt;
	end
end



 //PC register
 single_pc x_single_pc(BTN_OK[0], rst_cpu, pc_in, pc_out);
 
 
 //PC plus 4
 single_pc_plus_4 x_single_pc_plus4(pc_out, pc_plus_4);
 
 
 //intruction memory, read only. read address from PC's output
 instr_block x_instr_block(.addra(pc_out), .clka(clk), .douta(instr_out));

 
 //mux5, select from [20:16] or [15:11], to register file's write port
 single_mux5 x_single_mux5(instr_out[20:16],instr_out[15:11],
 regdst, reg3_out);
 
 
 //register files, read from 3 ports, write to 1 port
 single_gpr x_single_gpr(
  BTN_OK[0], rst_cpu,
  instr_out[25:21], instr_out[20:16],
  tmp_sel,
  reg3_out, wdata_out,
  regwrite,
  reg1_dat, reg2_dat,
  gpr_disp_out);
  
  
  
 //ALU ctrl
 single_alu_ctrl x_single_alu_ctrl(aluop,  instr_out[5:0],alu_ctrl);
 
 
 
 //16 to 32 extension
 single_signext x_single_signext(instr_out[15:0], signext_out);
 
 
 //mux32,to ALU B-port input(mux to alu)
 single_mux32 x_single_mux32(reg2_dat, signext_out, alusrc, mux_to_alu);
 
 
 //ALU
 single_alu x_single_alu(reg1_dat, mux_to_alu, alu_ctrl, alu_zero, alu_out);
 

 //data memory, r/w
 dat_block x_dat_block(
  .addra(alu_out[8:0]),
  .clka(clk),
  .dina(reg2_dat),
  .douta(mem_dat_out),
  .wea(memwrite)
  );
  
  //.addra(bg1),.douta(spob0),.clka(clkdiv[1])
 //mux32, select from ALU or Memory 's output, to Register files' write  port
 single_mux32 x_single_mux32_2(alu_out, mem_dat_out, memtoreg, wdata_out);
 
 
 //and gate, zero and branch signal for BEQ
 and x_and(and_out, alu_zero, branch);
 
 
 //ADD, add PC+4 and immediate number for BEQ's address transition
 single_add  x_single_add(signext_out, {{23'b000_0000_0000_0000_0000_0000},pc_plus_4},branch_addr_out);
 
 
 //mux32,ctrl is the output of and gate, determine whether use the BEQ transition address,(branch mux out)
 single_mux32 x_single_mux_32_3({23'b000_0000_0000_0000_0000_0000,pc_plus_4}, branch_addr_out, and_out, branch_mux_out);
 
 
 //mux9, jump selection, to pc_in
 single_mux9 x_single_mux9(branch_mux_out[8:0], instr_out[8:0], jump, pc_in);
 
  
 //CPU controllor
 single_ctrl x_single_ctrl( instr_out[31:26], aluop, regdst, regwrite,branch,jump,memtoreg,memread,memwrite,alusrc,rst_cpu);
 
 
 
endmodule
