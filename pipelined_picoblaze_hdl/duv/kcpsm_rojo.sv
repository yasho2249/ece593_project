/*
    Copyright (c) 2004 Pablo Bleyer Kocik.

    Modified for EE573 Fall 2005 by John Lynch, OGI/OHSU

    Modified by Miles Simpson (mil32@pdx.edu) March 8, 2020
    Updated to SystemVerilog and using new kcpsmx3_inc package
    Added Instruction Fetch and Execute Stack concurrent assertions to pipeline

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
	
	Acknowledgment:  SystemVerilog version created and tested by SethR, MilesS, ShubhankaSPM, and Supraj Vastrad for ECE 571 Winter 2020 final project
*/


/** pipeline control definitions **/
`define IS_PIPELINED
`define HAS_DATA_FORWARDING

/* Import kcpsmx3_inc package definitions */
import kcpsmx3_inc::*;

/** Top kcpsmx module. */
module kcpsmx(
    output logic [PORT_DEPTH-1:0]   port_id,        ///< Port address.
    output logic                    write_strobe,   ///< Port output strobe
    output logic [PORT_WIDTH-1:0]   out_port,       ///< Port output
    output logic                    read_strobe,    ///< Port input strobe
    input        [PORT_WIDTH-1:0]   in_port,        ///< Port input
    input                           interrupt,      ///< Interrupt request
    output logic                    interrupt_ack,  ///< Interrupt acknowledge
    input                           reset,          ///< Reset input
    input                           clk             ///< Clock input
);

/* Pipeline stage 0 - program counter */
logic [CODE_DEPTH-1:0]      program_counter;

/* IFID registers between Instruction Fetch and Instuction Decode stages */
///< Instruction register is contained within the instantiated ROM module
logic [CODE_DEPTH-1:0]      ifid_pcplus2;           ///< Program_counter plus 2 because of branch delay slot

/* IDEX registers between Instuction Decode and Execute stages */
logic [STACK_DEPTH-1:0]     stack_pointer;          ///<  stack_pointer
logic                       stack_write_enable;
logic [CODE_DEPTH-1:0]      idex_pcplus2;           ///< Program_counter plus 1
logic [REGISTER_WIDTH-1:0]  idex_reg_x_out,         ///< Register X output
                            idex_reg_y_out;         ///< Register Y output
logic [REGISTER_DEPTH-1:0]  idex_dst;               ///< destination register for ALU result
logic                       register_write_enable;  ///< register writeback enable
logic [1:0]                 idex_reg_source;        ///< register writeback data source
logic                       scratch_write_enable;
opcode_t                    idex_operation;
shift_op_t                  idex_shift_operation;
logic                       idex_shift_direction;
logic                       idex_shift_constant;
`ifdef HAS_DATA_FORWARDING
logic [REGISTER_DEPTH-1:0]  idex_x_address;
logic [REGISTER_DEPTH-1:0]  idex_y_address;
logic                       idex_operand_selection;
`endif

/* EXWB registers between Execute and Writeback stages */
logic [REGISTER_WIDTH-1:0]  exwb_alu_result;
logic [PORT_WIDTH-1:0]      exwb_in_port;
logic [REGISTER_WIDTH-1:0]  exwb_scratch_out;
logic [REGISTER_DEPTH-1:0]  exwb_dst;
logic [1:0]                 exwb_reg_source;        ///< register writeback data source
logic                       exwb_register_write;    ///< register write enable
logic                       zero;                   ///< Zero flag
logic                       carry;                  ///< Carry flag
logic                       zero_carry_write_enable;///< Zero/Carry update.

/* Interrupt registers */
logic interrupt_enable;                             ///< Interrupt enable.
logic interrupt_latch;                              ///< Interrupt latch hold.
logic zero_saved;                                   ///< Interrupt-saved zero flag.
logic carry_saved;                                  ///< Interrupt-saved carry flag.

/* Reset registers */
logic [1:0] reset_latch;                            ///< Reset latch.

wire internal_reset;                                ///< Internal reset signal.
wire conditional_match;                             ///< True when unconditional or flags match.
wire enable_PC, enable_IF, enable_EX, enable_WB;    ///< individual pipeline stage stall controls

/* instruction decode wires */
wire instr_t                instruction;            ///< instruction data from ROM
wire opcode_t               idu_operation;
wire shift_op_t             idu_shift_operation;
wire                        idu_shift_direction;
wire                        idu_shift_constant;
wire                        idu_operand_selection;
wire [REGISTER_DEPTH-1:0]   idu_x_address, idu_y_address;
wire [OPERAND_WIDTH-1:0]    idu_implied_value;
wire [PORT_DEPTH-1:0]       idu_port_address;
wire [SCRATCH_DEPTH-1:0]    idu_scratch_address;
wire [CODE_DEPTH-1:0]       idu_code_address;
wire                        idu_conditional;
wire cond_flag_t            idu_condition_flags;
wire                        idu_interrupt_enable;

