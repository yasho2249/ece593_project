/*
    Copyright (c) 2004 Pablo Bleyer Kocik.

    Modified for EE573 Fall 2005 by John Lynch, OGI/OHSU

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

    Behavioral KCPSMX arithmetic logic unit.
	
	Acknowledgment:  SystemVerilog version created and tested by SethR, MilesS, 
	ShubhankaSPM, and Supraj Vastrad for ECE 571 Winter 2020 final project
*/

import kcpsmx3_inc::*;

module kcpsmx_alu(
    operation,
    shift_operation, shift_direction, shift_constant,
    result, operand_a, operand_b, carry_in,
    zero_out, carry_out
);
input opcode_t                  operation;				///< Main operation.
input shift_op_t                shift_operation;		///< Rotate/shift operation.
input                           shift_direction;		///< Rotate/shift left(0)/right(1).
input                           shift_constant;			///< Shift constant (0 or 1).
output logic [OPERAND_WIDTH-1:0] result;				///< ALU result.
input [OPERAND_WIDTH-1:0]       operand_a, operand_b;	///< ALU operands.
input                            carry_in;				///< Carry in.
output logic                     zero_out;				///< Zero out.
output logic                     carry_out;				///< Carry out.

/** Adder/substracter second operand. */
wire [OPERAND_WIDTH-1:0] addsub_b =
    (operation == SUB
    || operation == SUBCY
    || operation == COMPARE
    ) ? (~operand_b) :
    operand_b;

/** Adder/substracter carry. */
wire addsub_carry =
    (operation == ADDCY) ? carry_in :
    (operation == SUB
    || operation == COMPARE
    ) ? 1 :                                         // ~b => b'
    (operation == SUBCY) ? ~carry_in : 0;  // ~b - c => b' - c
    //0;

/** Adder/substracter with carry. */
wire [OPERAND_WIDTH:0] addsub_result = operand_a + addsub_b + addsub_carry;

/** Shift bit value. */
logic shift_bit;

always_comb
begin: shift_bit_mux
    case (shift_operation)
        RR_SLX: shift_bit = operand_a[0];
        RL_SRX: shift_bit = operand_a[7];
        SA:     shift_bit = carry_in;
        default:shift_bit = shift_constant;
    endcase
end

always_comb
begin: on_alu
    /* Defaults */
    carry_out = 0;

    // synthesis parallel_case full_case
    case (operation)
        ADD,
        ADDCY:
            {carry_out, result} = addsub_result;

        COMPARE,
        SUB,
        SUBCY:
            {carry_out, result} = {~addsub_result[8], addsub_result[7:0]};

        AND:
            result = operand_a & operand_b;

        OR:
            result = operand_a | operand_b;

        TEST:
            begin
                result = operand_a & operand_b; carry_out = ^result;
            end

        XOR:
            result = operand_a ^ operand_b;

        RS:
            if (shift_direction)                                // shift right
                {result, carry_out} = {shift_bit, operand_a};
            else                                                // shift left
                {carry_out, result} = {operand_a, shift_bit};

        default:
            result = operand_b;
    endcase

    zero_out = ~|result;
end

endmodule
