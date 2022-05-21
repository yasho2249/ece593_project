/*
	Copyright (c) 2004 Pablo Bleyer Kocik.

    Modified for EE573 Fall 2005 by John Lynch, OGI/OHSU

	Redistribution and use in source and binary forms, with or without
	modification, are permitted provided that the following conditions are met:

	1. Redistributions of source code must retain the above copyright notice, this
	list of conditions and the following disclaimer.

	2. Redistributions in binary form must reproduce the above copyright notice,
	this list of conditions and the following disclaimer in the documentation
	and/or other materials provided with the distribution.

	3. The name of the author may not be used to endorse or promote products
	derived from this software without specific prior written permission.

	THIS SOFTWARE IS PROVIDED BY THE AUTHOR "AS IS" AND ANY EXPRESS OR IMPLIED
	WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
	MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO
	EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
	SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
	PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
	BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER
	IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
	ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
	POSSIBILITY OF SUCH DAMAGE.

    Behavioral KCPSMX 64-location scratchpad RAM.
	
	Acknowledgment:  SystemVerilog version created and tested by SethR, MilesS,
	ShubhankaSPM, and Supraj Vastrad for ECE 571 Winter 2020 final project
*/


import kcpsmx3_inc::*;

module kcpsmx_scratch(
	address, write_enable, data_in, data_out,
	reset, clk
);
input logic 	clk, reset, write_enable;
input logic  [SCRATCH_DEPTH-1:0] address;
input logic  [SCRATCH_WIDTH-1:0] data_in;
output logic [SCRATCH_WIDTH-1:0] data_out;

logic [SCRATCH_WIDTH-1:0] spr[0:SCRATCH_SIZE-1];

assign data_out = spr[address];
always_ff @ (posedge clk)
begin
    if (reset)
        for (int i = 0; i < SCRATCH_SIZE; i++)
            spr[i] = 'X;
    else if (write_enable)
        spr[address] <= data_in;
end

endmodule
