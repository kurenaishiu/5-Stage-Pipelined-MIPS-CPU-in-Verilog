module ALU_Ctrl(
    input      [5:0] funct_i,
    input      [1:0] ALUOp_i,
    output reg [3:0] ALUCtrl_o
);

always @(*) begin
    case(ALUOp_i)
        2'b00: ALUCtrl_o = 4'b0010; // add
        2'b01: ALUCtrl_o = 4'b0110; // sub
        2'b10: begin
            case(funct_i)
                6'b100010: ALUCtrl_o = 4'b0010; // add
                6'b100000: ALUCtrl_o = 4'b0110; // sub
                6'b100101: ALUCtrl_o = 4'b0000; // and
                6'b100100: ALUCtrl_o = 4'b0001; // or
                6'b101010: ALUCtrl_o = 4'b1100; // nor
                6'b100111: ALUCtrl_o = 4'b0111; // slt
                default:   ALUCtrl_o = 4'b1111;
            endcase
        end
        default: ALUCtrl_o = 4'b1111;
    endcase
end

endmodule
