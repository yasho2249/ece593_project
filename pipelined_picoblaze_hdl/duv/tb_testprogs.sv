/*
tb_testprogs.sv - A short testbench to drive a RojoBlaze and look at the results in the scratchpad.

Author: Seth Rohrbach
Modified: March 17, 2020

----------
Description:

This testbench just waits for the last scratch pad ram location to be written to,
then prints out the values in all the scratch pads.
Designed simply to see the results of a number of short test programs for the RojoBlaze.

Acknowledgment:  SystemVerilog version created and tested by SethR, MilesS, 
ShubhankaSPM, and Supraj Vastrad for ECE 571 Winter 2020 final project

NOTE: (RK) I included 2 of the teams test programs as examples.

*/


import kcpsmx3_inc::*;

//`include "coverage.sv"

module alt_rojo_tb;

parameter tck = 10, program_size = 1024;

string memfile[] = '{
	// ADD ADDITIONAL TESTS HERE
    "add_test.mem"
};

reg clk, rst; // clock, reset
reg [OPERAND_WIDTH-1:0] prt[0:PORT_SIZE];
wire [OPERAND_WIDTH-1:0] pa, po; // port id, port out
wire rd, wr; // read strobe, write strobe
wire ir, ia; // interrupt req, interrupt ack
wire [OPERAND_WIDTH-1:0] pi; // port in
wire [1:152] opcode; // disassembler output
logic [7:0] local_mem [0:63]; //Local mem for testing use


kcpsmx dut(
	.clk(clk),
	.reset(rst),
	.port_id(pa),
	.read_strobe(rd),
	.write_strobe(wr),
	.in_port(pi),
	.out_port(po),
	.interrupt(ir),
	.interrupt_ack(ia)
);

disassembler dis(
    .instruction(dut.instruction),
    .kcpsm3_opcode(opcode)
);

//coverage ci (bfm);
integer			i;			// loop index


initial begin
	$monitor("%d %s z = %d c = %d || shiftbit = %d || shiftop = %s || reg cont = %X", $time, opcode, dut.zero, dut.carry, dut.alu.shift_bit, dut.alu.shift_operation.name(), dut.register_w_data_in);
	clk = 0;
	rst = 1;
	repeat(5) @(negedge clk);
	rst = 0; // free processor
	for (i = 0; i < 64; i = i + 1) begin //initialize local mem
		local_mem[i] = 8'b0;
	end
end



always #(tck/2) clk = ~clk;

always @(posedge clk) begin
    foreach (memfile[test]) begin
        $display("==================================");
        $display("Running test file %s", memfile[test]);
        rst = 1;
        @(negedge clk);
        $readmemh(memfile[test], dut.rom.ram);
        repeat(4) @(negedge clk);
        rst = 0;
        wait(~$isunknown(dut.scratch.spr[63]));
        repeat(20) @(negedge clk);
        $write("Test Program concluded.\n");
        $write("Scratch Pad Mem Values:\n");
        for(i = 0; i < 64; i = i + 1) begin
            $write("RAM[%2d] = %2X\n", i, dut.scratch.spr[i]);
        end
        $display("==================================\n\n");
	end
	$stop;
end


endmodule
