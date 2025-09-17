`include "Adder.v"
`include "ALU_Ctrl.v"
`include "ALU.v"
`include "Data_Memory.v"
`include "Decoder.v"
`include "Forwarding_Unit.v"
`include "Hazard_Detection.v"
`include "Instruction_Memory.v"
`include "MUX_2to1.v"
`include "MUX_3to1.v"
`include "Reg_File.v"
`include "Shift_Left_Two_32.v"
`include "Sign_Extend.v"
`include "Pipe_Reg.v"
`include "ProgramCounter.v"

`timescale 1ns / 1ps

module Pipe_CPU_PRO(
    clk_i,
    rst_i
);
    
input clk_i;
input rst_i;

//############## IF stage ############################
wire [31:0] pc_current;
wire [31:0] pc_next;
wire [31:0] instruction;
wire [31:0] pc_plus4;
wire        pcwrite;      
wire        ifid_write;   
wire        ifid_flush;   

assign pc_next = mem_taken ? mem_branch_target : pc_plus4;
wire hazard_ifid_flush;
wire hazard_idex_flush;
assign ifid_flush = hazard_ifid_flush | mem_taken;
assign idex_flush = hazard_idex_flush | mem_taken;

ProgramCounter PC(
    .clk_i(clk_i),
    .rst_i(rst_i),
    .pc_in_i(pc_next),
    .pc_out_o(pc_current),
    .pc_write(pcwrite)
);

Instruction_Memory IM(
    .addr_i(pc_current),
    .instr_o(instruction)
);

Adder PC_Plus4(
    .src1_i(pc_current),
    .src2_i(32'd4),
    .sum_o(pc_plus4)
);

Pipe_Reg #(.size(64)) IF_ID (
    .clk_i(clk_i),
    .rst_i(rst_i),
    .flush(ifid_flush),
    .write(ifid_write),
    .data_i({pc_plus4, instruction}),
    .data_o({id_pc_plus4, id_instruction})
);

// ######### ID stage ########################
wire [31:0] id_pc_plus4;       
wire [31:0] id_instruction;    

wire [1:0]  id_aluop;
wire        id_alusrc;
wire        id_regwrite;
wire        id_regdst;
wire        id_branch;
wire        id_memread;
wire        id_memwrite;
wire        id_memtoreg;
wire        id_branchtype;

wire [31:0] id_regdata1;
wire [31:0] id_regdata2;
wire [4:0]  id_rs;  
wire [4:0]  id_rt;  
wire [4:0]  id_rd;  

wire [31:0] id_signimm;

wire        idex_flush;

wire [31:0] ex_pc_plus4;
wire [31:0] ex_regdata1;
wire [31:0] ex_regdata2;
wire [31:0] ex_signimm;
wire [4:0]  ex_rs;
wire [4:0]  ex_rt;
wire [4:0]  ex_rd;
wire [1:0]  ex_aluop;
wire        ex_alusrc;
wire        ex_regwrite;
wire        ex_regdst;
wire        ex_branch;
wire        ex_memread;
wire        ex_memwrite;
wire        ex_memtoreg;
wire        ex_branchtype;

assign id_rs = id_instruction[25:21];
assign id_rt = id_instruction[20:16];
assign id_rd = id_instruction[15:11];

Decoder decoder(
    .instr_op_i(id_instruction[31:26]),
    .ALUOp_o(id_aluop),
    .ALUSrc_o(id_alusrc),
    .RegWrite_o(id_regwrite),
    .RegDst_o(id_regdst),
    .Branch_o(id_branch),
    .MemRead_o(id_memread),
    .MemWrite_o(id_memwrite),
    .MemtoReg_o(id_memtoreg),
    .BranchType_o(id_branchtype)
);

Reg_File RF(
    .clk_i(clk_i),
    .rst_i(rst_i),
    .RSaddr_i(id_rs),
    .RTaddr_i(id_rt),
    .RDaddr_i(wb_rd),         
    .RDdata_i(wb_writedata),  
    .RegWrite_i(wb_regwrite), 
    .RSdata_o(id_regdata1),
    .RTdata_o(id_regdata2)
);

Sign_Extend sign_ext(
    .data_i(id_instruction[15:0]),
    .data_o(id_signimm)
);

Hazard_Detection hazard(
    .memread(ex_memread),      
    .instr_i(id_instruction),
    .idex_regt(ex_rt),         
    .branch(id_branch),
    .pcwrite(pcwrite),
    .ifid_write(ifid_write),
    .ifid_flush(hazard_ifid_flush),
    .idex_flush(hazard_idex_flush),
    .exmem_flush(exmem_flush) 
);

Pipe_Reg #(.size(159)) ID_EX (
    .clk_i(clk_i),
    .rst_i(rst_i),
    .flush(idex_flush),
    .write(1'b1),
    .data_i({id_pc_plus4, id_regdata1, id_regdata2, id_signimm, id_rs, id_rt, id_rd, id_instruction[5:0], id_aluop, id_alusrc, id_regwrite, id_regdst, id_branch, id_memread, id_memwrite, id_memtoreg, id_branchtype}),
    .data_o({ex_pc_plus4, ex_regdata1, ex_regdata2, ex_signimm, ex_rs, ex_rt, ex_rd, ex_funct, ex_aluop, ex_alusrc, ex_regwrite, ex_regdst, ex_branch, ex_memread, ex_memwrite, ex_memtoreg, ex_branchtype})
);

