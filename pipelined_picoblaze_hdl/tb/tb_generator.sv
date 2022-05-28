/*

Group 3: Yashodhan Wagle, Ramaa Potnis, Supreet Gulavani
ECE 593: Final Project
        Testebench for verification of RojoBlaze

Generator module for creating .mem files

Since the picoblaze architecture reads only from the ROM, we have created a generator module to create the ROM files 
in the form of .mem files. 

*/
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

class generator;
    
    rand bit [5:0]  opcode;
    rand bit [3:0]  sx, sy, constant; 
    bit [17:0]   instr;

	int f;
    function void write_mem();
	
	instr = {opcode, sx, sy, constant};
        f = $fopen("./add_test.mem", "a");
        $fwrite(f, "%h\n", instr);
        $fclose(f);

    endfunction
endclass //generator 

import kcpsmx3_inc::*;

class opcode_generator;

    rand opcode_t op;

endclass

module top();
	
	bit [5:0]  opcode;
    bit [3:0]  sx, sy, constant;
	opcode_t op;
	
	initial begin 
	generator g = new();
	opcode_generator og = new();
	repeat (1024) begin
	assert(g.randomize());
	assert(og.randomize());
	$display("%b",op);
	g.write_mem();
	end
	end
endmodule
