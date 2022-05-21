///////////////////////////////////////////////////////////
// rojoblaze_devs.sv - new global definitions for the SystemVerilog conversion of a 
// RojoBlaze, a pipelined PicoBlaze
//
// Authors: Seth Rohrbach (rseth@pdx.edu)
//
// Last Modified: March 2, 2020
//
//
// Contains global typedefs, enums, structs, etc for the RojoBlaze.
//
// Acknowledgment:  SystemVerilog version created and tested by SethR, MilesS, 
// ShubhankaSPM, and Supraj Vastrad for ECE 571 Winter 2020 final project
//
//
//////////////////////////////////////////////////////////

package rojoblaze_defs;

//Disassembler typedefs:
typedef enum logic [5:0]
{
LOAD_CONST = 6'b000000, LOAD_REG = 6'b000001,
AND_CONST = 6'b001010, AND_REG = 6'b001011,
OR_CONST = 6'b001100, OR_REG = 6'b001101,
XOR_CONST = 6'b001110, XOR_REG = 6'b001111,
TEST_CONST = 6'b010010, TEST_REG = 6'b010011,
ADD_CONST = 6'b011000, ADD_REG = 6'b011001,
ADDCY_CONST = 6'b011010, ADDCY_REG = 6'b011011,
SUB_CONST = 6'b011100, SUB_REG = 6'b011101,
SUBCY_CONST = 6'b011110, SUBCY_REG = 6'b011111,
COMPARE_CONST = 6'b010100, COMPARE_REG = 6'b010101,
SHIFT_OP = 6'b100000,
OUTPUT_CONST = 6'b101100, OUTPUT_REG = 6'b101101,
INPUT_CONST = 6'b000100, INPUT_REG = 6'b000101,
STORE_CONST = 6'b101110, STORE_REG = 6'b101111,
FETCH_CONST = 6'b000110, FETCH_REG = 6'b000111,
JUMP_UNCOND = 6'b110100, JUMP_COND = 6'b110101,
CALL_UNCOND = 6'b110000, CALL_COND = 6'b110001,
RETURN_UNCOND = 6'b101010, RETURN_COND = 6'b101011,
RETURN_I_SET = 6'b111000, INTERRUPT_SET = 6'b111100
} opcode_instr_t;

typedef enum logic [3:0]
{
SL0 = 4'b0110, SL1 = 4'b0111, SLX = 4'b0100, SLA = 4'b0000, RL = 4'b0010,
SR0 = 4'b1110, SR1 = 4'b1111, SRX = 4'b1010, SRA = 4'b1000, RR = 4'b1100
} opcode_shift_t;

typedef enum logic [1:0]
{
JUMP_Z = 2'b00, JUMP_NZ = 2'b01, JUMP_C = 2'b10, JUMP_NC = 2'b11
} opcode_jumpcond_t;

typedef enum logic [1:0]
{
CALL_Z = 2'b00, CALL_NZ = 2'b01, CALL_C = 2'b10, CALL_NC = 2'b11
} opcode_callcond_t;

typedef enum logic [1:0]
{
RETURN_Z = 2'b00, RETURN_NZ = 2'b01, RETURN_C = 2'b10, RETURN_NC = 2'b11
} opcode_returncond_t;

typedef enum logic
{
RETURNI_DISABLE = 1'b0, RETURNI_ENABLE = 1'b1
} opcode_return_en_t;

typedef enum logic
{
INT_DISABLE = 1'b0, INT_ENABLE = 1'b1
} opcode_interrupt_en_t;



endpackage
