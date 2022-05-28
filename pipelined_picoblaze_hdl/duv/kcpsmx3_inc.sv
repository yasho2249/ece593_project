/*
    Copyright (c) 2004 Pablo Bleyer Kocik.

    Modified for EE573 Fall 2005 by John Lynch, OGI/OHSU:
        Deleted KCPSMX1 and KCPSMX2 options in order to reduce clutter

    Modified by Miles Simpson (mil32@pdx.edu) on March 8, 2020
    Updated to SystemVerilog, converted into package for importing

    Redistribution and use in source and binary forms, with or without
    modification, are permitted provided that the following conditions are met:

    1. Redistributions of source code must retain the above copyright notice, this
    list of conditions and the following disclaimer.

    2. Redistributions in binary form must reproduce the above copyright notice,
    this list of conditions and the following disclaimer in the documentation
    and/or other materials provided with the distribution.

    3. The name of the author may not be used to endorse or promote products
    derived from this software without specific prior written permission.

    THIS SOFTWARE IS PROVIDED BY THE AUTHOR "AS IS" AND ANY EXPRESS OR IMPLIED
    WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
    MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO
    EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
    SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
    PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
    BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER
    IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
    ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
    POSSIBILITY OF SUCH DAMAGE.

    kcpsmx include file for kcpsmx3 only.
	
	Acknowledgment:  SystemVerilog version created and tested by SethR, MilesS, 
	ShubhankaSPM, and Supraj Vastrad for ECE 571 Winter 2020 final project
*/

package kcpsmx3_inc;

