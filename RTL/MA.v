`include "constants.v"

module MA_STAGE(
    input stall, rst ,clk2,
    input [31:0] EX_aluresult,EX_instruction,EX_PC,EX_op2,
    output reg[31:0] MA_ldresult,
    output reg[31:0] MA_aluresult,MA_instruction,MA_pc
);

reg [7:0] d_mem [0:1023] ;
initial begin
    $readmemh("d_mem.hex",d_mem) ;
end

wire [6:0] opcode ;
reg [31:0] ldresult ;
wire [2:0] funct3 ;

assign funct3 = EX_instruction[14:12] ;
assign opcode = EX_instruction[6:0] ;

wire [7:0]byte1,byte2,byte3,byte4 ; //byte 1 is MSB
wire [7:0]op2_B1,op2_B2,op2_B3,op2_B4 ;

assign byte1 = d_mem[EX_aluresult] ;
assign byte2 = d_mem[EX_aluresult + 1] ;
assign byte3 = d_mem[EX_aluresult + 2] ;
assign byte4 = d_mem[EX_aluresult + 3] ;

// assign op2_B4 = EX_op2[7:0] ;
// assign op2_B3 = EX_op2[15:8] ;
// assign op2_B2 = EX_op2[23:16] ;
// assign op2_B1 = EX_op2[31:24] ;

always @(posedge rst)begin
MA_aluresult <= 0 ;
MA_instruction <= 0;
MA_pc <= 0;
MA_ldresult <=0 ;
end

always @(*)begin
case(opcode)

`I_type_ld :begin
      case(funct3)
        3'd0 : ldresult <= {{24{byte4[7]}},byte4} ; //LB
        3'd1 : ldresult <= {{16{byte3[7]}},byte3,byte4} ; //LH
        3'd2 : ldresult <= {byte1,byte2,byte3,byte4} ; //LW
        3'd4 : ldresult <= {{24{1'b0}},byte4} ; //LBU
        3'd5 : ldresult <= {{16{1'b0}},byte3,byte4} ; //LHU
      endcase  
end

`S_type :begin
    case(funct3)
        3'd0 : {d_mem[EX_aluresult + 3]} <= EX_op2[7:0];
        3'd1 : {d_mem[EX_aluresult + 2] ,d_mem[EX_aluresult + 3]} <= EX_op2[15:0];
        3'd2 : {d_mem[EX_aluresult],d_mem[EX_aluresult + 1] ,d_mem[EX_aluresult + 2] ,d_mem[EX_aluresult + 3]} <= EX_op2 ;
    endcase
end



endcase
end

always @(posedge clk2)begin

    if (~stall)begin
MA_ldresult <= ldresult ;
MA_pc <= EX_PC ;
MA_instruction <= EX_instruction ;
MA_aluresult <= EX_aluresult ;
    end
end


endmodule