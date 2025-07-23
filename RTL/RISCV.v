`timescale 1ns/1ps
`include "constants.v"
`include "IF.v"
`include "OF.v"
`include "EX.v"
`include "MA.v"
`include "RW.v"
`include "stall.v"



module RISC_V(clk1,clk2,rst);
input clk1,clk2,rst;

parameter dly = 2 ;


//system memory and registers

reg [31:0] regfile [31:0] ; //32 registers
reg [31:0] PC;

initial begin
PC <= 32'b0 ;
end


//wires and regs
reg [31:0] inst ;
wire EX_isBranchTaken ; //is reg for testing only
wire [31:0] EX_branchPC,IF_PC,IF_instruction;
wire [31:0] newpc ;

wire [4:0] regfile_addr1,regfile_addr2 ;
wire [31:0] OF_immx ;
wire [31:0] op1,op2 ;
reg [31:0] OF_op1,OF_op2 ;
wire [31:0] OF_instruction,OF_PC ;
wire [31:0] EX_instruction,EX_PC,EX_aluresult,EX_op2,EX_op1 ;
wire [31:0] MA_ldresult,MA_aluresult,MA_instruction,MA_pc ;
wire RW_isWB ;
wire [31:0] RW_reg_addr,RW_reg_data ;

//wires and regs for hazard unit
reg flush;  //for flushing in case of control hazards
wire [31:0] f_ldresult ;//ld result is forwarded to different stages for RW-MA ,RW-EX and RW-OF 
wire [31:0] mux_rw_ma_op2 ;
wire [31:0] f_aluresult,mux_ma_ex_op1,mux_ma_ex_op2 ;
wire [31:0] mux_rw_ex_op1 ,mux_rw_ex_op2 ;
wire [5:1]stall ; // stall signal across various stages



//FLUSH MODULE - to flush the pipeline in case of control hazard
always @(posedge clk1 or posedge rst) begin
if (rst) begin flush <= 0; 
// stall<= 0;
 end
else flush <= EX_isBranchTaken ;
end



stall_logic_ld_use_hazard s1(clk1,rst,IF_instruction,OF_instruction,stall);






//IF STAGE
IF_STAGE if_module ( stall[1],rst ,clk1,EX_isBranchTaken,PC,EX_branchPC,IF_PC,IF_instruction,newpc) ;
always @(posedge clk1)begin
    if(~stall[1])begin
PC <= newpc ;
    end
end

//OF STAGE
OF_STAGE of_module(stall[2],rst,clk2,
flush,
IF_PC,IF_instruction,regfile_addr1,regfile_addr2,OF_immx,OF_isImm,OF_PC,OF_instruction) ;

assign op1 = (MA_instruction[11:7] == regfile_addr1) & (MA_instruction[6:0] == `I_type_ld ) ? f_ldresult : regfile[regfile_addr1] ; 
assign op2 = (MA_instruction[11:7] == regfile_addr2) & (MA_instruction[6:0] == `I_type_ld ) ? f_ldresult : regfile[regfile_addr2] ;

always @(posedge clk2)begin
    if(~stall[2])begin
    OF_op1 <= op1 ;
    OF_op2 <= op2 ;
end
end
//EX STAGE


assign mux_ma_ex_op1 = (EX_instruction[11:7] == OF_instruction[19:15]) & ((EX_instruction[6:0] == `R_type) | (EX_instruction[6:0] == `I_type_alu) | (EX_instruction[6:0] == `U_type_auipc) | ((EX_instruction[6:0] == `U_type_lui)) ) ? f_aluresult :(MA_instruction[11:7] == OF_instruction[19:15] )& (MA_instruction[6:0] == `I_type_ld)? f_ldresult: OF_op1 ;
assign mux_ma_ex_op2 = (EX_instruction[11:7] == OF_instruction[24:20]) & ((EX_instruction[6:0] == `R_type) | (EX_instruction[6:0] == `I_type_alu) | (EX_instruction[6:0] == `U_type_auipc) | ((EX_instruction[6:0] == `U_type_lui)) ) ? f_aluresult :(MA_instruction[11:7] == OF_instruction[24:20] )& (MA_instruction[6:0] == `I_type_ld)? f_ldresult: OF_op2 ;

EX_STAGE ex_module( stall[3],rst,clk1,flush,OF_PC,OF_instruction,mux_ma_ex_op1,mux_ma_ex_op2,OF_immx,EX_aluresult,EX_branchPC,EX_isBranchTaken,EX_PC,EX_instruction,EX_op2 ) ;
assign f_aluresult = EX_aluresult ;

//MA STAGE

assign mux_rw_ma_op2 = (MA_instruction[11:7] == EX_instruction[24:20])&(MA_instruction[6:0] == `I_type_ld ) ? f_ldresult : EX_op2 ;

MA_STAGE ma_module(stall[4] ,rst,clk2,EX_aluresult,EX_instruction,EX_PC,mux_rw_ma_op2,MA_ldresult,MA_aluresult,MA_instruction,MA_pc) ;

assign f_ldresult = MA_ldresult ;

//RW STAGE
RW_STAGE rw_module (stall[5] ,rst,clk1,MA_pc,MA_aluresult,MA_instruction,MA_ldresult,RW_isWB,RW_reg_addr,RW_reg_data) ;

always @(posedge clk1)begin
    if(~stall[5])begin
if(RW_isWB)regfile[RW_reg_addr] <= RW_reg_data ;
    end
end


endmodule
