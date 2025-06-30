`include "constants.v"

module EX_STAGE(input stall,rst, clk1,flush,
input [31:0] OF_PC,OF_instruction,
input [31:0] OF_op1,OF_op2,OF_immx,
output reg [31:0] EX_aluresult,
output reg [31:0] EX_branch_Target,
output reg EX_isBranchTaken,
output reg [31:0] EX_PC,EX_instruction,EX_op2 );

reg [31:0] aluresult ;
wire [6:0] funct7,opcode ;
wire [2:0] funct3 ;
wire [31:0] op1,op2,immx ;
wire [31:0] instruction ;

assign instruction = flush ? `nop : OF_instruction ; 

assign op1 = flush ? 0: OF_op1 ;
assign op2 = flush ? 0: OF_op2 ;
assign immx = flush ? 0: OF_immx ;

assign opcode = instruction[6:0]  ;

assign funct3 = instruction[14:12] ;
assign funct7 = instruction[31:25] ;

//wires for multiply extension
    wire signed   [31:0] s_op1 = op1;
    wire signed   [31:0] s_op2 = op2;
    wire          [31:0] u_op1 = op1;
    wire          [31:0] u_op2 = op2;

    wire signed   [63:0] prod_mul   = s_op1 * s_op2;
    //wire signed   [63:0] prod_mulh  = s_op1 * s_op2;
    wire signed   [63:0] prod_mulsu = s_op1 * $signed({1'b0, u_op2});
    wire          [63:0] prod_mulhu = u_op1 * u_op2;

always @(posedge rst)begin
aluresult <= 0;
EX_PC <= 0 ;
    EX_instruction <= 0 ;
    EX_op2 <= 0 ;
    EX_aluresult <= 0 ;
EX_branch_Target <=0 ;
EX_isBranchTaken <= 0 ;
end

always @ (*) begin // calculating aluresult and branch_target
case(opcode)
`R_type :begin

    case(funct7)

    7'h00:begin
        case(funct3)
        3'd0 :aluresult <= op1 + op2 ; //ADD
        3'd1 :aluresult <= op1 << op2 ; //SLL
        3'd2 :aluresult <= ($signed(op1) < $signed(op2)) ? 32'b1 : 32'b0 ; //SLT
        3'd3 :aluresult <= (op1 < op2) ? 32'b1 : 32'b0 ; //SLTU
        3'd4 :aluresult <= op1 ^ op2 ; //XOR
        3'd5 :aluresult <= op1 >> op2 ; //SRL
        3'd6 :aluresult <= op1 | op2 ; //OR
        3'd7 :aluresult <= op1 & op2 ; //AND
        endcase
    end


    7'h20 :begin
        case(funct3)
        3'd0 :aluresult <= op1 - op2 ; //SUB
        3'd5 :aluresult <= s_op1 >>> u_op2 ; //SRA
        endcase
    end

    7'h01 :begin //multiply extension
        case(funct3)
        3'd0 : aluresult <= prod_mul[31:0] ;  //MUL
        3'd1 : aluresult <= prod_mul[63:32] ; //MULH
        3'd2 : aluresult <= prod_mulsu[63:32] ; //MULSU
        3'd3 : aluresult <= prod_mulhu[63:22] ; //MULU
        3'd4 : aluresult <= $signed(op1) / $signed(op2) ; //DIV
        3'd5 : aluresult <= op1 / op2 ; //DIVU
        3'd6 : aluresult <= $signed(op1) % $signed(op2)  ; //REM
        3'd7 : aluresult <= op1 % op2 ; //REMU
        endcase
    end

    endcase
end

`I_type_alu :begin

    case(funct3)
    3'd0 : aluresult <= op1 + immx ; //ADDI
    3'd1 : aluresult <= op1 << immx[4:0] ; //SLLI
    3'd2 : aluresult <= ($signed(op1) < $signed(immx)) ? 32'b1 : 32'b0 ; //SLTI
    3'd3 : aluresult <= (op1 < immx) ? 32'b1 : 32'b0 ; //SLTIU
    3'd4 : aluresult <= op1 ^ immx ; //XORI
    3'd5 :begin 
        case(funct7)
        7'h00 :aluresult <= op1 >> immx[4:0]  ; //SRLI
        7'h20 :aluresult <= s_op1 >>> immx[4:0] ; //SRAI
        endcase
          end
    3'd6 : aluresult <= op1 | immx ; //ORI
    3'd7 : aluresult <= op1 & immx ; //ANDI
    endcase

end

`I_type_ld :begin
    aluresult <= op1 + immx ;
end

`I_type_jalr :begin
    aluresult <= OF_PC + 4 ;
    EX_branch_Target <= op1 + immx ; 
end

`J_type :begin
    aluresult <= OF_PC + 4 ;
    EX_branch_Target <= OF_PC + immx ;
end

`S_type :begin
    aluresult <= op1 + immx ;
end

`U_type_lui :begin
    aluresult <= immx ;
end

`U_type_auipc :begin
    aluresult <= OF_PC + immx ;
end

`B_type :begin
    EX_branch_Target <= OF_PC + immx ;
end

endcase
end

always @(*)begin
case (opcode)
    `B_type:begin
        case(funct3)
        3'd0 :EX_isBranchTaken <= (op1 == op2) ? 1 : 0 ; //BEQ
        3'd1 :EX_isBranchTaken <= (op1 != op2) ? 1 : 0 ; //BNE
        //3'd2 :EX_isBranchTaken <= (op1 == op2) ? 1 : 0 ;  //Not in ISA
        //3'd3 :EX_isBranchTaken <= (op1 == op2) ? 1 : 0 ;  //Not in ISA
        3'd4 :EX_isBranchTaken <= (s_op1 < s_op2) ? 1 : 0 ; //BLT
        3'd5 :EX_isBranchTaken <= (s_op1 >= s_op2) ? 1 : 0 ; //BGE
        3'd6 :EX_isBranchTaken <= (u_op1 < u_op2) ? 1 : 0 ; //BLTU
        3'd7 :EX_isBranchTaken <= (u_op1 >= u_op2) ? 1 : 0 ; //BGEU
        endcase
    end
    `I_type_jalr:EX_isBranchTaken <= 1;
    `J_type:EX_isBranchTaken <= 1; 
    default:EX_isBranchTaken <= 0;
endcase
end

always @(posedge clk1)begin
    if(~stall)begin
    EX_PC <= OF_PC ;
    EX_instruction <= instruction ;
    EX_op2 <= OF_op2 ;
    EX_aluresult <= aluresult ;
    end
end

endmodule