`define HAS_RESET_LATCH
`define HAS_INTERRUPT_ACK
`define HAS_SCRATCH_MEMORY
`define HAS_COMPARE_OPERATION
`define HAS_TEST_OPERATION

localparam OPERAND_WIDTH    = 8;                    ///< Operand width.

/** Instruction memory data, address width. */
localparam CODE_WIDTH       = 18;
localparam CODE_DEPTH       = 10;                   ///< 1024 instructions.

localparam CODE_SIZE        = (1 << CODE_DEPTH);    ///< Instruction memory size.

localparam PORT_WIDTH       = OPERAND_WIDTH;        ///< Port IO data width.
localparam PORT_DEPTH       = OPERAND_WIDTH;        ///< Port id (address) width.
localparam PORT_SIZE        = (1 << PORT_DEPTH);    ///< Port size.

localparam STACK_WIDTH      = CODE_DEPTH;           ///< Call/return stack width.
localparam STACK_DEPTH      = 5;                    ///< Call/return stack depth.
localparam STACK_SIZE       = (1 << STACK_DEPTH);   ///< Call/return stack size.

localparam REGISTER_WIDTH   = OPERAND_WIDTH;        ///< Register file width.
localparam REGISTER_DEPTH   = 4;                    ///< Register file depth.
localparam REGISTER_SIZE    = (1 << REGISTER_DEPTH);///< Register file size.

localparam SCRATCH_WIDTH    = OPERAND_WIDTH;        ///< Scratchpad ram width.
localparam SCRATCH_DEPTH    = 6;                    ///< Scratchpad ram depth.
localparam SCRATCH_SIZE     = (1 << SCRATCH_DEPTH); ///< Scratchpad ram size.

localparam OPERATION_WIDTH  = 5;

localparam RESET_VECTOR     = 0;                    ///< Reset vector
localparam INTERRUPT_VECTOR = (CODE_SIZE - 1);       ///< Interrupt vector.

/** Conditional flags. */
typedef enum logic [1:0] {
    Z           = 2'b00, // zero set
    NZ          = 2'b01, // zero not set
    C           = 2'b10, // carry set
    NC          = 2'b11  // carry not set
} cond_flag_t;


/** Shift operations. */
typedef enum logic [1:0] {
    SA          = 2'b00, // shift all (through carry)
    RL_SRX      = 2'b01, // Rotate Left or SRX
    RR_SLX      = 2'b10, // Rotate Right or SLX
    SC          = 2'b11 // shift constant
} shift_op_t;

/** Operation codes. */
typedef enum logic [4:0] {
    LOAD        = 5'h00,
    INPUT       = 5'h02,
    FETCH       = 5'h03,
    AND         = 5'h05,
    OR          = 5'h06,
    XOR         = 5'h07,
    TEST        = 5'h09,
    COMPARE     = 5'h0a,
    ADD         = 5'h0c,
    ADDCY       = 5'h0d,
    SUB         = 5'h0e,
    SUBCY       = 5'h0f,
    RS          = 5'h10,
    RETURN      = 5'h15,
    OUTPUT      = 5'h16,
    STORE       = 5'h17,
    CALL        = 5'h18,
    JUMP        = 5'h1a,
    RETURNI     = 5'h1c,
    INTERRUPT   = 5'h1e
} opcode_t;

/** Register/Register operation fields */
typedef struct packed {
    logic [11:8] x_addr;                // [11:8]
    logic [7:4] y_addr;                 // [7:4]
    logic [3:0] padding;                // [3:0]
} reg_reg_instr_t;

/** Register/Constant operation fields */
typedef struct packed {
    logic [11:8] x_addr;                // [11:8]
    logic [7:0] constant;               // [7:0]
} reg_const_instr_t;

/** Scratchpad operation fields */
typedef struct packed {
    logic [11:8] x_addr;                // [11:8]
    logic [7:6] padding;                // [7:6]
    logic [5:0] scratch_addr;           // [5:0]
} scratch_instr_t;

/** Port operation fields */
typedef struct packed {
    logic [11:8] x_addr;                // [11:8]
    logic [7:0] port_addr;              // [7:0]
} port_instr_t;

/** Shift operation fields */
typedef struct packed {
    logic [11:8] x_addr;                // [11:8]
    logic [7:4] padding;                // [7:4]
    logic [3:3] dir;                    // [3:3]
    shift_op_t  op;                     // [2:1]
    logic [0:0] constant;               // [0:0]
} shift_instr_t;

/** Jump/Call/Return operation fields */
typedef struct packed {
    cond_flag_t flags;                  // [11:10]
    logic [9:0] code_addr;              // [9:0]
} jump_instr_t;

/** Interrupt operation fields */
typedef struct packed {
    logic [11:1] padding;
    logic [0:0] en;
} int_instr_t;

/** Instruction opcode and type union */
typedef struct packed {
    opcode_t    operation;          // [17:13]
    logic       op_cond_sel;        // [12]
    union packed {                  // [11:0]
        reg_reg_instr_t reg_reg;
        reg_const_instr_t reg_const;
        scratch_instr_t scratch;
        port_instr_t port;
        shift_instr_t shift;
        jump_instr_t jump;
        /* verilator lint_off SYMRSVDWORD */
        int_instr_t interrupt;
        /* verilator lint_on SYMRSVDWORD */
    } instr_type;
} instr_t;
endpackage

/*
    KCPSM3
    ADDK         01100 0 sX(4) constant(8)
    ADDR         01100 1 sX(4) sY(4) 0000
    ADDCYK       01101 0 sX(4) constant(8)
    ADDCYR       01101 1 sX(4) sY(4) 0000
    ANDK         00101 0 sX(4) constant(8)
    ANDR         00101 1 sX(4) sY(4) 0000
    CALL         11000 cnd(3) address(10)
    COMPARE      01010 0 sX(4) constant(8)
    COMPARE      01010 1 sX(4) sY(4) 0000
    INTERRUPTE/D 11110 000000000000 ed(1)
    FETCHK       00011 0 sX(4) 00 spad(6)
    FETCHR       00011 1 sX(4) sY(4) 0000
    INPUTK       00010 0 sX(4) pid(8)
    INPUTR       00010 1 sX(4) sY(4) 0000
    JUMP         11010 cnd(3) address(10)
    LOADK        00000 0 sX(4) constant(8)
    LOADR        00000 1 sX(4) sY(4) 0000
    ORK          00110 0 sX(4) constant(8)
    ORR          00110 1 sX(4) sY(4) 0000
    OUTPUTK      10110 0 sX(4) pid(8)
    OUTPUTR      10110 1 sX(4) sY(4) 0000
    RETURN       10101 0000000000000
    RETURNI      11100 000000000000 ie(1)
    RSR          10000 0 sX(4) 0000 1 sr(3)
    RSL          10000 0 sX(4) 0000 0 sr(3)

    SR0 sX100000 sX(4) 0000 1 11 0
    SR1 sX100000 sX(4) 0000 1 11 1
    SRX sX100000 sX(4) 0000 1 01 0
    SRA sX100000 sX(4) 0000 1 00 0
    RR  sX100000 sX(4) 0000 1 10 0

    SL0 sX100000 sX(4) 0000 0 11 0
    SL1 sX100000 sX(4) 0000 0 11 1
    SLX sX100000 sX(4) 0000 0 10 0
    SLA sX100000 sX(4) 0000 0 00 0
    RL  sX100000 sX(4) 0000 0 01 0

    STOREK       10111 0 sX(4) 00 spad(6)
    STORER       10111 1 sX(4) sY(4) 0000
    SUBK         01110 0 sX(4) constant(8)
    SUBR         01110 1 sX(4) sY(4) 0000
    SUBCYK       01111 0 sX(4) constant(8)
    SUBCYR       01111 1 sX(4) sY(4) 0000
    TESTK        01001 0 sX(4) constant(8)
    TESTR        01001 1 sX(4) sY(4) 0000
    XORK         00111 0 sX(4) constant(8)
    XORR         00111 1 sX(4) sY(4) 0000


    ADD sX,kk 0 1 1 0 0 0 x x x x k k k k k k k k
    ADD sX,sY 0 1 1 0 0 1 x x x x y y y y 0 0 0 0
    ADDCY sX,kk 0 1 1 0 1 0 x x x x k k k k k k k k
    ADDCY sX,sY 0 1 1 0 1 1 x x x x y y y y 0 0 0 0
    AND sX,kk 0 0 1 0 1 0 x x x x k k k k k k k k
    AND sX,sY 0 0 1 0 1 1 x x x x y y y y 0 0 0 0
    CALL 1 1 0 0 0 0 0 0 a a a a a a a a a a
    CALL C 1 1 0 0 0 1 1 0 a a a a a a a a a a
    CALL NC 1 1 0 0 0 1 1 1 a a a a a a a a a a
    CALL NZ 1 1 0 0 0 1 0 1 a a a a a a a a a a
    CALL Z 1 1 0 0 0 1 0 0 a a a a a a a a a a
    COMPARE sX,kk 0 1 0 1 0 0 x x x x k k k k k k k k
    COMPARE sX,sY 0 1 0 1 0 1 x x x x y y y y 0 0 0 0
    DISABLE INTERRUPT 1 1 1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0
    ENABLE INTERRUPT 1 1 1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 1
    FETCH sX, ss 0 0 0 1 1 0 x x x x 0 0 s s s s s s
    FETCH sX,(sY) 0 0 0 1 1 1 x x x x y y y y 0 0 0 0
    INPUT sX,(sY) 0 0 0 1 0 1 x x x x y y y y 0 0 0 0
    INPUT sX,pp 0 0 0 1 0 0 x x x x p p p p p p p p
    JUMP 1 1 0 1 0 0 0 0 a a a a a a a a a a
    JUMP C 1 1 0 1 0 1 1 0 a a a a a a a a a a
    JUMP NC 1 1 0 1 0 1 1 1 a a a a a a a a a a
    JUMP NZ 1 1 0 1 0 1 0 1 a a a a a a a a a a
    JUMP Z 1 1 0 1 0 1 0 0 a a a a a a a a a a
    LOAD sX,kk 0 0 0 0 0 0 x x x x k k k k k k k k
    LOAD sX,sY 0 0 0 0 0 1 x x x x y y y y 0 0 0 0
    OR sX,kk 0 0 1 1 0 0 x x x x k k k k k k k k
    OR sX,sY 0 0 1 1 0 1 x x x x y y y y 0 0 0 0
    OUTPUT sX,(sY) 1 0 1 1 0 1 x x x x y y y y 0 0 0 0
    OUTPUT sX,pp 1 0 1 1 0 0 x x x x p p p p p p p p
    RETURN 1 0 1 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0
    RETURN C 1 0 1 0 1 1 1 0 0 0 0 0 0 0 0 0 0 0
    RETURN NC 1 0 1 0 1 1 1 1 0 0 0 0 0 0 0 0 0 0
    RETURN NZ 1 0 1 0 1 1 0 1 0 0 0 0 0 0 0 0 0 0
    RETURN Z 1 0 1 0 1 1 0 0 0 0 0 0 0 0 0 0 0 0
    RETURNI DISABLE 1 1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
    RETURNI ENABLE 1 1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1
    RL sX 1 0 0 0 0 0 x x x x 0 0 0 0 0 0 1 0
    RR sX 1 0 0 0 0 0 x x x x 0 0 0 0 1 1 0 0
    SL0 sX 1 0 0 0 0 0 x x x x 0 0 0 0 0 1 1 0
    SL1 sX 1 0 0 0 0 0 x x x x 0 0 0 0 0 1 1 1
    SLA sX 1 0 0 0 0 0 x x x x 0 0 0 0 0 0 0 0
    SLX sX 1 0 0 0 0 0 x x x x 0 0 0 0 0 1 0 0
    SR0 sX 1 0 0 0 0 0 x x x x 0 0 0 0 1 1 1 0
    SR1 sX 1 0 0 0 0 0 x x x x 0 0 0 0 1 1 1 1
    SRA sX 1 0 0 0 0 0 x x x x 0 0 0 0 1 0 0 0
    SRX sX 1 0 0 0 0 0 x x x x 0 0 0 0 1 0 1 0
    STORE sX, ss 1 0 1 1 1 0 x x x x 0 0 s s s s s s
    STORE sX,(sY) 1 0 1 1 1 1 x x x x y y y y 0 0 0 0
    SUB sX,kk 0 1 1 1 0 0 x x x x k k k k k k k k
    SUB sX,sY 0 1 1 1 0 1 x x x x y y y y 0 0 0 0
    SUBCY sX,kk 0 1 1 1 1 0 x x x x k k k k k k k k
    SUBCY sX,sY 0 1 1 1 1 1 x x x x y y y y 0 0 0 0
    TEST sX,kk 0 1 0 0 1 0 x x x x k k k k k k k k
    TEST sX,sY 0 1 0 0 1 1 x x x x y y y y 0 0 0 0
    XOR sX,kk 0 0 1 1 1 0 x x x x k k k k k k k k
    XOR sX,sY 0 0 1 1 1 1 x x x x y y y y 0 0 0 0

    Unused opcodes
    01
    04
    08
    0b
    11
    12
    13
    14
    19
    1b
    1d
    1f
*/
