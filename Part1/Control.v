module Control (
    input [5:0] OpCode,
    input Stall,
    output [1:0] WB, 
    output [1:0] M, 
    output [3:0] EX
);
    reg Reg_dst, Branch, Reg_w, ALU_src, Mem_w, Mem_r, Mem_to_reg, Jump;
    reg [1:0] ALU_op;
    assign WB = {Reg_w, Mem_to_reg};
    assign M = {Mem_w, Mem_r};
    assign EX = {Reg_dst, ALU_op, ALU_src};

    always @(*) begin
        if (Stall) begin // nop
            Reg_dst    <= 1'bx;
            Reg_w      <= 1'b0;
            ALU_src    <= 1'bx;
            Mem_w      <= 1'b0;
            Mem_r      <= 1'b0;
            Mem_to_reg <= 1'bx;
            ALU_op     <= 2'bxx;
        end
        else case (OpCode)
            6'b000000: begin // R type
                Reg_dst    <= 1'b1;
                Reg_w      <= 1'b1;
                ALU_src    <= 1'b0;
                Mem_w      <= 1'b0;
                Mem_r      <= 1'b0;
                Mem_to_reg <= 1'b0;
                ALU_op     <= 2'b10;
            end
            6'b001001: begin // addi
                Reg_dst    <= 1'b0;
                Reg_w      <= 1'b1;
                ALU_src    <= 1'b1;
                Mem_w      <= 1'b0;
                Mem_r      <= 1'b0;
                Mem_to_reg <= 1'b0;
                ALU_op     <= 2'b00;
            end
            6'b101011: begin // sw
                Reg_dst    <= 1'bx;
                Reg_w      <= 1'b0;
                ALU_src    <= 1'b1;
                Mem_w      <= 1'b1;
                Mem_r      <= 1'b0;
                Mem_to_reg <= 1'bx;
                ALU_op     <= 2'b00;
            end
            6'b100011: begin // lw
                Reg_dst    <= 1'b0;
                Reg_w      <= 1'b1;
                ALU_src    <= 1'b1;
                Mem_w      <= 1'b0;
                Mem_r      <= 1'b1;
                Mem_to_reg <= 1'b1;
                ALU_op     <= 2'b00;
            end
            6'b001101: begin // ori
                Reg_dst    <= 1'b0;
                Reg_w      <= 1'b1;
                ALU_src    <= 1'b1;
                Mem_w      <= 1'b0;
                Mem_r      <= 1'b0;
                Mem_to_reg <= 1'b0;
                ALU_op     <= 2'b11;
            end
            default: begin // nop
                Reg_dst    <= 1'bx;
                Reg_w      <= 1'b0;
                ALU_src    <= 1'bx;
                Mem_w      <= 1'b0;
                Mem_r      <= 1'b0;
                Mem_to_reg <= 1'bx;
                ALU_op     <= 2'bxx;
            end
        endcase
    end
endmodule