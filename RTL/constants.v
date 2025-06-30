`ifndef CONSTANTS_V   // Include guard to prevent multiple inclusions
`define CONSTANTS_V

// Define constants

// constants for register file
  `define zero 0 //zero constant
  `define ra 1 //return address
  `define sp 2 //stack pointer
  `define gp 3 //global pointer
  `define tp 4 //thread pointer
  `define t0 5 //temp register 0
  `define t1 6  //temp register 1
  `define t2 7 //temp register 2
  `define s0 8 //saved register 0 / frame pointer
  `define fp 8
  `define s1 9 //saved register 1
  `define a0 10 //argument register 0 / return value
  `define a1 11 //argument register 1
  `define a2 12 //argument register 2
  `define a3 13 //argument register 3
  `define a4 14 //argument register 4
  `define a5 15 //argument register 5
  `define a6 16 //argument register 6
  `define a7 17  //argument register 7
  `define s2 18 //saved register 2
  `define s3 19 //saved register 3
  `define s4 20 //saved register 4
  `define s5 21 //saved register 5
  `define s6 22 //saved register 6
  `define s7 23 //saved register 7
  `define s8 24 //saved register 8
  `define s9 25 //saved register 9 
  `define s10 26 //saved register 10
  `define s11 27 //saved register 11
  `define t3 28 //temp register 3
  `define t4 29 //temp register 4
  `define t5 30 //temp register 5
  `define t6 31 //temp register 6

// OPCODES for different instructions
  `define R_type 7'b0110011
  `define I_type_alu 7'b0010011
  `define I_type_ld 7'b0000011
  `define I_type_jalr 7'b1100111
  `define I_type_env 7'b1110011
  `define S_type 7'b0100011
  `define B_type 7'b1100011
  `define J_type 7'b1101111
  `define U_type_lui 7'b0110111
  `define U_type_auipc 7'b0010111

  //hazards
  `define nop 32'h00000033




`endif