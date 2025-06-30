`timescale 1ns/1ps
`include "RISCV.v"
`include "constants.v"
module RISCV_tb();
reg clk1,clk2,rst ;

RISC_V dut(clk1,clk2,rst) ;
integer i;
integer file ;
initial begin
rst <= 0 ;
//2 clk 
clk1 <= 0 ; clk2 <= 0 ;
forever begin
// #5 clk1 = 1;    // Generating two-phase clock
// #5 clk1 = 0;
// #5 clk2 = 1;
// #5 clk2 = 0;

#5 clk1 = 1;clk2 = 1;  // Generatin single clock signal
#5 clk1 = 0;clk2 = 0;    
end


end
initial begin
    $dumpfile("riscv_tb.vcd");
    $dumpvars(0,RISCV_tb);
end
initial begin
    for (i = 0 ; i<33 ; i++)begin
dut.regfile[i] <= 32'd0 ;
    end
dut.regfile[`zero] <= 32'd0 ;
dut.regfile[`s0] <= 32'd0 ;
dut.regfile[`s1] <= 32'd0 ;
dut.regfile[`s2] <= 32'd0 ;
dut.regfile[`s3] <= 32'd0 ;
dut.regfile[`s4] <= 32'd0 ;
dut.regfile[`s5] <= 32'h0 ;
dut.regfile[`s6] <= 32'd0 ;
dut.regfile[`s7] <= 32'd0 ;
dut.regfile[`s8] <= 32'd0 ;
dut.regfile[`s9] <= 32'd0 ;
dut.regfile[`s10] <= 32'habcdef12 ;
dut.regfile[`s11] <= 32'd0 ;

dut.regfile[`t0] <= 32'd0 ;
dut.regfile[`t1] <= 32'd0 ;
dut.regfile[`t2] <= 32'd0 ;
dut.regfile[`t3] <= 32'd0 ; 
dut.regfile[`t4] <= 32'd0 ;
dut.regfile[`t5] <= 32'd0 ;
dut.regfile[`t6] <= 32'd0 ;

#1 rst <= 1 ;
#1 rst <= 0;


#1000

//writing reg values to a file
 file = $fopen("reg_out.hex", "w");
    
    for (i = 0; i < 32; i = i + 1) begin
        case (i)
            0: $fdisplay(file, "%08x // x0  (zero)", dut.regfile[i]);
            1: $fdisplay(file, "%08x // x1  (ra)",   dut.regfile[i]);
            2: $fdisplay(file, "%08x // x2  (sp)",   dut.regfile[i]);
            3: $fdisplay(file, "%08x // x3  (gp)",   dut.regfile[i]);
            4: $fdisplay(file, "%08x // x4  (tp)",   dut.regfile[i]);
            5: $fdisplay(file, "%08x // x5  (t0)",   dut.regfile[i]);
            6: $fdisplay(file, "%08x // x6  (t1)",   dut.regfile[i]);
            7: $fdisplay(file, "%08x // x7  (t2)",   dut.regfile[i]);
            8: $fdisplay(file, "%08x // x8  (s0/fp)",dut.regfile[i]);
            9: $fdisplay(file, "%08x // x9  (s1)",   dut.regfile[i]);
            10:$fdisplay(file, "%08x // x10 (a0)",   dut.regfile[i]);
            11:$fdisplay(file, "%08x // x11 (a1)",   dut.regfile[i]);
            12:$fdisplay(file, "%08x // x12 (a2)",   dut.regfile[i]);
            13:$fdisplay(file, "%08x // x13 (a3)",   dut.regfile[i]);
            14:$fdisplay(file, "%08x // x14 (a4)",   dut.regfile[i]);
            15:$fdisplay(file, "%08x // x15 (a5)",   dut.regfile[i]);
            16:$fdisplay(file, "%08x // x16 (a6)",   dut.regfile[i]);
            17:$fdisplay(file, "%08x // x17 (a7)",   dut.regfile[i]);
            18:$fdisplay(file, "%08x // x18 (s2)",   dut.regfile[i]);
            19:$fdisplay(file, "%08x // x19 (s3)",   dut.regfile[i]);
            20:$fdisplay(file, "%08x // x20 (s4)",   dut.regfile[i]);
            21:$fdisplay(file, "%08x // x21 (s5)",   dut.regfile[i]);
            22:$fdisplay(file, "%08x // x22 (s6)",   dut.regfile[i]);
            23:$fdisplay(file, "%08x // x23 (s7)",   dut.regfile[i]);
            24:$fdisplay(file, "%08x // x24 (s8)",   dut.regfile[i]);
            25:$fdisplay(file, "%08x // x25 (s9)",   dut.regfile[i]);
            26:$fdisplay(file, "%08x // x26 (s10)",  dut.regfile[i]);
            27:$fdisplay(file, "%08x // x27 (s11)",  dut.regfile[i]);
            28:$fdisplay(file, "%08x // x28 (t3)",   dut.regfile[i]);
            29:$fdisplay(file, "%08x // x29 (t4)",   dut.regfile[i]);
            30:$fdisplay(file, "%08x // x30 (t5)",   dut.regfile[i]);
            31:$fdisplay(file, "%08x // x31 (t6)",   dut.regfile[i]);
        endcase
    end

$fclose(file);

$writememh("d_mem.hex", dut.ma_module.d_mem);



$finish ;

end





endmodule