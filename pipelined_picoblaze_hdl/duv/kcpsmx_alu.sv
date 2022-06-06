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


// Assertions for ALU Execution functions 
// Implement Assertions as ARGS for future work.
/*
property add_assert;
@(posedge clk) (operation == ADD) |->  ({carry_out, result} == (operand_a + operand_b))&&(zero_out == (result ? 0 : 1));
endproperty 
a1: assert property (add_assert)
	$display ("Addition  successful");
else
	$error ("Addition  failed");

property sub_assert;
@(posedge clk) (operation == SUB) |->  (result == (operand_a - operand_b))&&(zero_out == (result ? 0 : 1));
endproperty 
a15: assert property (sub_assert)
	$display ("Subtraction successful");
else
	$error ("Subtraction failed");

property addcy_assert;
@(posedge clk) (operation == ADDCY) |->  ({carry_out, result} == (operand_a + operand_b + carry_in))&&(zero_out == (result ? 0 : 1));
endproperty 
a16: assert property (addcy_assert)
	$display ("Addition with carry successful");
else
	$error ("Addition with carry failed");

property subcy_assert;
@(posedge clk) (operation == ADDCY) |->  ({carry_out, result} == (operand_a + operand_b + carry_in))&&(zero_out == (result ? 0 : 1));
endproperty 
a17: assert property (subcy_assert)
	$display ("Subtraction with carry successful");
else
	$error ("Subtraction with carry failed");

property and_assert;
@(posedge clk) (operation == AND) |->  (result == (operand_a & operand_b))&&(carry_out == 1'b0)&&(zero_out == (result ? 0 : 1));
endproperty 
a2: assert property (and_assert)
	$display ("AND successful");
else
	$error ("AND not successful");

property or_assert;
@(posedge clk) (operation == OR) |->  (result == (operand_a | operand_b))&&(carry_out == 1'b0)&&(zero_out == (result ? 0 : 1));
endproperty 
a13: assert property (or_assert)
	$display ("OR successful");
else
	$error ("OR not successful");

property xor_assert;
@(posedge clk) (operation == XOR) |->  (result == (operand_a ^ operand_b))&&(carry_out == 1'b0)&&(zero_out == (result ? 0 : 1));
endproperty 
a14: assert property (xor_assert)
	$display ("XOR successful");
else
	$error ("XOR not successful");

property sr1_assert;
@(posedge clk) ((operation == RS)&&(shift_operation == SC)&&(shift_direction == 1'b1)&&(shift_constant == 1'b1)) |->  (result == (operand_a>>1) + 8'h80)&&(carry_out == operand_a[0])&&(zero_out == 1'b0);
endproperty 
a3: assert property (sr1_assert)
	$display ("SR1 successful");
else
	$error ("SR1 not successful");

property sr0_assert;
@(posedge clk) ((operation == RS)&&(shift_operation == SC)&&(shift_direction == 1'b1)&&(shift_constant == 1'b0)) |->  (result == (operand_a>>1))&&(carry_out == operand_a[0])&&(zero_out == (result ? 0 : 1));
endproperty 
a4: assert property (sr0_assert)
	$display ("SR0 successful");
else
	$error ("SR0 not successful");

property srX_assert;
@(posedge clk) ((operation == RS)&&(shift_operation == RL_SRX)&&(shift_constant == 1'b0)&&(shift_direction == 1'b1)) |->  (result == (operand_a>>>1))&&(carry_out == operand_a[0])&&(zero_out == (result ? 0 : 1));
endproperty 
a5: assert property (srX_assert)
	$display ("SRX successful");
else
	$error ("SRX not successful");

property srA_assert;
@(posedge clk) ((operation == RS)&&(shift_operation == SA)&&(shift_constant == 1'b0)&&(shift_direction == 1'b1)) |->  (result == (operand_a>>1+(carry_in?8'h80:8'h00)))&&(carry_out == operand_a[0])&&(zero_out == (result ? 0 : 1));
endproperty 
a6: assert property (srA_assert)
	$display ("SRA successful");
else
	$error ("SRA not successful");

property rr_assert;
@(posedge clk) ((operation == RS)&&(shift_operation == RR_SLX)&&(shift_constant == 1'b0)&&(shift_direction == 1'b1)) |->  (result == (operand_a>>1+(operand_a[0]?8'h80:8'h00)))&&(carry_out == operand_a[0])&&(zero_out == (result ? 0 : 1));
endproperty 
a7: assert property (rr_assert)
	$display ("RR successful");
else
	$error ("RR not successful");

property sl1_assert;
@(posedge clk) ((operation == RS)&&(shift_operation == SC)&&(shift_constant == 1'b1)&&(shift_direction == 1'b0)) |->  ({carry_out, result} == {operand_a, 1'b1})&&(zero_out == 1'b0);
endproperty 
a8: assert property (sl1_assert)
	$display ("SL1 successful");
else
	$error ("SL1 not successful");

property sl0_assert;
@(posedge clk) ((operation == RS)&&(shift_operation == SC)&&(shift_direction == 1'b0)&&(shift_constant == 1'b0)) |->  (result == (operand_a<<1))&&(carry_out == operand_a[7])&&(zero_out == (result ? 0 : 1));
endproperty 
a9: assert property (sl0_assert)
	$display ("SL0 successful");
else
	$error ("SL0 not successful");

property slX_assert;
@(posedge clk) ((operation == RS)&&(shift_operation == RR_SLX)&&(shift_constant == 1'b0)&&(shift_direction == 1'b0)) |->  (result == (operand_a<<1 + operand_a[0]))&&(carry_out == operand_a[7])&&(zero_out == (result ? 0 : 1));
endproperty 
a10: assert property (slX_assert)
	$display ("SLX successful");
else
	$error ("SLX not successful");

property slA_assert;
@(posedge clk) ((operation == RS)&&(shift_operation == SA)&&(shift_constant == 1'b0)&&(shift_direction == 1'b0)) |->  (result == (operand_a<<1+carry_in))&&(carry_out == operand_a[7])&&(zero_out == (result ? 0 : 1));
endproperty 
a11: assert property (slA_assert)
	$display ("SLA successful");
else
	$error ("SLA not successful");

property rl_assert;
@(posedge clk) ((operation == RS)&&(shift_operation == RL_SRX)&&(shift_constant == 1'b0)&&(shift_direction == 1'b0)) |-> ({carry_out, result} == {operand_a, operand_a[7]})&&(zero_out == (result ? 0 : 1));
endproperty 
a12: assert property (rl_assert)
	$display ("RL successful");
else
	$error ("RL not successful");

property test_assert;
@(posedge clk) (operation == TEST) |-> (result == operand_a & operand_b)&&(carry_out == ^result)&&(zero_out == (result ? 0 : 1));
endproperty 
a18: assert property (test_assert)
	$display ("TEST successful");
else
	$error ("TEST not successful");

property compare_assert;
@(posedge clk) (operation == COMPARE) |-> (carry_out == (operand_b > operand_a))&&(zero_out == (operand_a == operand_b));
endproperty 
a19: assert property (compare_assert)
	$display ("COMPARE successful");
else
	$error ("COMPARE not successful");

*/

endmodule
