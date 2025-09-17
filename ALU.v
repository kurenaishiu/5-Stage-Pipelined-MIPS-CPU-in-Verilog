module ALU(
    input  [31:0] src1_i,
    input  [31:0] src2_i,
    input  [3:0]  ctrl_i,
    output reg [31:0] result_o,
    output        zero_o
);

always @(*) begin
    case(ctrl_i)
        4'b0010: result_o = src1_i + src2_i;   // ADD
        4'b0110: result_o = src1_i - src2_i;   // SUB
        4'b0000: result_o = src1_i & src2_i;   // AND
        4'b0001: result_o = src1_i | src2_i;   // OR
        4'b1100: result_o = ~(src1_i | src2_i);// NOR
        4'b0111: result_o = (src1_i < src2_i) ? 32'b1 : 32'b0; // SLT
        default: result_o = 32'b0;
    endcase
end

assign zero_o = (result_o == 0);

endmodule
