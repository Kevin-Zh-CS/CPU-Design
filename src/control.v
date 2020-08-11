
`timescale 1ns / 1ps

//�źſ��Ƶ�Ԫģ�飺ControlUnit
//���룺ʱ���ź�clk�����־λzero������λ��־sign
//��������������ź�
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
    //�Ƚ���Ӧ����Ľ׶κͶ�Ӧ�����ָ�����óɳ���������б�д����
    parameter [2:0] s0=4'b0000, s1=4'b0001, s2=4'b0010, s3=4'b0011, s4=4'b0100, s5=4'b0101, s6=4'b0110, s7=4'b0111, s8=4'b1000, s9=4'b1001; 
    parameter [5:0] Rtype=6'b000000, SW=6'b101011, LW=6'b100011, BEQ=6'b000100, J=6'b000010, HALT=6'b111111; //ָ��������
    reg [2:0] state, next_state;    //stateΪ��ǰ��״����״̬��next_state�ǵ�ǰ״̬����һ��״̬
    reg [31:0] count;
    
    //1.�ȶԸ�������źż���ǰ�׶ν��г�ʼ���������ִ��˲飩
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
    end
    //2.D������ģ�飺���жԵ�ǰ�׶ν��и���
    always @(posedge clk or negedge rst) begin   
        if(rst == 0) begin
            state <= s0;
        end
        else begin 
            state <= next_state;
        end  
            out_state = state;  
    end  
    //3.�׶�ת��ģ�飺ȷ����һ���׶�
    always @(state or opcode) begin
        case(state)
            //��ǰ�׶Σ�s0
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
            //��ǰ�׶Σ�s1
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
            //��ǰ�׶Σ�s2
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
            //��ǰ״̬s3
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
            //��ǰ״̬s4
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
            //��ǰ״̬s5
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
            //��ǰ״̬s6
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
            //��ǰ״̬s7
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
            //��ǰ״̬s8
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
            //��ǰ״̬s9
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