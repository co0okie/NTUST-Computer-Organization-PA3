    /*
 *	Template for Project 3 Part 3
 *	Copyright (C) 2025 Xi Zhu Wang or any person belong ESSLab.
 *	All Right Reserved.
 *
 *	This program is free software: you can redistribute it and/or modify
 *	it under the terms of the GNU General Public License as published by
 *	the Free Software Foundation, either version 3 of the License, or
 *	(at your option) any later version.
 *
 *	This program is distributed in the hope that it will be useful,
 *	but WITHOUT ANY WARRANTY; without even the implied warranty of
 *	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *	GNU General Public License for more details.
 *
 *	You should have received a copy of the GNU General Public License
 *	along with this program.  If not, see <https://www.gnu.org/licenses/>.
 *
 *	This file is for people who have taken the cource (1132 Computer
 *	Organizarion) to use.
 *	We (ESSLab) are not responsible for any illegal use.
 *
 */

/*
 * Declaration of top entry for this project.
 * CAUTION: DONT MODIFY THE NAME AND I/O DECLARATION.
 */
module FinalCPU(
	// Outputs
	output        PC_Write,
	output [31:0] Output_Addr,
	// Inputs
	input  [31:0] Input_Addr,
	input         clk
);
    wire [7:0] Next_Addr = Input_Addr[7:0] + 4;
    assign Output_Addr = {Input_Addr[31:8], Next_Addr};

    wire [31:0] IF_Instruction;

    wire [5:0] ID_OpCode;
    wire [4:0] ID_RsAddr, ID_RtAddr; 
    wire [15:0] ID_imm;
    wire [1:0] ID_WB;
    wire [1:0] ID_M;
    wire [3:0] ID_EX;
    wire [31:0] ID_RsData;
    wire [31:0] ID_RtData;

    wire EX_Mem_r; 
    wire Stall;
    wire IF_ID_write = !Stall;
    assign PC_Write = !Stall;

    wire [1:0] EX_WB;
    wire [1:0] EX_M;
    wire [3:0] EX_EX;
    wire [1:0] EX_ALU_op;
    wire EX_Reg_dst, EX_ALU_src;
    wire [31:0] EX_RsData;
    wire [31:0] EX_RtData;
    wire [15:0] EX_imm;
    wire [4:0] EX_Shamt = EX_imm[10:6];
    wire [31:0] EX_imm_extend = {16'b0, EX_imm};
    wire [5:0] EX_Funct_ctrl = EX_imm[5:0];
    wire [4:0] EX_RsAddr;
    wire [4:0] EX_RtAddr;
    wire [4:0] EX_RdAddr = EX_imm[15:11];
    wire [31:0] EX_ALU_result;
    wire [31:0] EX_Mem_w_data;
    wire [31:0] EX_ALU_Src_1, EX_ALU_Src_2;

    wire Forward_1_MEM, Forward_2_MEM, Forward_1_WB, Forward_2_WB;

    wire [1:0] MEM_WB;
    wire MEM_Reg_w, MEM_Mem_to_reg;
    wire MEM_M; 
    wire MEM_Mem_w = MEM_M;
    wire [31:0] MEM_ALU_result;
    wire [31:0] MEM_Mem_w_data;
    wire [4:0] MEM_RdAddr;
    wire [31:0] MEM_Mem_r_data;
    wire [31:0] MEM_RdData;

    wire WB_Reg_w;
    wire [31:0] WB_ALU_result;
    wire [31:0] WB_Mem_r_data;
    wire [4:0] WB_RdAddr;
    wire [31:0] WB_RdData;

    assign Stall = (EX_Mem_r && (
        EX_RtAddr == ID_RsAddr ||
        EX_RtAddr == ID_RtAddr
    ));
    
    assign EX_Mem_r = EX_M[0];
    assign {EX_Reg_dst, EX_ALU_op, EX_ALU_src} = EX_EX;

    assign Forward_1_MEM = MEM_Reg_w && MEM_RdAddr != 0 && MEM_RdAddr == EX_RsAddr;
    assign Forward_2_MEM = MEM_Reg_w && MEM_RdAddr != 0 && MEM_RdAddr == EX_RtAddr;
    assign Forward_1_WB = WB_Reg_w && WB_RdAddr != 0 && WB_RdAddr == EX_RsAddr;
    assign Forward_2_WB = WB_Reg_w && WB_RdAddr != 0 && WB_RdAddr == EX_RtAddr;

    assign EX_ALU_Src_1 = Forward_1_MEM ? MEM_ALU_result : 
        Forward_1_WB ? WB_RdData : EX_RsData;
    assign EX_Mem_w_data = Forward_2_MEM ? MEM_ALU_result : 
        Forward_2_WB ? WB_RdData : EX_RtData;
    assign EX_ALU_Src_2 = EX_ALU_src ? EX_imm_extend : EX_Mem_w_data;

    assign {MEM_Reg_w, MEM_Mem_to_reg} = MEM_WB;
    assign MEM_RdData = MEM_Mem_to_reg ? MEM_Mem_r_data : MEM_ALU_result;

	/* 
	 * Declaration of Instruction Memory.
	 * CAUTION: DONT MODIFY THE NAME.
	 */
	IM Instr_Memory(
        .Instr(IF_Instruction),
        .InstrAddr(Input_Addr)
	);

    Pipeline_IF_ID pipline_IF_ID (
        .IF_ID_write(IF_ID_write),
        .IF_Instruction(IF_Instruction),
        .ID_Instruction({ID_OpCode, ID_RsAddr, ID_RtAddr, ID_imm}),
        .clk(clk)
    );

	/* 
	 * Declaration of Register File.
	 * CAUTION: DONT MODIFY THE NAME.
	 */
	RF Register_File(
        .RsData(ID_RsData),
        .RtData(ID_RtData),
        .RsAddr(ID_RsAddr),
        .RtAddr(ID_RtAddr),
        .RdAddr(WB_RdAddr),
        .RdData(WB_RdData),
        .RegWrite(WB_Reg_w),
        .clk(clk)
	);

    Control control(
        .OpCode(ID_OpCode),
        .Stall(Stall),
        .WB(ID_WB), 
        .M(ID_M), 
        .EX(ID_EX)
    );

    Pipeline_Register #(.size(98)) pipeline_ID_EX (
        .in({ID_WB, ID_M, ID_EX, ID_RsData, ID_RtData, ID_imm, ID_RsAddr, ID_RtAddr}),
        .out({EX_WB, EX_M, EX_EX, EX_RsData, EX_RtData, EX_imm, EX_RsAddr, EX_RtAddr}),
        .clk(clk)
    );

    wire [1:0] Funct;
    ALU_Control aluControl(
        .Funct_ctrl(EX_Funct_ctrl),
        .ALU_op(EX_ALU_op),
        .Funct(Funct)
    );

    ALU alu (
        .Src_1(EX_ALU_Src_1),
        .Src_2(EX_ALU_Src_2),
        .Shamt(EX_Shamt),
        .Funct(Funct),
        .ALU_result(EX_ALU_result)
    );

    Pipeline_Register #(.size(72)) pipeline_EX_MEM (
        .in({EX_WB, EX_M[1], EX_ALU_result, EX_Mem_w_data, EX_Reg_dst ? EX_RdAddr : EX_RtAddr}),
        .out({MEM_WB, MEM_M, MEM_ALU_result, MEM_Mem_w_data, MEM_RdAddr}),
        .clk(clk)
    );

	/* 
	 * Declaration of Data Memory.
	 * CAUTION: DONT MODIFY THE NAME.
	 */
	DM Data_Memory(
        .MemReadData(MEM_Mem_r_data),
        .MemAddr(MEM_ALU_result),
        .MemWriteData(MEM_Mem_w_data),
        .MemWrite(MEM_Mem_w),
        .clk(clk)
	);

    Pipeline_Register #(.size(38)) pipeline_MEM_WB (
        .in({MEM_Reg_w, MEM_RdData, MEM_RdAddr}),
        .out({WB_Reg_w, WB_RdData, WB_RdAddr}),
        .clk(clk)
    );
endmodule

module Pipeline_IF_ID (
    input IF_ID_write,
    input [31:0] IF_Instruction,
    output reg [31:0] ID_Instruction,
    input clk
);
    initial ID_Instruction <= 0;
    always @(posedge clk) if (IF_ID_write) ID_Instruction <= IF_Instruction;
endmodule

module Pipeline_Register #(
    parameter size = 1
) (
    input [size-1:0] in,
    output reg [size-1:0] out,
    input clk
);
    initial out <= 0;
    always @(posedge clk) out <= in;
endmodule