module MUX_2to1 #(parameter WIDTH = 32) (
    input  [WIDTH-1:0] data0_i,
    input  [WIDTH-1:0] data1_i,
    input              select_i,
    output [WIDTH-1:0] data_o
);
assign data_o = (select_i) ? data1_i : data0_i;
endmodule