// ######## EX stage ###########################
wire [1:0]  forwarda;
wire [1:0]  forwardb;
wire [31:0] alu_in1;
wire [31:0] alu_in2;
wire [31:0] alu_src2;
wire [3:0]  ex_aluctrl;
wire [31:0] alu_result;
wire        alu_zero;
wire [31:0] ex_branch_target;
wire [4:0]  ex_dst;
wire [31:0] mem_pc_plus4;
wire        mem_zero;
wire [31:0] mem_alu_result;
wire [31:0] mem_regdata2;
wire [4:0]  mem_dst;
wire        mem_regwrite;
wire        mem_memread;
wire        mem_memwrite;
wire        mem_memtoreg;
wire        mem_branch;
wire        mem_branchtype;
wire        exmem_flush;
wire [5:0]  ex_funct;

Forwarding_Unit forward_unit(
    .regwrite_mem(mem_regwrite),
    .regwrite_wb(wb_regwrite),
    .idex_regs(ex_rs),
    .idex_regt(ex_rt),
    .exmem_regd(mem_dst),
    .memwb_regd(wb_rd),
    .forwarda(forwarda),
    .forwardb(forwardb)
);

MUX_3to1 mux_alu_in1(
    .data0_i(ex_regdata1),    
    .data1_i(mem_alu_result), 
    .data2_i(wb_writedata),   
    .select_i(forwarda),
    .data_o(alu_in1)
);

MUX_3to1 mux_alu_in2(
    .data0_i(ex_regdata2),
    .data1_i(mem_alu_result),
    .data2_i(wb_writedata),
    .select_i(forwardb),
    .data_o(alu_in2)
);

MUX_2to1 mux_alusrc(
    .data0_i(alu_in2),
    .data1_i(ex_signimm),
    .select_i(ex_alusrc),
    .data_o(alu_src2)
);

ALU_Ctrl alu_ctrl(
    .funct_i(ex_funct), 
    .ALUOp_i(ex_aluop),
    .ALUCtrl_o(ex_aluctrl)
);

ALU alu(
    .src1_i(alu_in1),
    .src2_i(alu_src2),
    .ctrl_i(ex_aluctrl),
    .result_o(alu_result),
    .zero_o(alu_zero)
);

wire [31:0] ex_signimm_shifted;
Shift_Left_Two_32 shift_left2(
    .data_i(ex_signimm),
    .data_o(ex_signimm_shifted)
);
Adder branch_addr_adder(
    .src1_i(ex_pc_plus4),
    .src2_i(ex_signimm_shifted),
    .sum_o(ex_branch_target)
);

MUX_2to1 #(.WIDTH(5)) mux_regdst(
    .data0_i(ex_rt),
    .data1_i(ex_rd),
    .select_i(ex_regdst),
    .data_o(ex_dst)
);

Pipe_Reg #(.size(32+32+32+32+1+5+1+1+1+1+1+1)) EX_MEM (
    .clk_i(clk_i),
    .rst_i(rst_i),
    .flush(exmem_flush),
    .write(1'b1),
    .data_i({ex_pc_plus4, alu_result, alu_in2, ex_branch_target, alu_zero, ex_dst, ex_regwrite, ex_memread, ex_memwrite, ex_memtoreg, ex_branch, ex_branchtype}),
    .data_o({mem_pc_plus4, mem_alu_result, mem_regdata2, mem_branch_target, mem_zero, mem_dst, mem_regwrite, mem_memread, mem_memwrite, mem_memtoreg, mem_branch, mem_branchtype})
);


// ######### MEM stage ###################
wire [31:0] mem_branch_target; 
wire [31:0] mem_readdata;     
wire        mem_taken;        
wire        mem_flush;        
wire [31:0] wb_pc_plus4;
wire [31:0] wb_memdata;
wire [31:0] wb_alu_result;
wire [4:0]  wb_dst;
wire        wb_memtoreg;
wire [31:0] mem_addr_word;
assign mem_addr_word = mem_alu_result;
assign mem_taken = (mem_branch && (
                        (mem_branchtype == 1'b0 && mem_zero) ||
                        (mem_branchtype == 1'b1 && ~mem_zero)    
                    ));

Data_Memory DM(
    .clk_i(clk_i),
    .addr_i(mem_addr_word),
    .data_i(mem_regdata2),
    .MemRead_i(mem_memread),
    .MemWrite_i(mem_memwrite),
    .data_o(mem_readdata)
);

Pipe_Reg #(.size(32+32+32+5+1+1)) MEM_WB (
    .clk_i(clk_i),
    .rst_i(rst_i),
    .flush(1'b0),
    .write(1'b1),
    .data_i({mem_pc_plus4, mem_readdata, mem_alu_result, mem_dst, mem_regwrite, mem_memtoreg}),
    .data_o({wb_pc_plus4, wb_memdata, wb_alu_result, wb_dst, wb_regwrite, wb_memtoreg})
);

// ########## WB stage #######################
wire [4:0]  wb_rd;
wire [31:0] wb_writedata;
wire        wb_regwrite;

MUX_2to1 mux_memtoreg(
    .data0_i(wb_alu_result),
    .data1_i(wb_memdata),
    .select_i(wb_memtoreg),
    .data_o(wb_writedata)
);

assign wb_rd = wb_dst;

endmodule