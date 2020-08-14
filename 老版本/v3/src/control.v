
`timescale 1ns / 1ps

//信号控制单元模块：ControlUnit
//输入：时钟信号clk，零标志位zero，符号位标志sign
//输出：各个控制信�
module control(
    input clk,
    input rst,
    input [5:0] opcode,
    //input zero,
    //input sign,
    output reg RegWrite,
    output reg PCWrite,
    output reg IRWrite,
    output reg PCWriteCond,
    output reg IorD,
    output reg MemRead,
    output reg MemWrite,
    output reg MemtoReg,
    output reg RegDst,
    output reg ALUSrcA,
    output reg [1:0] ALUSrcB,
    output reg [1:0] ALUOp,
    output reg [1:0] PCSource,
    output reg [4:0] beat
    //output reg [2:0] out_state
    );  
    //先将对应情况的阶段和对应情况的指令设置成常数方便进行编写代码
    parameter [3:0] s0=4'b0000, s1=4'b0001, s2=4'b0010, s3=4'b0011, s4=4'b0100, s5=4'b0101, s6=4'b0110, s7=4'b0111, s8=4'b1000, s9=4'b1001; 
    parameter [5:0] Rtype=6'b000000, SW=6'b101011, LW=6'b100011, BEQ=6'b000100, J=6'b000010, HALT=6'b111111; //指令名常�
    reg [3:0] state, next_state;    //state为当前所状处的状态，next_state是当前状态的下一个状�
    reg [31:0] count;
    
    //1.先对各个输出信号及当前阶段进行初始化（本部分待核查）
    initial begin
        RegWrite = 0;
        PCWrite = 0;
        IRWrite = 0;
        PCWriteCond = 0; 
        IorD = 0;
        MemRead = 0;
        MemWrite = 0;
        MemtoReg = 0;
        RegDst = 0;
        ALUSrcA = 0;
        ALUSrcB = 2'b00;
        ALUOp = 2'b00; 
        PCSource = 2'b00;
        beat = 5'b00000;
        count=32'h00000000;
		  state = s0;
			next_state = s0;
    end
    //2.D触发器模块：并行对当前阶段进行更�
    always @(posedge clk or posedge rst) begin 
	if(rst) state <= s0;
	else state <= next_state;
        //if(rst) begin
        //    state <= s0;
        //end
        //else begin 
        //    state <= next_state;
        //end  
            //out_state = state;  
    end  
    //3.阶段转移模块：�'定下一个阶�
    always @* begin
        case(state)
            //当前阶段：s0
            s0: begin
                beat = 5'b00001;
                PCWrite = 1;
                PCWriteCond = 0;
                IorD = 0;
                MemRead = 1;
                MemWrite = 0;
                IRWrite = 1;
                MemtoReg = 0;
                ALUSrcA = 0;
                RegWrite = 0;
                RegDst = 0;
                PCSource = 2'b00;
                ALUOp = 2'b00;
                ALUSrcB = 2'b01;
                next_state = s1;
                count=count+32'h00000001;
            end
            //当前阶段：s1
            s1: begin
                beat = 5'b00010;
                PCWrite = 0;
                PCWriteCond = 0;
                IorD = 0;
                MemRead = 0;
                MemWrite = 0;
                IRWrite = 0;
                MemtoReg = 0;
                ALUSrcA = 0;
                RegWrite = 0;
                RegDst = 0;
                PCSource = 2'b00;
                ALUOp = 2'b00;
                ALUSrcB = 2'b11;
                case(opcode)
                    LW: next_state = s2;
                    SW: next_state = s2;
                    Rtype: next_state = s6;
                    BEQ: next_state = s8;
                    J: next_state = s9;
                endcase
            end
            //当前阶段：s2
            s2: begin
                beat = 5'b00100;
                PCWrite = 0;
                PCWriteCond = 0;
                IorD = 0;
                MemRead = 0;
                MemWrite = 0;
                IRWrite = 0;
                MemtoReg = 0;
                ALUSrcA = 1;
                RegWrite = 0;
                RegDst = 0;
                PCSource = 2'b00;
                ALUOp = 2'b00;
                ALUSrcB = 2'b10;
                case(opcode)
                    LW: next_state = s3;
                    SW: next_state = s5;
                    default next_state = s2;
                endcase
            end
            //当前状态s3
            s3: begin
                beat = 5'b01000;
                PCWrite = 0;
                PCWriteCond = 0;
                IorD = 1;
                MemRead = 1;
                MemWrite = 0;
                IRWrite = 0;
                MemtoReg = 0;
                ALUSrcA = 0;
                RegWrite = 0;
                RegDst = 0;
                PCSource = 2'b00;
                ALUOp = 2'b00;
                ALUSrcB = 2'b00;
                next_state = s4;
            end
            //当前状态s4
            s4: begin
                beat = 5'b10000;
                PCWrite = 0;
                PCWriteCond = 0;
                IorD = 0;
                MemRead = 0;
                MemWrite = 0;
                IRWrite = 0;
                MemtoReg = 1;
                ALUSrcA = 0;
                RegWrite = 1;
                RegDst = 0;
                PCSource = 2'b00;
                ALUOp = 2'b00;
                ALUSrcB = 2'b00;
                next_state = s0;
            end
            //当前状态s5
            s5: begin
                beat = 5'b01000;
                PCWrite = 0;
                PCWriteCond = 0;
                IorD = 1;
                MemRead = 0;
                MemWrite = 1;
                IRWrite = 0;
                MemtoReg = 0;
                ALUSrcA = 0;
                RegWrite = 0;
                RegDst = 0;
                PCSource = 2'b00;
                ALUOp = 2'b00;
                ALUSrcB = 2'b00;
                next_state = s0;
            end
            //当前状态s6
            s6: begin
                beat = 5'b00100;
                PCWrite = 0;
                PCWriteCond = 0;
                IorD = 0;
                MemRead = 0;
                MemWrite = 0;
                IRWrite = 0;
                MemtoReg = 0;
                ALUSrcA = 1;
                RegWrite = 0;
                RegDst = 0;
                PCSource = 2'b00;
                ALUOp = 2'b10;
                ALUSrcB = 2'b00;
                next_state = s7;
            end
            //当前状态s7
            s7: begin
                beat = 5'b01000;
                PCWrite = 0;
                PCWriteCond = 0;
                IorD = 0;
                MemRead = 0;
                MemWrite = 0;
                IRWrite = 0;
                MemtoReg = 0;
                ALUSrcA = 0;
                RegWrite = 1;
                RegDst = 1;
                PCSource = 2'b00;
                ALUOp = 2'b00;
                ALUSrcB = 2'b00;
                next_state = s0;
            end
            //当前状态s8
            s8: begin
                beat = 5'b00100;
                PCWrite = 0;
                PCWriteCond = 1;
                IorD = 0;
                MemRead = 0;
                MemWrite = 0;
                IRWrite = 0;
                MemtoReg = 0;
                ALUSrcA = 1;
                RegWrite = 0;
                RegDst = 0;
                PCSource = 2'b01;
                ALUOp = 2'b01;
                ALUSrcB = 2'b00;
                next_state = s0;
            end
            //当前状态s9
            s9: begin
                beat = 5'b00100;
                PCWrite = 1;
                PCWriteCond = 0;
                IorD = 0;
                MemRead = 0;
                MemWrite = 0;
                IRWrite = 0;
                MemtoReg = 0;
                ALUSrcA = 0;
                RegWrite = 0;
                RegDst = 0;
                PCSource = 2'b10;
                ALUOp = 2'b00;
                ALUSrcB = 2'b00;
                next_state = s0;
            end
        endcase
    end    
endmodule