/* ALU wires */
wire [OPERAND_WIDTH-1:0] alu_operand_a_in, alu_operand_b_in, alu_result;
wire alu_zero_out, alu_carry_out;

/* Stack wires */
wire [STACK_WIDTH-1:0] stack_data_out;

/* scratchpad register wires */
wire [SCRATCH_DEPTH-1:0] scratch_address;
wire [SCRATCH_WIDTH-1:0] scratch_data_in, scratch_data_out;

/* Register file wires */
wire [REGISTER_WIDTH-1:0] register_w_data_in, register_x_data_out, register_y_data_out;


/* ROM - Instruction ROM */
blockram #(
    .WIDTH(CODE_WIDTH),
    .DEPTH(CODE_DEPTH))
    rom(
    .clk(clk),
    .rst(internal_reset),
    .en(enable_IF),
    .we(1'b0),
    .ad(program_counter),
    .din(18'b0),
    .dout(instruction)
);

/* IDU - Instruction decode unit */
kcpsmx_idu idu(
    .instruction(instruction),
    .operation(idu_operation),
    .shift_operation(idu_shift_operation),
    .shift_direction(idu_shift_direction),
    .shift_constant(idu_shift_constant),
    .operand_selection(idu_operand_selection),
    .x_address(idu_x_address),
    .y_address(idu_y_address),
    .implied_value(idu_implied_value),
    .port_address(idu_port_address),
    .scratch_address(idu_scratch_address),
    .code_address(idu_code_address),
    .conditional(idu_conditional),
    .condition_flags(idu_condition_flags),
    .interrupt_enable(idu_interrupt_enable)
);

// register write data multiplexor
assign register_w_data_in =
    exwb_reg_source[1] ? exwb_scratch_out :
    exwb_reg_source[0] ? exwb_in_port : exwb_alu_result;

/* Register File */
kcpsmx_register register(
    .w_address(exwb_dst),
    .w_write_enable(exwb_register_write),
    .w_data_in(register_w_data_in),
    .x_address(idu_x_address),
    .x_data_out(register_x_data_out),
    .y_address(idu_y_address),
    .y_data_out(register_y_data_out),
    .reset(reset),
    .clk(clk)
);

/* ALU input multiplexers for data forwarding */
`ifdef HAS_DATA_FORWARDING
wire forward_alu_a_in = ((exwb_register_write == 1) && (exwb_dst == idex_x_address));
wire forward_alu_b_in = ((exwb_register_write == 1) && (exwb_dst == idex_y_address) && (idex_operand_selection == 1));
assign alu_operand_a_in = forward_alu_a_in ? register_w_data_in : idex_reg_x_out;
assign alu_operand_b_in = forward_alu_b_in ? register_w_data_in : idex_reg_y_out;
`else
assign alu_operand_a_in = idex_reg_x_out;
assign alu_operand_b_in = idex_reg_y_out;
`endif

/* ALU - Arithmetic Logic Unit */
kcpsmx_alu alu(
    .operation(idex_operation),
    .shift_operation(idex_shift_operation),
    .shift_direction(idex_shift_direction),
    .shift_constant(idex_shift_constant),
    .result(alu_result),
    .operand_a(alu_operand_a_in),
    .operand_b(alu_operand_b_in),
    .carry_in(carry),
    .zero_out(alu_zero_out),
    .carry_out(alu_carry_out)
);

/* Call/return stack */
kcpsmx_stack stack(
    .address(stack_pointer),
    .write_enable(stack_write_enable),
    .data_in(idex_pcplus2),
    .data_out(stack_data_out),
    .reset(reset),
    .clk(clk)
);

/* Scratchpad RAM */
assign scratch_address = alu_operand_b_in[SCRATCH_DEPTH-1:0];
assign scratch_data_in = alu_operand_a_in;

kcpsmx_scratch scratch(
    .address(scratch_address),
    .write_enable(scratch_write_enable),
    .data_in(scratch_data_in),
    .data_out(scratch_data_out),
    .reset(reset),
    .clk(clk)
);

/* brach flag logic */
assign conditional_match =
    (!idu_conditional
    || (idu_condition_flags == C && carry)
    || (idu_condition_flags == NC && ~carry)
    || (idu_condition_flags == Z && zero)
    || (idu_condition_flags == NZ && ~zero)
    ) ? 1 : 0;

/* pipelinable single-clock IO port -- does not meet 2-clock PicoBlaze spec */
assign port_id = (read_strobe || write_strobe) ? alu_operand_b_in : 0;
assign out_port = write_strobe ? alu_operand_a_in : 0;

/* reset logic */
always_ff @(posedge clk) begin: on_reset
    if (reset) reset_latch <= 'b11;
    else begin
        reset_latch[1] <= reset_latch[0];
        reset_latch[0] <= 0;
    end
end

assign internal_reset = reset_latch[1];

/* pipeline throttle */
logic [0:3] enable_stage;

always_ff @(posedge clk) begin
    `ifdef IS_PIPELINED
    if (internal_reset) enable_stage <= 4'b1111; // enable full pipelining
    `else
    if (internal_reset) enable_stage <= 4'b1000; // allows only one instruction at a time through the pipeline
    `endif
    else enable_stage <= {enable_stage[3],enable_stage[0:2]}; // shift enable_stage register
end


assign {enable_PC, enable_IF, enable_EX, enable_WB} = enable_stage;

/* pipeline registers */
always_ff @(posedge clk) begin
    if (internal_reset) begin: on_internal_reset
        /* Reset values */
        program_counter         <= RESET_VECTOR;
        stack_pointer           <= -1; // first write to stack increments stack_pointer to 0 before writing
        idex_operation          <= LOAD;
        idex_reg_x_out          <= 0;
        idex_reg_y_out          <= 0;
        idex_dst                <= 0;
        zero                    <= 0;
        carry                   <= 0;
        interrupt_ack           <= 0;
        interrupt_enable        <= 0;
        interrupt_latch         <= 0;
        write_strobe            <= 0;
        read_strobe             <= 0;
        register_write_enable   <= 0;
        exwb_register_write     <= 0;
        scratch_write_enable    <= 0;
        stack_write_enable      <= 0;
        zero_carry_write_enable <= 0;
    end
    else begin: on_run
        /* Idle values and default actions */
        read_strobe             <= 0;
        write_strobe            <= 0;
        register_write_enable   <= 0;
        exwb_register_write     <= 0;
        scratch_write_enable    <= 0;
        stack_write_enable      <= 0;
        interrupt_ack           <= 0;
        zero_carry_write_enable <= 0;

        if (enable_PC) begin
            if (((idu_operation == JUMP) || (idu_operation == CALL)) && conditional_match)
                program_counter <= idu_code_address;
            else if (((idu_operation == RETURN) || (idu_operation == RETURNI)) && conditional_match)
                program_counter <= stack_data_out;
            else
                program_counter <= program_counter + 1;
        end

        if (enable_IF) begin // instruction fetch
            ifid_pcplus2 <= program_counter + 2; // plus 2 because of branch delay slot
        end

        if (enable_EX) begin // execute
            idex_reg_x_out  <= register_x_data_out;
            idex_reg_y_out  <= (idu_operand_selection == 0) ? idu_implied_value : register_y_data_out;

            idex_pcplus2    <= ifid_pcplus2;
            idex_dst        <= idu_x_address;
            idex_reg_source <= {(idu_operation == FETCH),(idu_operation == INPUT)};

            idex_operation       <= idu_operation;
            idex_shift_operation <= idu_shift_operation;
            idex_shift_direction <= idu_shift_direction;
            idex_shift_constant  <= idu_shift_constant;
            execute(idu_operation);
            `ifdef HAS_DATA_FORWARDING
                idex_x_address         <= idu_x_address;
                idex_y_address         <= idu_y_address;
                idex_operand_selection <= idu_operand_selection;
            `endif
            /* execute task sets the following IDEX stage registers:
                read_strobe
                write_strobe
                register_write_enable
                stack_pointer
                stack_write_enable
                zero_carry_write_enable
            */
        end

        if (enable_WB) begin // write back
            exwb_alu_result     <= alu_result;
            exwb_scratch_out    <= scratch_data_out;
            exwb_dst            <= idex_dst;
            exwb_register_write <= register_write_enable;
            exwb_reg_source     <= idex_reg_source;
            exwb_in_port        <= in_port;
            if (zero_carry_write_enable) begin
                zero            <= alu_zero_out;
                carry           <= alu_carry_out;
            end
        end
    end // on_run
end //always_ff

task execute;
input opcode_t operation;
begin
    // synthesis parallel_case full_case
    case (operation)
        LOAD: register_write_enable <= 1;

        AND,
        OR,
        XOR,
        ADD,
        ADDCY,
        SUB,
        SUBCY,
        RS: begin
                register_write_enable   <= 1; // writeback sX
                zero_carry_write_enable <= 1; // writeback zero, carry
            end

        // JUMP: do nothing -- program_counter updates in a different pipeline stage

        CALL:
            if (conditional_match) begin
                stack_write_enable <= 1;
                stack_pointer      <= stack_pointer + 1;
            end

        RETURN:
            if (conditional_match) stack_pointer <= stack_pointer - 1; // pop

        RETURNI: begin
                stack_pointer    <= stack_pointer - 1; // pop
                zero             <= zero_saved;
                carry            <= carry_saved;
                interrupt_enable <= idu_interrupt_enable;
            end

        INTERRUPT: interrupt_enable <= idu_interrupt_enable;

        INPUT: begin
                read_strobe <= 1;
                register_write_enable <= 1;
            end

        OUTPUT: begin
                write_strobe <= 1;
            end

        COMPARE:
            zero_carry_write_enable <= 1;

        TEST:
            zero_carry_write_enable <= 1;

        FETCH:
            register_write_enable <= 1; // transfer scratch to sX

        STORE:
            scratch_write_enable <= 1;  // transfer sX to scratch

        default: ;
    endcase
end
endtask

endmodule
