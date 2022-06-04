`ifndef __TRANSACTION_SV__
`define __TRANSACTION_SV__

/*

Group 3: Yashodhan Wagle, Ramaa Potnis, Supreet Gulavani
ECE 593: Final Project
        Testebench for verification of RojoBlaze

Generator module for creating .mem files

Since the picoblaze architecture reads only from the ROM, we have created a generator module to create the ROM files 
in the form of .mem files. 

*/

class transaction;
    
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
endclass 

/*
module transaction_top();
	
	bit [5:0]  opcode;
    bit [3:0]  sx, sy, constant;
	kcpsmx_alu(.operation(op));
	
	initial begin 
	transaction g = new();
	//operation_generator og =  new();
	repeat (1024) begin
	assert(g.randomize());
	//assert(og.randomize());
	g.write_mem();
	end
	end
endmodule
*/

`endif