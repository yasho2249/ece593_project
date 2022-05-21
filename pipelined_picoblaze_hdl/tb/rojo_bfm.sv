/*

Group 3: Yashodhan Wagle, Ramaa Potnis, Supreet Gulavani
ECE 593: Final Project
        Testebench for verification of RojoBlaze

BFM module for RojoBlaze 
***** WORK IN PROGRESS *****
*/

interface rojo_bfm;

import kcpsmx3_inc::*;

// inputs _rojo
logic reset, clk;
logic [PORT_WIDTH-1:0] in_port;
logic interrupt; 

// inputs _alu
logic opcode_t operation;
logic shift_op_t shift_operation;
logic shift_direction;
logic shift_constant;
logic [OPERAND_WIDTH-1:0] operand_a, operand_b;	
logic carry_in;

// outputs _rojo
wire [PORT_DEPTH-1:0] port_id;
wire write_strobe;  
wire [PORT_WIDTH-1:0] out_port;       
wire read_strobe;    
wire interrupt_ack;  

// output _alu
logic [OPERAND_WIDTH-1:0] result;
logic zero_out;
logic carry_out;

//local key;
bit local_key;

//set clock
initial begin
    clk = 0;
    forever begin
        #10;
	    clk = ~clk;
    end
end

//task for reset
task reset_rojo();
    reset_n = 1'b0;
    @(negedge clk);
    @(negedge clk);
    reset_n = 1'b1;
    local_key = 0;
endtask: reset_rojo


//send_op task for BFM
task send_op(input bit [PORT_WIDTH-1:0] t_in_port, 
    input bit t_interrupt,
    output bit [PORT_DEPTH-1:0] t_port_id,
    output bit t_write_strobe, t_read_strobe, t_interrupt_ack,
    output bit [PORT_WIDTH-1:0] t_out_port);

  // write initial conditions

  
endtask: send_op

endinterface: rojo_bfm
