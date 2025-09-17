module Decoder( 
    input  [5:0] instr_op_i,
    output reg [1:0] ALUOp_o,
    output reg       ALUSrc_o,
    output reg       RegWrite_o,	
    output reg       RegDst_o,
    output reg       Branch_o,
    output reg       MemRead_o, 
    output reg       MemWrite_o, 
    output reg       MemtoReg_o,
    output reg       BranchType_o   // 0: beq, 1: bne
);

always @(*) begin
    ALUOp_o     = 2'b00;
    ALUSrc_o    = 1'b0;
    RegWrite_o  = 1'b0;
    RegDst_o    = 1'b0;
    Branch_o    = 1'b0;
    MemRead_o   = 1'b0;
    MemWrite_o  = 1'b0;
    MemtoReg_o  = 1'b0;
    BranchType_o= 1'b0;

    case(instr_op_i)
        6'b000000: begin // R-type
            ALUOp_o    = 2'b10;
            ALUSrc_o   = 1'b0;
            RegWrite_o = 1'b1;
            RegDst_o   = 1'b1;
        end
        6'b101011: begin // lw
            ALUOp_o     = 2'b00;
            ALUSrc_o    = 1'b1;
            RegWrite_o  = 1'b1;
            RegDst_o    = 1'b0;
            MemRead_o   = 1'b1;
            MemtoReg_o  = 1'b1;
        end
        6'b100011: begin // sw
            ALUOp_o     = 2'b00;
            ALUSrc_o    = 1'b1;
            RegWrite_o  = 1'b0;
            RegDst_o    = 1'b0;
            MemWrite_o  = 1'b1;
        end
        6'b000101: begin // beq
            ALUOp_o      = 2'b01;
            ALUSrc_o     = 1'b0;
            RegWrite_o   = 1'b0;
            RegDst_o     = 1'b0;
            Branch_o     = 1'b1;
            BranchType_o = 1'b0; // beq
        end
        6'b000100: begin // bne
            ALUOp_o      = 2'b01;
            ALUSrc_o     = 1'b0;
            RegWrite_o   = 1'b0;
            RegDst_o     = 1'b0;
            Branch_o     = 1'b1;
            BranchType_o = 1'b1; // bne
        end
        6'b001000: begin // addi
            ALUOp_o     = 2'b00;
            ALUSrc_o    = 1'b1;
            RegWrite_o  = 1'b1;
            RegDst_o    = 1'b0;
        end
        default: begin
        end
    endcase
end

endmodule
