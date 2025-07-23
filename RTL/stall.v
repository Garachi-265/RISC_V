`include "constants.v"
module stall_logic_ld_use_hazard(input clk,rst,
input [31:0] i1,i2,
output reg [5:1]stall);

wire temp1 ;
reg temp2,cooldown ;

assign temp1 = ((i2[11:7] == i1[24:20]) | (i2[11:7] == i1[19:15]) )&(i2[6:0] == `I_type_ld) ;

always @ (posedge rst)begin
   if (rst) begin stall <= 0 ;
   cooldown <=0  ;end
        end

always @(posedge clk) begin
temp2 <= temp1 ;
if (temp1 && ~cooldown)begin
    cooldown <= cooldown + 1 ;
stall <= 5'b00111 ;
end
else if(cooldown)begin
stall[3:1] <= 3'b000;
cooldown <= 0 ;
end
stall[4] <= stall[3] ;
stall[5] <= stall[4] ;
end


endmodule
