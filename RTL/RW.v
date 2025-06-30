`include "constants.v"

module RW_STAGE(input stall, rst,clk1,
input [31:0] MA_pc,MA_aluresult,MA_instruction,MA_ldresult,
output isWB,
output [31:0] reg_addr,
output reg [31:0] reg_data);

wire [6:0] opcode ;

assign opcode = MA_instruction[6:0] ;

assign reg_addr = MA_instruction[11:7] ;
assign isWB = (opcode == `R_type) | (opcode == `I_type_alu) | (opcode == `I_type_jalr) | (opcode == `I_type_ld) | (opcode == `J_type) | (opcode == `U_type_auipc) | (opcode == `U_type_lui);

always @ (posedge rst) begin
    reg_data <= 0;
    
end

always @ (*)begin

case (opcode)

`I_type_ld  : reg_data <= MA_ldresult ;
default : reg_data <= MA_aluresult ;

endcase
end

endmodule