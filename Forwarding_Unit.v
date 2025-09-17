module Forwarding_Unit(
    input        regwrite_mem,
    input        regwrite_wb,
    input  [4:0] idex_regs,
    input  [4:0] idex_regt,
    input  [4:0] exmem_regd,
    input  [4:0] memwb_regd,
    output reg [1:0] forwarda,
    output reg [1:0] forwardb
);

always @(*) begin
    forwarda = 2'b00;
    forwardb = 2'b00;

    if (regwrite_mem && (exmem_regd != 0) && (exmem_regd == idex_regs))
        forwarda = 2'b01;
    else if (regwrite_wb && (memwb_regd != 0) && (memwb_regd == idex_regs))
        forwarda = 2'b10;

    if (regwrite_mem && (exmem_regd != 0) && (exmem_regd == idex_regt))
        forwardb = 2'b01;
    else if (regwrite_wb && (memwb_regd != 0) && (memwb_regd == idex_regt))
        forwardb = 2'b10;
end

endmodule
