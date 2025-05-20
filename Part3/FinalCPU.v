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
    assign Output_Addr = Input_Addr + 4;

    wire [31:0] IF_Instruction;

    reg [31:0] ID_Instruction;
    wire [5:0] ID_OpCode;
    wire [4:0] ID_RsAddr, ID_RtAddr; 
    wire [15:0] ID_imm;
    assign {ID_OpCode, ID_RsAddr, ID_RtAddr, ID_imm} = ID_Instruction;
    wire [1:0] ID_WB;
    wire [1:0] ID_M;
    wire [3:0] ID_EX;
    wire [31:0] ID_RsData;
    wire [31:0] ID_RtData;

    reg [1:0] EX_WB;
    reg [1:0] EX_M;
    wire EX_Mem_r; assign EX_Mem_r = EX_M[0];
    reg [3:0] EX_EX;
    wire [1:0] EX_ALU_op;
    assign {EX_Reg_dst, EX_ALU_op, EX_ALU_src} = EX_EX;
    reg [31:0] EX_RsData;
    reg [31:0] EX_RtData;
    reg [15:0] EX_imm;
    wire [4:0] EX_Shamt; assign EX_Shamt = EX_imm[10:6];
    wire [31:0] EX_imm_extend; assign EX_imm_extend = {16'b0, EX_imm};
    wire [5:0] EX_Funct_ctrl; assign EX_Funct_ctrl = EX_imm[5:0];
    reg [4:0] EX_RsAddr;
    reg [4:0] EX_RtAddr;
    wire [4:0] EX_RdAddr; assign EX_RdAddr = EX_imm[15:11];
    wire [31:0] EX_ALU_result;
    wire [31:0] EX_Mem_w_data;
    wire [31:0] EX_ALU_Src_1, EX_ALU_Src_2;
    assign EX_ALU_Src_1 = Forward_1_MEM ? MEM_ALU_result : 
        Forward_1_WB ? WB_RdData : EX_RsData;
    assign EX_Mem_w_data = Forward_2_MEM ? MEM_ALU_result : 
        Forward_2_WB ? WB_RdData : EX_RtData;
    assign EX_ALU_Src_2 = EX_ALU_src ? EX_imm_extend : EX_Mem_w_data;

    wire Forward_1_MEM = MEM_Reg_w && MEM_RdAddr != 0 && MEM_RdAddr == EX_RsAddr;
    wire Forward_2_MEM = MEM_Reg_w && MEM_RdAddr != 0 && MEM_RdAddr == EX_RtAddr;
    wire Forward_1_WB = WB_Reg_w && WB_RdAddr != 0 && WB_RdAddr == EX_RsAddr;
    wire Forward_2_WB = WB_Reg_w && WB_RdAddr != 0 && WB_RdAddr == EX_RtAddr;

    reg [1:0] MEM_WB;
    assign MEM_Reg_w = MEM_WB[1];
    reg MEM_M; 
    assign MEM_Mem_w = MEM_M;
    reg [31:0] MEM_ALU_result;
    reg [31:0] MEM_Mem_w_data;
    reg [4:0] MEM_RdAddr;
    wire [31:0] MEM_Mem_r_data;

    reg [1:0] WB_WB;
    assign {WB_Reg_w, WB_Mem_to_reg} = WB_WB;
    reg [31:0] WB_ALU_result;
    reg [31:0] WB_Mem_r_data;
    reg [4:0] WB_RdAddr;
    wire [31:0] WB_RdData;
    assign WB_RdData = WB_Mem_to_reg ? WB_Mem_r_data : WB_ALU_result;

    wire Stall;
    assign Stall = (EX_Mem_r && (
        EX_RtAddr == ID_RsAddr ||
        EX_RtAddr == ID_RtAddr
    ));
    wire IF_ID_write; assign IF_ID_write = !Stall;
    assign PC_Write = !Stall;

    initial begin
        {ID_Instruction, EX_WB, EX_M, EX_EX, EX_RtAddr, MEM_WB, MEM_M, WB_WB} <= 0;
    end

    always @(posedge clk) begin
        if (IF_ID_write) ID_Instruction <= IF_Instruction;
        EX_WB <= ID_WB;
        EX_M <= ID_M;
        EX_EX <= ID_EX;
        EX_RsData <= ID_RsData;
        EX_RtData <= ID_RtData;
        EX_RsAddr <= ID_RsAddr;
        EX_RtAddr <= ID_RtAddr;
        EX_imm <= ID_imm;

        MEM_WB <= EX_WB;
        MEM_M <= EX_M[1];
        MEM_ALU_result <= EX_ALU_result;
        MEM_Mem_w_data <= EX_Mem_w_data;
        MEM_RdAddr <= EX_Reg_dst ? EX_RdAddr : EX_RtAddr;

        WB_WB <= MEM_WB;
        WB_ALU_result <= MEM_ALU_result;
        WB_Mem_r_data <= MEM_Mem_r_data;
        WB_RdAddr <= MEM_RdAddr;
    end

	/* 
	 * Declaration of Instruction Memory.
	 * CAUTION: DONT MODIFY THE NAME.
	 */
	IM Instr_Memory(
        .Instr(IF_Instruction),
        .InstrAddr(Input_Addr)
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

    Control control(
        .OpCode(ID_OpCode),
        .Stall(Stall),
        .WB(ID_WB), 
        .M(ID_M), 
        .EX(ID_EX)
    );

    wire [1:0] Funct;
    ALU alu (
        .Src_1(EX_ALU_Src_1),
        .Src_2(EX_ALU_Src_2),
        .Shamt(EX_Shamt),
        .Funct(Funct),
        .ALU_result(EX_ALU_result)
    );

    ALU_Control aluControl(
        .Funct_ctrl(EX_Funct_ctrl),
        .ALU_op(EX_ALU_op),
        .Funct(Funct)
    );

endmodule
