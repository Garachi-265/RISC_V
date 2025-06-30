module IF_STAGE (input stall,rst ,
    input clk1,
    input EX_isBranchTaken,
    input [31:0] pcreg ,
    input [31:0] EX_branchPC,
    output reg [31:0] IF_PC,
    output reg [31:0] IF_instruction,
    output  [31:0] newpc 
);

    reg [7:0] instruction_memory [0:1023];
    

    initial begin
        $readmemh("i_mem.hex", instruction_memory);
        
    end

always @(posedge rst) begin
IF_PC <= 0;
IF_instruction <= 0;
end

    assign newpc = EX_isBranchTaken ? EX_branchPC : pcreg + 4;

    always @(posedge clk1) begin
        if(~stall)begin
                
        IF_PC <= pcreg;
        IF_instruction <= {instruction_memory[pcreg],instruction_memory[pcreg+1],instruction_memory[pcreg+2],instruction_memory[pcreg+3]};
    end
    end


endmodule