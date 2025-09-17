module Hazard_Detection(
    input        memread,
    input [31:0] instr_i,
    input [4:0]  idex_regt,
    input        branch,
    output reg   pcwrite,
    output reg   ifid_write,
    output reg   ifid_flush,
    output reg   idex_flush,
    output reg   exmem_flush
);

wire [4:0] rs, rt;
assign rs = instr_i[25:21];
assign rt = instr_i[20:16];

always @(*) begin
    pcwrite    = 1'b1;
    ifid_write = 1'b1;
    ifid_flush = 1'b0;
    idex_flush = 1'b0;
    exmem_flush= 1'b0;

    if(memread && ((idex_regt == rs) || (idex_regt == rt))) begin
        pcwrite    = 1'b0;
        ifid_write = 1'b0;
        idex_flush = 1'b1;
    end

    if(branch) begin
        ifid_flush = 1'b1;
    end
end

endmodule
