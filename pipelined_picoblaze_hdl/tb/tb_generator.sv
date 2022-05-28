/*

Group 3: Yashodhan Wagle, Ramaa Potnis, Supreet Gulavani
ECE 593: Final Project
        Testebench for verification of RojoBlaze

Generator module for creating .mem files

Since the picoblaze architecture reads only from the ROM, we have created a generator module to create the ROM files 
in the form of .mem files. 

*/
import kcpsmx3_inc::*;
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

class operation_generator;
    rand var opcode_t op;

endclass

module top();
	
	bit [5:0]  opcode;
    bit [3:0]  sx, sy, constant;
	opcode_t op;
	kcpsmx_alu ka(.operation(op));
	
	initial begin 
	generator g = new();
	operation_generator og =  new();
	repeat (1024) begin
	assert(g.randomize());
	assert(og.randomize());
	g.write_mem();
	end
	end
endmodule
