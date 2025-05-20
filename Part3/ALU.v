module ALU (
    input [31:0] Src_1,
    input [31:0] Src_2,
    input [4:0] Shamt,
    input [1:0] Funct,
    output reg [31:0] ALU_result
);
    always @(*) begin
        case (Funct)
            2'b00: ALU_result <= Src_1 + Src_2;
            2'b01: ALU_result <= Src_1 - Src_2;
            2'b10: ALU_result <= Src_1 << Shamt;
            2'b11: ALU_result <= Src_1 | Src_2;
        endcase
    end
endmodule