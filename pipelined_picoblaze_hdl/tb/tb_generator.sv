/*

Group 3: Yashodhan Wagle, Ramaa Potnis, Supreet Gulavani
ECE 593: Final Project
        Testebench for verification of RojoBlaze

Generator module for creating .mem files

Since the picoblaze architecture reads only from the ROM, we have created a generator module to create the ROM files 
in the form of .mem files. 

*/


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

    rand opcode_t opcode;

endclass

module top();
	
	bit [5:0]  opcode;
    bit [3:0]  sx, sy, constant;
	
	initial begin 
	generator g = new();
	opcode_generator og = new();
	repeat (1024) begin
	assert(g.randomize());
	assert(og.randomize());
	g.write_mem();
	end
	end
endmodule
