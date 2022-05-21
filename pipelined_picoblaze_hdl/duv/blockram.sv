/*
    Block RAM module that loads from memory file

    Modified by Miles SImpson (mil32@pdx.edu) March 8, 2020
    Updated to SystemVerilog and using new kcpsmx3_inc package
	
	Acknowledgment:  Created and tested by SethR, MilesS, ShubhankaSPM, and Supraj Vastrad
	for ECE 571 Winter 2020 final project
*/
import kcpsmx3_inc::*;

module blockram(
    clk, rst,
    en, we, ad, din, dout
);

parameter WIDTH = 8, DEPTH = 10;

input clk, rst, en, we;
input [DEPTH-1:0] ad;
input [WIDTH-1:0] din;
output logic [WIDTH-1:0] dout;

logic [WIDTH-1:0] ram[0:(1<<DEPTH)-1];

always_ff @(posedge clk)
    if (rst) dout <= 'hx;
    else if (en)
        if (we) ram[ad] <= din;
        else dout <= ram[ad];

endmodule
