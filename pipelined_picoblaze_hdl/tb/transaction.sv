`ifndef __TRANSACTION_SV__
`define __TRANSACTION_SV__

/*

Group 3: Yashodhan Wagle, Ramaa Potnis, Supreet Gulavani
ECE 593: Final Project
        Testebench for verification of RojoBlaze

Transaction Class for creating .mem files

Since the picoblaze architecture reads only from the ROM, we have created a transaction class to create the ROM files 
in the form of .mem files. 

*/

class transaction;
    
	// Zero Opcode. Literally
    bit [5:0]  opcode;
	// Random Instruction opcode
	rand bit [5:0]  rand_opcode;
	// Control Instruction opcode 
	rand bit [4:0] 	control_opcode; 
    rand bit 		control_opcode_append;
	// Logical Instruction Opcode
	rand bit [4:0] 	logical_opcode;
	rand bit 		logical_opcode_append;
	// Interrupt Instruciton Opcode
	rand bit [5:0] 	interrupt_opcode;
	// Arithmetic Instruction Opcode
	rand bit [4:0] 	arithmetic_opcode;
	rand bit 		arithmetic_opcode_append;
	// Storage Instruction opcode
	rand bit [4:0] 	storage_opcode;
	rand bit 		storage_opcode_append;
	// I/O INstruction Opcode
	rand bit [4:0] 	io_opcode;
	rand bit 		io_opcode_append;
	// Shift and Rotate INstruction Opcodes
	rand bit [5:0] 	shift_opcode;
	// All Valid Instructions
	rand bit [5:0]	all_opcode;


	// Randomized Register and Constant values.
	// For specific regs or constants implement args functionality
	rand bit [3:0]  sx, sy;
	rand bit [7:0]	constant; 
    bit [17:0]   	instr;

	constraint control_type {
		control_opcode inside {5'b11010, 5'b11000, 5'b10101, 5'b11100};
	}

	constraint logical_type {
		logical_opcode inside {5'b00000, 5'b00101, 5'b00110, 5'b00111, 5'b01001};
	}

	constraint interrupt_type {
		interrupt_opcode inside {6'b111100};
	}

	constraint arithmetic_type {
		arithmetic_opcode inside {5'b011000, 5'b01101, 5'b01110, 5'b01111, 5'b01010};
	}

	constraint storage_type {
		storage_opcode inside {5'b10111, 5'b00011};
	}

	constraint io_type {
		io_opcode inside {5'b10110, 5'b00010};
	}

	constraint shift_type {
		shift_opcode inside {6'b100000};
	}

	constraint all_type {
		all_opcode inside {6'b100000, 	6'b110100, 6'b110000, 6'b101010, 6'b111000, 6'b000000, 6'b001010, 6'b001100, 6'b001110, 6'b010010, 6'b111100, 
										6'b110101, 6'b110001, 6'b101011, 6'b111001, 6'b000001, 6'b001011, 6'b001101, 6'b001111, 6'b010011,
										6'b011000, 6'b011010, 6'b011100, 6'b011110, 6'b010100, 6'b101110, 6'b000110, 6'b101100, 6'b000100, 
										6'b011011, 6'b011101, 6'b011111, 6'b010101, 6'b101111, 6'b000111, 6'b101101, 6'b000101};
	}


	int f;
	string txn_type;
	string filename;

    function void write_mem(int file_ext);

		if ($value$plusargs ("TXN=%s", txn_type)) 
            if (txn_type == "Random") begin
				instr = {rand_opcode, sx, constant};
			end

			else if (txn_type == "Control") begin
				instr = {control_opcode, control_opcode_append, sx, constant};
			end

			else if (txn_type == "Logical") begin
                instr = {logical_opcode, logical_opcode_append, sx, constant};
            end

			else if (txn_type == "Interrupt") begin
                instr = {interrupt_opcode, sx, constant};
            end

            else if (txn_type == "Arithmetic") begin
                instr = {arithmetic_opcode, arithmetic_opcode_append, sx, constant};
            end

			else if (txn_type == "Storage") begin
                instr = {storage_opcode, storage_opcode_append, sx, constant};
            end

			else if (txn_type == "Io") begin
                instr = {io_opcode, io_opcode_append, sx, constant};
            end

			else if (txn_type == "Shift") begin
                instr = {shift_opcode, sx, constant};
            end

			else if (txn_type == "All") begin
                instr = {all_opcode, sx, constant};
            end

			else $fatal ("No valid Args");
		
        $sformat(filename, "test%0d.mem", file_ext);
		f = $fopen(filename, "a");
        $fwrite(f, "%h\n", instr);
        $fclose(f);
    endfunction
endclass 


`endif