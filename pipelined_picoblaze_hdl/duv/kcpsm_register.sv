/*
    Copyright (c) 2004 Pablo Bleyer Kocik.
 
    Modified for EE573 Fall 2005 by John Lynch, OGI/OHSU
        Added independent write address input

    Modified by Miles Simpson (mil32@pdx.edu) on March 9, 2020
    Updated to SystemVerilog, making use of kcpsmx3_inc package defintions

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

        Behavioral KCPSMX 16-location register file
		
	Acknowledgment:  SystemVerilog version created and tested by SethR, MilesS, ShubhankaSPM, and Supraj Vastrad for ECE 571 Winter 2020 final project
*/

import kcpsmx3_inc::*;

module kcpsmx_register(
    input clk, reset, w_write_enable,
    input  [REGISTER_DEPTH-1:0] w_address, x_address, y_address,
    input  [REGISTER_WIDTH-1:0] w_data_in,
    output [REGISTER_WIDTH-1:0] x_data_out, y_data_out
);

logic [REGISTER_WIDTH-1:0] dpr[0:REGISTER_SIZE-1];

assign x_data_out = dpr[x_address];
assign y_data_out = dpr[y_address];

always_ff @(negedge clk)
    if (w_write_enable) dpr[w_address] <= w_data_in;


// Register Load Store Assertions
/*
property load_assert;
@(posedge clk) (idex_operation == LOAD) |-> (w_write_enable) |=> w_data_in == w_data_in |=> dpr[$past (w_address,1)] == $past (w_data_in,1);
endproperty

a21: assert property(load_assert)
	$display ("LOAD performed successfully");
else
	$error ("LOAD not successful");
*/

endmodule
