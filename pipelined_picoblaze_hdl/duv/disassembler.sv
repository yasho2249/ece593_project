////////////////////////////////////////////////////////////////////////////////////
//
// Disassemble the instruction codes to form a text string for display.
//
// Modified by Seth Rohrbach (rseth@pdx.edu)
// Modified March 2, 2020
// Modified to take advantage of SystemVerilog typedefs for the opcode.
// The typedefs have been included in a package.
//
// Acknowledgment:  SystemVerilog version created and tested by SethR, MilesS, ShubhankaSPM, 
// and Supraj Vastrad for ECE 571 Winter 2020 final project
////////////////////////////////////////////////////////////////////////////////////

import rojoblaze_defs::*;
import kcpsmx3_inc::*;

module disassembler(
    input [17:0] instruction,
    output reg [1:152] kcpsm3_opcode
);

 wire	[1:16] 	sx_decode ; //sX register specification
 wire 	[1:16]  sy_decode ; //sY register specification
 wire 	[1:16]	kk_decode ; //constant value specification
 wire 	[1:24]	aaa_decode ; //address specification
 //
 ////////////////////////////////////////////////////////////////////////////////
 //
 // Function to convert 4-bit binary nibble to hexadecimal character
 //
 ////////////////////////////////////////////////////////////////////////////////
 //
 function [1:8] hexcharacter ;
 input 	[3:0] nibble ;
 begin
 case (nibble)
 4'b0000 : hexcharacter = "0" ;
 4'b0001 : hexcharacter = "1" ;
 4'b0010 : hexcharacter = "2" ;
 4'b0011 : hexcharacter = "3" ;
 4'b0100 : hexcharacter = "4" ;
 4'b0101 : hexcharacter = "5" ;
 4'b0110 : hexcharacter = "6" ;
 4'b0111 : hexcharacter = "7" ;
 4'b1000 : hexcharacter = "8" ;
 4'b1001 : hexcharacter = "9" ;
 4'b1010 : hexcharacter = "A" ;
 4'b1011 : hexcharacter = "B" ;
 4'b1100 : hexcharacter = "C" ;
 4'b1101 : hexcharacter = "D" ;
 4'b1110 : hexcharacter = "E" ;
 4'b1111 : hexcharacter = "F" ;
 endcase
 end
 endfunction
  /*
 //
 ////////////////////////////////////////////////////////////////////////////////
 //
 begin
 */
 // decode first register
 assign sx_decode[1:8] = "s" ;
 assign sx_decode[9:16] = hexcharacter(instruction[11:8]) ;

 // decode second register
 assign sy_decode[1:8] = "s";
 assign sy_decode[9:16] = hexcharacter(instruction[7:4]);

 // decode constant value
 assign kk_decode[1:8] = hexcharacter(instruction[7:4]);
 assign kk_decode[9:16] = hexcharacter(instruction[3:0]);

 // address value
 assign aaa_decode[1:8] = hexcharacter({2'b00, instruction[9:8]});
 assign aaa_decode[9:16] = hexcharacter(instruction[7:4]);
 assign aaa_decode[17:24] = hexcharacter(instruction[3:0]);

 // decode instruction
 always @ (instruction or kk_decode or sy_decode or sx_decode or aaa_decode)
 begin
 case (instruction[17:12])
 LOAD_CONST  : begin kcpsm3_opcode <= {"LOAD ", sx_decode, ",", kk_decode, " "} ; end
 LOAD_REG    : begin kcpsm3_opcode <= {"LOAD ", sx_decode, ",", sy_decode, " "} ; end
 AND_CONST   : begin kcpsm3_opcode <= {"AND  ", sx_decode, ",", kk_decode, " "} ; end
 AND_REG     : begin kcpsm3_opcode <= {"AND  ", sx_decode, ",", sy_decode, " "} ; end
 OR_CONST    : begin kcpsm3_opcode <= {"OR   ", sx_decode, ",", kk_decode, " "} ; end
 OR_REG      : begin kcpsm3_opcode <= {"OR   ", sx_decode, ",", sy_decode, " "} ; end
 XOR_CONST   : begin kcpsm3_opcode <= {"XOR  ", sx_decode, ",", kk_decode, " "} ; end
 XOR_REG     : begin kcpsm3_opcode <= {"XOR  ", sx_decode, ",", sy_decode, " "} ; end
 TEST_CONST  : begin kcpsm3_opcode <= {"TEST ", sx_decode, ",", kk_decode, " "} ; end
 TEST_REG    : begin kcpsm3_opcode <= {"TEST ", sx_decode, ",", sy_decode, " "} ; end
 ADD_CONST   : begin kcpsm3_opcode <= {"ADD  ", sx_decode, ",", kk_decode, " "} ; end
 ADD_REG     : begin kcpsm3_opcode <= {"ADD  ", sx_decode, ",", sy_decode, " "} ; end
 ADDCY_CONST : begin kcpsm3_opcode <= {"ADDCY", sx_decode, ",", kk_decode, " "} ; end
 ADDCY_REG   : begin kcpsm3_opcode <= {"ADDCY", sx_decode, ",", sy_decode, " "} ; end
 SUB_CONST   : begin kcpsm3_opcode <= {"SUB  ", sx_decode, ",", kk_decode, " "} ; end
 SUB_REG     : begin kcpsm3_opcode <= {"SUB  ", sx_decode, ",", sy_decode, " "} ; end
 SUBCY_CONST : begin kcpsm3_opcode <= {"SUBCY", sx_decode, ",", kk_decode, " "} ; end
 SUBCY_REG   : begin kcpsm3_opcode <= {"SUBCY", sx_decode, ",", sy_decode, " "} ; end
 COMPARE_CONST : begin kcpsm3_opcode <= {"COMPARE ", sx_decode, ",", kk_decode, " "} ; end
 COMPARE_REG   : begin kcpsm3_opcode <= {"COMPARE ", sx_decode, ",", sy_decode, " "} ; end
 SHIFT_OP : begin
   case (instruction[3:0])
    SL0 : begin kcpsm3_opcode <= {"SL0 ", sx_decode, " "}; end
    SL1 : begin kcpsm3_opcode <= {"SL1 ", sx_decode, " "}; end
    SLX : begin kcpsm3_opcode <= {"SLX ", sx_decode, " "}; end
    SLA : begin kcpsm3_opcode <= {"SLA ", sx_decode, " "}; end
    RL  : begin kcpsm3_opcode <= {"RL ", sx_decode, " "}; end
    SR0 : begin kcpsm3_opcode <= {"SR0 ", sx_decode, " "}; end
    SR1 : begin kcpsm3_opcode <= {"SR1 ", sx_decode, " "}; end
    SRX : begin kcpsm3_opcode <= {"SRX ", sx_decode, " "}; end
    SRA : begin kcpsm3_opcode <= {"SRA ", sx_decode, " "}; end
    RR  : begin kcpsm3_opcode <= {"RR ", sx_decode, " "}; end
     default : begin kcpsm3_opcode <= "Invalid Instruction"; end
   endcase
 end
OUTPUT_CONST : begin kcpsm3_opcode <= {"OUTPUT ", sx_decode, ",", kk_decode, " "}; end
OUTPUT_REG   : begin kcpsm3_opcode <= {"OUTPUT ", sx_decode, ",(", sy_decode, ") "}; end
INPUT_CONST  : begin kcpsm3_opcode <= {"INPUT ", sx_decode, ",", kk_decode, " "}; end
INPUT_REG    : begin kcpsm3_opcode <= {"INPUT ", sx_decode, ",(", sy_decode, ") "}; end
STORE_CONST  : begin kcpsm3_opcode <= {"STORE ", sx_decode, ",", kk_decode, " "}; end
STORE_REG    : begin kcpsm3_opcode <= {"STORE ", sx_decode, ",(", sy_decode, ") "}; end
FETCH_CONST  : begin kcpsm3_opcode <= {"FETCH ", sx_decode, ",", kk_decode, " "}; end
FETCH_REG    : begin kcpsm3_opcode <= {"FETCH ", sx_decode, ",(", sy_decode, ") "}; end
JUMP_UNCOND  : begin kcpsm3_opcode <= {"JUMP ", aaa_decode, " "}; end
JUMP_COND    : begin
   case (instruction[11:10])
   JUMP_Z    : begin kcpsm3_opcode <= {"JUMP Z,", aaa_decode, " "}; end
   JUMP_NZ   : begin kcpsm3_opcode <= {"JUMP NZ,", aaa_decode, " "}; end
   JUMP_C    : begin kcpsm3_opcode <= {"JUMP C,", aaa_decode, " "}; end
   JUMP_NC   : begin kcpsm3_opcode <= {"JUMP NC,", aaa_decode, " "}; end
     default : begin kcpsm3_opcode <= "Invalid Instruction"; end
   endcase
 end
 CALL_UNCOND : begin kcpsm3_opcode <= {"CALL ", aaa_decode, " "}; end
 CALL_COND   : begin
   case (instruction[11:10])
   CALL_Z    : begin kcpsm3_opcode <= {"CALL Z,", aaa_decode, " "}; end
   CALL_NZ   : begin kcpsm3_opcode <= {"CALL NZ,", aaa_decode, " "}; end
   CALL_C    : begin kcpsm3_opcode <= {"CALL C,", aaa_decode, " "}; end
   CALL_NC   : begin kcpsm3_opcode <= {"CALL NC,", aaa_decode, " "}; end
     default : begin kcpsm3_opcode <= "Invalid Instruction"; end
   endcase
 end
 RETURN_UNCOND : begin kcpsm3_opcode <= "RETURN "; end
 RETURN_COND : begin
 case (instruction[11:10])
     2'b00   : begin kcpsm3_opcode <= "RETURN Z "; end
     2'b01   : begin kcpsm3_opcode <= "RETURN NZ "; end
     2'b10   : begin kcpsm3_opcode <= "RETURN C "; end
     2'b11   : begin kcpsm3_opcode <= "RETURN NC "; end
     default : begin kcpsm3_opcode <= "Invalid Instruction"; end
   endcase
 end
 RETURN_I_SET : begin
   case (instruction[0])
   RETURNI_DISABLE    : begin kcpsm3_opcode <= "RETURNI DISABLE "; end
   RETURNI_ENABLE     : begin kcpsm3_opcode <= "RETURNI ENABLE "; end
     default : begin kcpsm3_opcode <= "Invalid Instruction"; end
   endcase
 end
 INTERRUPT_SET : begin
   case (instruction[0])
   INT_DISABLE    : begin kcpsm3_opcode <= "DISABLE INTERRUPT "; end
   INT_ENABLE     : begin kcpsm3_opcode <= "ENABLE INTERRUPT "; end
     default : begin kcpsm3_opcode <= "Invalid Instruction"; end
   endcase
 end
 default : begin kcpsm3_opcode <= "Invalid Instruction"; end
 endcase
 end

endmodule
