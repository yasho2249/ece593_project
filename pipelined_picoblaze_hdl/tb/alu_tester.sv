/*

Group 3: Yashodhan Wagle, Ramaa Potnis, Supreet Gulavani
ECE 593: Final Project
        Testebench for verification of RojoBlaze

TESTER module for RojoBlaze 
*/

module alu_tester(rojo_bfm bfm);

import kcpsmx3_inc::*;


/*function to get stimulus for operand_a 
 --> static probability is used to select a value*/
function bit [OPERAND_WIDTH-1:0] get_operand_a();
  bit [1:0] max_min;
  max_min = $random;
  if(max_min == 2'b00)
    return 0; 
  else if(max_min == 2'b11)
    return 1;
  else
    return $random;
endfunction: get_operand_a

/*function to get stimulus for operand_b 
 --> static probability is used to select a value*/
function bit [OPERAND_WIDTH-1:0] get_operand_b();
  bit [1:0] max_min;
  max_min = $random;
  if(max_min == 2'b00)
    return 0;
  else if(max_min == 2'b11)
    return 1;
  else
    return $random;
endfunction: get_operand_b


initial begin

    opcode_t t_operation;
    shift_op_t t_shift_operation;
    bit t_shift_direction;
    bit t_shift_constant;
    bit [OPERAND_WIDTH-1:0] t_operand_a, t_operand_b;	
    bit t_carry_in;
    bit [OPERAND_WIDTH-1:0] t_result;
    bit t_zero_out;
    bit t_carry_out;
  
  int runs;
  string Initial_Task;
  
  //dynamic selection of a task to set initial conditions
  
  if($value$plusargs("InitialTask=%s", Initial_Task));
  if(Initial_Task == "ResetTask")
    bfm.reset_rojo();
  else
    $display("No initial task given");

  //dynamic selection of a number of runs
  if($value$plusargs("RUNS=%d", runs));
  
  $display("RUNS: %d", runs);
  $display("InitialTask: %s", Initial_Task);
  
  repeat (runs) begin: random_loop
	

	bfm.send_op_alu(t_operation, t_shift_operation, t_shift_direction,
                t_shift_constant, t_carry_in, t_operand_a, t_operand_b);

  end: random_loop
  $stop;
  
end

endmodule: alu_tester