module Shift_Left_Two_32(
    input  [31:0] data_i,
    output [31:0] data_o
);

assign data_o = data_i << 2;

endmodule
