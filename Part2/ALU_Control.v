module ALU_Control (
    input [5:0] Funct_ctrl,
    input [1:0] ALU_op,
    output reg [1:0] Funct
);
    always @(*) begin
        case (ALU_op)
            2'b00: Funct <= 2'b00; // sw, lw, addi
            2'b01: Funct <= 2'bxx;
            2'b10: case (Funct_ctrl) // R type
                6'b100001: Funct <= 2'b00; // add
                6'b100011: Funct <= 2'b01; // sub
                6'b000000: Funct <= 2'b10; // sll
                6'b100101: Funct <= 2'b11; // or
                default: Funct <= 2'bxx;
            endcase
            2'b11: Funct <= 2'b11; // ori
        endcase
    end
endmodule