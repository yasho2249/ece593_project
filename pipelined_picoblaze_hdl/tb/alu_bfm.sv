/*

Group 3: Yashodhan Wagle, Ramaa Potnis, Supreet Gulavani
ECE 593: Final Project
        Testebench for verification of RojoBlaze

BFM module for ALU 
***** WORK IN PROGRESS *****
*/

interface alu_bfm;

import kcpsmx3_inc::*;

// inputs _alu
logic opcode_t operation;
logic shift_op_t shift_operation;
logic shift_direction;
logic shift_constant;
logic [OPERAND_WIDTH-1:0] operand_a, operand_b;	
logic carry_in;

// output _alu
logic [OPERAND_WIDTH-1:0] result;
logic zero_out;
logic carry_out;

//local key;
bit local_key;

// //set clock
// initial begin
//     clk = 0;
//     forever begin
//         #10;
// 	    clk = ~clk;
//     end
// end

// //task for reset
// task reset_rojo();
//     reset_n = 1'b0;
//     @(negedge clk);
//     @(negedge clk);
//     reset_n = 1'b1;
//     local_key = 0;
// endtask: reset_rojo


//send_op task for BFM
task send_op_alu(input opcode_t t_operation, input shift_op_t t_shift_operation,
             input bit t_shift_direction, t_shift_constant, t_carry_in,
             input bit [OPERAND_WIDTH-1:0] t_operand_a, t_operand_b,
             output bit [OPERAND_WIDTH-1:0] t_result, output bit t_zero_out, t_carry_out);

// write initial conditions

if (t_operation == ADD || t_operation == ADDCY) begin
    operand_a = t_operand_a;
    operand_b = t_operand_b; 
    carry_in = t_carry_in;
    result = t_result;
    carry_out = t_carry_out;
end
else if (t_operation == SUB || t_operation == SUBCY) begin
    operand_a = t_operand_a;
    operand_b = t_operand_b; 
    carry_in = t_carry_in;
    result = t_result;
    carry_out = t_carry_out;
end
else if (t_operation == AND) begin
    operand_a = t_operand_a;
    operand_b = t_operand_b; 
    result = t_result;
end
else if (t_operation == OR) begin
    operand_a = t_operand_a;
    operand_b = t_operand_b; 
    result = t_result;
end
else if (t_operation == TEST) begin
    operand_a = t_operand_a;
    operand_b = t_operand_b; 
    result = t_result;
    carry_out = t_carry_out;
end
else if (t_operation == XOR) begin
    operand_a = t_operand_a;
    operand_b = t_operand_b; 
    result = t_result;
end
else if (t_operation == RS) begin
    if (shift_direction == t_shift_direction) begin
    operand_a = t_operand_a; 
    result = t_result;
    carry_out = t_carry_out;
    end else begin
        operand_a = t_operand_a; 
        result = t_result;
        carry_out = t_carry_out;
    end
end 
else    zero_out = t_zero_out;
  
endtask: send_op

endinterface: rojo_bfm
