`include "constants.v"
module OF_STAGE(input stall,rst ,clk2,
flush,
input [31:0]IF_PC,IF_instruction,
  
output reg [4:0] regfile_addr1,regfile_addr2,
output reg [31:0] OF_immx,

output  OF_isImm,
output reg [31:0]OF_PC,OF_instruction);


reg [31:0] immx ;
wire [6:0]opcode ;
wire [31:0] instruction;

assign instruction = flush ? `nop : IF_instruction ; //if there is need of flush ,instruction processed should be a nop

assign opcode = instruction[6:0] ;

assign OF_isImm = (opcode == `I_type_alu)|(opcode == `I_type_env)|(opcode == `I_type_jalr)|(opcode == `I_type_ld) ;

always @(posedge rst)begin
    OF_PC <= 0;
    OF_instruction <= 0;
    immx <= 0;
    OF_immx <=0 ;
    regfile_addr1 <=0;
    regfile_addr2 <=0;
end

always @(*)begin
case(opcode)

`R_type: begin
regfile_addr1 <= instruction[19:15] ;
regfile_addr2 <= instruction[24:20] ;

end

`S_type: begin
regfile_addr1 <= instruction[19:15] ;
regfile_addr2 <= instruction[24:20] ;
immx <= {{20{instruction[31]}},instruction[31:25],instruction[11:7]} ;
end

`B_type: begin
regfile_addr1 <= instruction[19:15] ;
regfile_addr2 <= instruction[24:20] ;
immx <= {{19{instruction[31]}}, instruction[31], instruction[7], instruction[30:25], instruction[11:8], 1'b0};
end

`I_type_alu: begin
regfile_addr1 <= instruction[19:15] ;
immx <= {{20{instruction[31]}},instruction[31:20]} ; //In I type imm is present in lower 12 bits ;
end

`I_type_jalr: begin
regfile_addr1 <= instruction[19:15] ;
immx <= {{20{instruction[31]}},instruction[31:20]} ; //In I type imm is present in lower 12 bits ;
end

`I_type_ld: begin
regfile_addr1 <= instruction[19:15] ;
immx <= {{20{instruction[31]}},instruction[31:20]} ; //In I type imm is present in lower 12 bits ;
end

`U_type_auipc: begin
    immx <= {instruction[31:12],{12{1'b0}}} ; //In U type imm is present in upper 20 bits ;
end

`U_type_lui: begin
    immx <= {instruction[31:12],{12{1'b0}}} ; //In U type imm is present in upper 20 bits ;
end

`J_type: begin
immx <= {{11{instruction[31]}}, instruction[31], instruction[19:12], instruction[20], instruction[30:21], 1'b0};
end



// `I_type_env: begin
// end


endcase
end


always @(posedge clk2)begin
    if(~stall)begin
OF_instruction <= instruction ;
OF_PC <= IF_PC ;

OF_immx <= immx ;
    end
end

endmodule